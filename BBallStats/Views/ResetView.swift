//
//  ResetView.swift
//  BBaller Stats
//
//  Created by Chad Wallace on 10/27/22.
//

import SwiftUI
import StoreKit

struct ResetView: View {
    @Environment(Game.self) private var game
    @Environment(\.dismiss) private var dismiss
    @Environment(\.requestReview) private var requestReview
    @AppStorage("completedGames") private var completedGames = 0

    var body: some View {
        GeometryReader { screen in
            let fontSize = min(screen.size.height / 19, screen.size.width / 8)
            VStack {
                Text("Are you sure you want to reset the stats?")
                    .padding()
                    .padding(.bottom, fontSize)

                HStack {
                    Button("Yes") { reset() }
                        .padding(30)
                    Button("No") { dismiss() }
                        .padding(30)
                }
            }
            .font(.system(size: fontSize, weight: .bold))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationTitle("")
    }

    private func reset() {
        game.reset()
        // A reset ends a game: ask for a rating after the 3rd, then every 10th (iOS limits how often it shows).
        // No interstitial here: a reset usually happens right before the next game starts.
        completedGames += 1
        if completedGames == 3 || completedGames % 10 == 0 {
            requestReview()
        }
        dismiss()
    }
}

#Preview {
    ResetView()
        .environment(Game())
}
