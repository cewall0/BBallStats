//
//  PlusStore.swift
//  BBaller Stats
//
//  BBaller+: an auto-renewing subscription that adds the season log, multiple
//  players and share cards, and removes ads.
//

import StoreKit
import SwiftUI

@MainActor
@Observable
final class PlusStore {
    static let shared = PlusStore()

    static let productIDs = ["com.WallaceApps.FavBBaller.plus.yearly", "com.WallaceApps.FavBBaller.plus.monthly"]
    static let termsURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
    static let privacyURL = URL(string: "https://wallacewaysoftware.com/my-bballer-stats/privacy/")!

    private(set) var isPlus = false
    private var updates: Task<Void, Never>?

    private init() {
        #if DEBUG
        if CommandLine.arguments.contains("-plusDemo") { isPlus = true; return }
        #endif
        updates = Task { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let transaction) = result { await transaction.finish() }
                await self?.refresh()
            }
        }
        Task { await refresh() }
    }

    func refresh() async {
        var active = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let t) = result, Self.productIDs.contains(t.productID), t.revocationDate == nil {
                active = true
            }
        }
        isPlus = active
    }
}

/// Apple's subscription screen: prices, trial terms, Restore Purchases and policy links.
struct PlusPaywall: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        SubscriptionStoreView(productIDs: PlusStore.productIDs) {
            VStack(spacing: 14) {
                Image(systemName: "basketball.fill")
                    .font(.system(size: 54))
                    .foregroundStyle(.orange)
                    .accessibilityHidden(true)
                Text("BBaller+")
                    .font(.title.bold())
                VStack(alignment: .leading, spacing: 10) {
                    Label("Save every game to the season", systemImage: "tray.full.fill")
                    Label("Season averages, shooting % and trends", systemImage: "chart.line.uptrend.xyaxis")
                    Label("Track more than one player", systemImage: "person.2.fill")
                    Label("Share game cards with family", systemImage: "square.and.arrow.up")
                    Label("No ads", systemImage: "nosign")
                }
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
        }
        .storeButton(.visible, for: .restorePurchases)
        .storeButton(.visible, for: .policies)
        .subscriptionStorePolicyDestination(url: PlusStore.termsURL, for: .termsOfService)
        .subscriptionStorePolicyDestination(url: PlusStore.privacyURL, for: .privacyPolicy)
        .subscriptionStoreControlStyle(.prominentPicker)
        .onInAppPurchaseCompletion { _, result in
            if case .success(.success) = result {
                await PlusStore.shared.refresh()
                dismiss()
            }
        }
    }
}
