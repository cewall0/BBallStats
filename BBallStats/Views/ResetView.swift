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

    private let plus = PlusStore.shared
    private let season = SeasonStore.shared
    @State private var opponent = ""
    @State private var newPlayerName = ""
    @State private var showPaywall = false

    var body: some View {
        Group {
            if plus.isPlus { saveAndReset } else { confirmReset }
        }
        .navigationTitle("")
        .sheet(isPresented: $showPaywall) { NavigationStack { PlusPaywall() } }
    }

    // MARK: BBaller+: save the game to the player's season, then reset

    private var saveAndReset: some View {
        Form {
            Section("This game") {
                Text(game.line.summary).font(.title2.bold())
                Text(game.line.shooting).font(.subheadline.monospacedDigit()).foregroundStyle(.secondary)
            }
            Section("Save to season") {
                if season.players.isEmpty {
                    TextField("Player name", text: $newPlayerName)
                        .textContentType(.givenName)
                } else {
                    PlayerMenu(showPlayers: .constant(false))
                }
                TextField("Opponent (optional)", text: $opponent)
            }
            Section {
                Button {
                    let playerID = season.currentPlayerID ?? season.addPlayer(named: newPlayerName).id
                    season.record(game.line, opponent: opponent, for: playerID)
                    reset()
                } label: {
                    Text("Save Game & Reset").font(.headline).frame(maxWidth: .infinity)
                }
                .disabled(season.players.isEmpty && newPlayerName.trimmingCharacters(in: .whitespaces).isEmpty)
                if !season.playersWithLiveGames.isEmpty {
                    Button {
                        season.recordAll(onScreen: game.line, opponent: opponent)
                        reset()
                    } label: {
                        VStack {
                            Text("Save All Players' Games & Reset").font(.headline)
                            Text("Also saves " + season.playersWithLiveGames.map(\.name).formatted(.list(type: .and)))
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                Button("Reset Without Saving", role: .destructive) { reset() }
                    .frame(maxWidth: .infinity)
                Button("Cancel") { dismiss() }
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: Free: confirm, with a nudge to keep the game

    private var confirmReset: some View {
        GeometryReader { screen in
            let fontSize = min(screen.size.height / 19, screen.size.width / 8)
            VStack {
                Text("Are you sure you want to reset the stats?")
                    .padding()
                    .padding(.bottom, fontSize * 0.5)

                HStack {
                    Button("Yes") { reset() }
                        .padding(30)
                    Button("No") { dismiss() }
                        .padding(30)
                }

                VStack(spacing: 8) {
                    Text("Keep this game?").font(.headline)
                    Text("BBaller+ saves every game to the season, with averages, trends and share cards.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                    Button("Try BBaller+ free") { showPaywall = true }
                        .font(.headline)
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 14).fill(Color.orange.opacity(0.1)))
                .padding()
            }
            .font(.system(size: fontSize, weight: .bold))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    /// Resets the stats; a reset ends a game.
    private func reset() {
        game.reset()
        // Ask for a rating after the 3rd game, then every 10th (iOS limits how often it shows).
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
