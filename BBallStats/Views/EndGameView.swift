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
    @State private var chosen: Set<UUID> = []

    var body: some View {
        Group {
            if plus.isPlus { endGame } else { newGame }
        }
        .navigationTitle(plus.isPlus ? "End Game" : "New Game")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPaywall) { NavigationStack { PlusPaywall() } }
        .onAppear { opponent = season.resumedGame?.opponent ?? "" }
    }

    // MARK: BBaller+: end the game for everyone in it

    /// Everyone with stats in this game: the player on screen plus any paused games
    private var playersInGame: [Player] {
        season.players.filter { $0.id == season.currentPlayerID || season.hasLiveGame($0.id) }
    }

    private func line(for player: Player) -> StatLine {
        player.id == season.currentPlayerID ? game.line : (season.liveGame(for: player.id) ?? StatLine())
    }

    private var chosenNames: String {
        playersInGame.filter { chosen.contains($0.id) }.map(\.name).formatted(.list(type: .and))
    }

    private var endGame: some View {
        Form {
            if season.players.isEmpty {
                Section {
                    Text(game.line.summary).font(.title2.bold())
                    TextField("Player name", text: $newPlayerName)
                        .textContentType(.givenName)
                } header: {
                    Text("This game")
                }
            } else {
                Section {
                    ForEach(playersInGame) { player in
                        Button {
                            if chosen.contains(player.id) { chosen.remove(player.id) } else { chosen.insert(player.id) }
                        } label: {
                            HStack {
                                Image(systemName: chosen.contains(player.id) ? "checkmark.circle.fill" : "circle")
                                    .font(.title2)
                                    .foregroundStyle(chosen.contains(player.id) ? Color.accentColor : Color.secondary)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(player.name).font(.headline)
                                    Text(line(for: player).summary).font(.subheadline)
                                    Text(line(for: player).shooting).font(.caption.monospacedDigit()).foregroundStyle(.secondary)
                                }
                            }
                            .foregroundStyle(.primary)
                        }
                        .tint(.primary)
                        .accessibilityAddTraits(chosen.contains(player.id) ? .isSelected : [])
                    }
                } header: {
                    Text(playersInGame.count > 1 ? "Players in this game" : "This game")
                } footer: {
                    if playersInGame.count > 1 {
                        Text("Ticked players are saved together. Untick anyone whose game should stay in progress.")
                    } else if let resumed = season.resumedGame {
                        Text("Saving updates your game from \(resumed.date.formatted(date: .abbreviated, time: .omitted)).")
                    }
                }
            }

            Section("Opponent") {
                TextField("Opponent (optional)", text: $opponent)
            }

            Section {
                Button {
                    save()
                } label: {
                    Label("Save & Start New Game", systemImage: "tray.and.arrow.down.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .disabled(season.players.isEmpty ? newPlayerName.trimmingCharacters(in: .whitespaces).isEmpty : chosen.isEmpty)

                Button("Keep Playing") { dismiss() }
                    .frame(maxWidth: .infinity)
            } footer: {
                Text("Games in progress are saved on this phone automatically, so you can leave and come back any time. You can resume or edit a saved game later from Season.")
            }

            if !season.players.isEmpty {
                Section {
                    Button("Discard This Game", role: .destructive) { confirmDiscard = true }
                        .frame(maxWidth: .infinity)
                        .disabled(chosen.isEmpty)
                }
            }
        }
        .onAppear { chosen = Set(playersInGame.map(\.id)) }
        .confirmationDialog("Discard \(chosenNames)'s game?", isPresented: $confirmDiscard, titleVisibility: .visible) {
            Button("Discard", role: .destructive) {
                let onScreen = season.currentPlayerID.map { chosen.contains($0) } ?? false
                season.discardGames(chosen)
                if onScreen { startNewGame(finished: false) } else { dismiss() }
            }
        } message: {
            Text("Their stats will be cleared and not saved. A resumed game stays as it was saved.")
        }
    }

    private func save() {
        if season.players.isEmpty {
            let player = season.addPlayer(named: newPlayerName)
            season.endGame(saving: [player.id], onScreen: game.line, opponent: opponent)
            startNewGame()
            return
        }
        let onScreen = season.currentPlayerID.map { chosen.contains($0) } ?? false
        season.endGame(saving: chosen, onScreen: game.line, opponent: opponent)
        // The board clears when the player on screen was saved; otherwise their game carries on
        if onScreen { startNewGame() } else { completedGames += 1; dismiss() }
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
