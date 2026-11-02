//
//  EndGameView.swift
//  BBaller Stats
//
//  Created by Chad Wallace on 10/27/22.
//

import SwiftUI
import StoreKit

/// Ends the game on screen. BBaller+ saves it to the player's season; the free app clears it.
struct EndGameView: View {
    @Environment(Game.self) private var game
    @Environment(\.dismiss) private var dismiss
    @Environment(\.requestReview) private var requestReview
    @AppStorage("completedGames") private var completedGames = 0

    private let plus = PlusStore.shared
    private let season = SeasonStore.shared
    @State private var opponent = ""
    @State private var newPlayerName = ""
    @State private var showPaywall = false
    @State private var confirmDiscard = false

    var body: some View {
        Group {
            if plus.isPlus { endGame } else { newGame }
        }
        .navigationTitle(plus.isPlus ? "End Game" : "New Game")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPaywall) { NavigationStack { PlusPaywall() } }
        .onAppear { opponent = season.resumedGame?.opponent ?? "" }
    }

    // MARK: BBaller+: save to the season (the main action), or discard on purpose

    private var endGame: some View {
        Form {
            Section {
                Text(game.line.summary).font(.title2.bold())
                Text(game.line.shooting).font(.subheadline.monospacedDigit()).foregroundStyle(.secondary)
            } header: {
                Text(season.currentPlayer.map { "\($0.name)'s game" } ?? "This game")
            } footer: {
                if let resumed = season.resumedGame {
                    Text("Saving updates your game from \(resumed.date.formatted(date: .abbreviated, time: .omitted)).")
                }
            }

            Section("Save to season") {
                if season.players.isEmpty {
                    TextField("Player name", text: $newPlayerName)
                        .textContentType(.givenName)
                }
                TextField("Opponent (optional)", text: $opponent)
            }

            Section {
                Button {
                    let playerID = season.currentPlayerID ?? season.addPlayer(named: newPlayerName).id
                    season.record(game.line, opponent: opponent, for: playerID)
                    startNewGame()
                } label: {
                    Label("Save & Start New Game", systemImage: "tray.and.arrow.down.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .disabled(season.players.isEmpty && newPlayerName.trimmingCharacters(in: .whitespaces).isEmpty)

                if !season.playersWithLiveGames.isEmpty {
                    Button {
                        season.recordAll(onScreen: game.line, opponent: opponent)
                        startNewGame()
                    } label: {
                        VStack {
                            Text("Save All Players & Start New Game").font(.headline)
                            Text("Also saves " + season.playersWithLiveGames.map(\.name).formatted(.list(type: .and)))
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }

                Button("Keep Playing") { dismiss() }
                    .frame(maxWidth: .infinity)
            } footer: {
                Text("Your game in progress is saved on this phone automatically, so you can leave and come back any time. You can resume or edit a saved game later from Season.")
            }

            Section {
                Button("Discard This Game", role: .destructive) { confirmDiscard = true }
                    .frame(maxWidth: .infinity)
            }
        }
        .confirmationDialog("Discard this game?", isPresented: $confirmDiscard, titleVisibility: .visible) {
            Button("Discard Game", role: .destructive) {
                if let id = season.currentPlayerID { season.discardLiveGame(for: id) }
                startNewGame(finished: false)
            }
        } message: {
            Text(season.resumedGame == nil
                 ? "The stats on screen will be cleared and not saved."
                 : "Changes since you resumed will be lost. The saved game stays as it was.")
        }
    }

    // MARK: Free: clear the stats, with a nudge to keep the game

    private var newGame: some View {
        GeometryReader { screen in
            let fontSize = min(screen.size.height / 22, screen.size.width / 10)
            VStack(spacing: 18) {
                Text("Start a new game?")
                    .font(.system(size: fontSize, weight: .bold))
                Text("This clears the stats on screen.")
                    .font(.title3)
                    .foregroundStyle(.secondary)

                HStack(spacing: 40) {
                    Button("Start New Game") { startNewGame() }
                    Button("Keep Playing") { dismiss() }
                }
                .font(.system(size: fontSize * 0.7, weight: .bold))
                .padding(.vertical)

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
            }
            .multilineTextAlignment(.center)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    /// Clears the board. A finished (not discarded) game is when we may ask for a rating.
    private func startNewGame(finished: Bool = true) {
        game.reset()
        // Ask for a rating after the 3rd game, then every 10th (iOS limits how often it shows).
        // No interstitial here: a new game usually starts right away.
        if finished {
            completedGames += 1
            if completedGames == 3 || completedGames % 10 == 0 {
                requestReview()
            }
        }
        dismiss()
    }
}

#Preview {
    NavigationStack { EndGameView() }
        .environment(Game())
}
