//
//  GameView.swift
//  BBaller Stats
//
//  Created by Chad Wallace on 10/21/22.
//

import SwiftUI
import WallaceAds

struct GameView: View {
    @Environment(Game.self) private var game
    @State private var showFix = false
    @State private var showSeason = false
    @State private var showPaywall = false
    @State private var lastTap: LastTap?
    @State private var tapCount = 0
    private let plus = PlusStore.shared
    private let season = SeasonStore.shared

    // Shot buttons on the left (two per row), hustle stats on the right
    private let leftStats: [Stat] = [.madeTwo, .missedTwo, .madeThree, .missedThree,
                                     .madeFreeThrow, .missedFreeThrow, .turnover, .foul]
    private let rightStats: [Stat] = [.rebound, .assist, .steal, .block]

    /// The most recent tap, with the stats from just before it so Undo can put them back exactly.
    struct LastTap: Equatable {
        let id = UUID()
        let stat: Stat
        let before: StatLine
    }

    var body: some View {
        NavigationStack {
            GeometryReader { screen in
                // Text scales with the space available (with or without the ad banner, iPhone or iPad)
                let textSize = min(screen.size.height / 26, screen.size.width / 12)
                let sideBySide = screen.size.width > screen.size.height   // iPad landscape

                VStack(spacing: 8) {
                    if sideBySide {
                        HStack(spacing: 24) {
                            VStack(spacing: 14) {
                                header(textSize: min(textSize, 34))
                                Spacer(minLength: 0)
                                controls(fontSize: min(textSize * 0.55, 20))
                            }
                            .frame(width: screen.size.width * 0.38)
                            GeometryReader { area in
                                buttonGrid(in: area.size)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
                        .padding(.horizontal)
                    } else {
                        header(textSize: textSize)
                        GeometryReader { area in
                            buttonGrid(in: area.size)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        controls(fontSize: min(textSize * 0.55, 20))
                    }

                    if WallaceAds.privacyOptionsRequired {
                        Button("Ad privacy settings") {
                            WallaceAds.presentPrivacyOptions()
                        }
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    }

                    if !plus.isPlus {
                        BannerAdView(size: .compact)
                    }
                    Color.clear.frame(height: 10)
                }
            }
            .background(Color(.systemBackground))
            .ignoresSafeArea(edges: .bottom)
            .sensoryFeedback(.impact(weight: .light), trigger: tapCount)
            .onChange(of: season.currentPlayerID) { _, _ in lastTap = nil }   // Undo belongs to the player it was for
            .onDisappear { lastTap = nil }                                        // ...and to the game it was in
            .task(id: lastTap?.id) {
                guard lastTap != nil else { return }
                try? await Task.sleep(for: .seconds(4))
                if !Task.isCancelled { withAnimation { lastTap = nil } }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    WallaceAds.start()
                }
            }
            .navigationTitle("")
            .navigationDestination(isPresented: $showSeason) { SeasonView() }
            .sheet(isPresented: $showPaywall) { NavigationStack { PlusPaywall() } }
        }
        // On the stack itself so pushed screens (Season, game detail) can pop back here
        .environment(\.returnToGame, ReturnToGame { showSeason = false })
    }

    /// Player chips (BBaller+) and the scoreboard
    @ViewBuilder private func header(textSize: CGFloat) -> some View {
        if plus.isPlus {
            PlayerSwitcher(fontSize: min(textSize * 0.7, 26))
                .padding(.top, 4)
        }
        StatsView(fontSize: textSize)
            .padding(.horizontal, 12)
            .padding(.top, plus.isPlus ? 0 : 8)
    }

    /// 4 rows: two columns of shot buttons, a divider, and one column of hustle stats.
    private func buttonGrid(in size: CGSize) -> some View {
        let spacing: CGFloat = 8
        let diameter = min((size.height - spacing * 3) / 4,
                           (size.width - spacing * 4 - 2) / 3,
                           200)
        return HStack(spacing: spacing) {
            Grid(horizontalSpacing: spacing, verticalSpacing: spacing) {
                ForEach(0..<4, id: \.self) { row in
                    GridRow {
                        statButton(leftStats[row * 2], diameter: diameter)
                        statButton(leftStats[row * 2 + 1], diameter: diameter)
                    }
                }
            }
            Capsule()
                .fill(Color.secondary.opacity(0.35))
                .frame(width: 2, height: diameter * 4 + spacing * 3)
            VStack(spacing: spacing) {
                ForEach(rightStats) { statButton($0, diameter: diameter) }
            }
        }
    }

    private func statButton(_ stat: Stat, diameter: CGFloat) -> some View {
        Button(showFix ? stat.undoTitle : stat.buttonTitle) { tap(stat) }
            .buttonStyle(StatButtonStyle(positive: stat.isPositive, diameter: diameter, fixing: showFix))
            .accessibilityLabel(showFix ? "Undo \(stat.spokenName)" : stat.spokenName)
    }

    /// Records (or, in Fix mode, removes) a stat and vibrates. After a record, the Fix button
    /// becomes "Undo +2" for a few seconds; End Game and Season stay available.
    private func tap(_ stat: Stat) {
        let before = game.line
        if showFix { game.undo(stat) } else { game.record(stat) }
        tapCount += 1
        lastTap = !showFix && game.line != before ? LastTap(stat: stat, before: before) : nil
    }

    /// Fix switches the buttons to undo; End Game (New Game when free) finishes it; Season is BBaller+.
    private func controls(fontSize: CGFloat) -> some View {
        HStack(spacing: 10) {
            // A plain button (not a toggle-style Toggle, which adds its own padding) so all three capsules match
            if let lastTap {
                Button {
                    game.line = lastTap.before
                    withAnimation { self.lastTap = nil }
                } label: {
                    capsule("Undo " + lastTap.stat.shortName, fontSize: fontSize,
                            fill: Color.brandOrange.opacity(0.15), text: .brandOrange)
                }
                .accessibilityLabel("Undo " + lastTap.stat.spokenName.lowercased())
                .transition(.opacity)
            } else {
                Button { showFix.toggle() } label: {
                    capsule(showFix ? "Fixing" : "Fix", fontSize: fontSize,
                            fill: showFix ? Color.brandOrange : Color(.tertiarySystemFill),
                            text: showFix ? .white : .primary)
                }
                .accessibilityLabel("Fix")
                .accessibilityValue(showFix ? "On" : "Off")
                .accessibilityHint("Switches the stat buttons to undo")
                .accessibilityAddTraits(showFix ? .isSelected : [])
                .transition(.opacity)
            }

            NavigationLink(destination: EndGameView()) {
                capsule(plus.isPlus ? "End Game" : "New Game", fontSize: fontSize, fill: .brandOrange, text: .white)
            }
            .accessibilityLabel(plus.isPlus ? "End Game" : "New Game")

            Button {
                if plus.isPlus { showSeason = true } else { showPaywall = true }
            } label: {
                capsule("Season", fontSize: fontSize, fill: Color.brandOrange.opacity(0.15), text: .brandOrange)
            }
            .accessibilityLabel("Season")
            .accessibilityHint(plus.isPlus ? "Season averages and saved games" : "BBaller+ subscription")
        }
        .animation(.easeOut(duration: 0.2), value: lastTap)
    }

    private func capsule(_ title: String, fontSize: CGFloat, fill: Color, text: Color) -> some View {
        Text(title)
            .font(.system(size: fontSize, weight: .bold, design: .rounded))
            .minimumScaleFactor(0.5)
            .lineLimit(1)
            .padding(.horizontal, 10)
            .frame(width: 118, height: 40)   // three fit a 375-pt phone; one size so "End Game" isn't shrunk
            .foregroundStyle(text)
            .background(Capsule().fill(fill))
    }
}

/// Round stat button: green for good plays, red for misses and mistakes; presses in when tapped.
struct StatButtonStyle: ButtonStyle {
    let positive: Bool
    let diameter: CGFloat
    var fixing = false

    func makeBody(configuration: Configuration) -> some View {
        let top = positive ? Color.statGreenLight : Color.statRedLight
        let bottom = positive ? Color.statGreen : Color.statRed
        configuration.label
            .multilineTextAlignment(.center)
            .font(.system(size: diameter * 0.16, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .frame(width: diameter, height: diameter)
            .background(Circle().fill(LinearGradient(colors: [top, bottom], startPoint: .top, endPoint: .bottom)))
            .overlay(Circle().strokeBorder(Color.white.opacity(0.22), lineWidth: 1.5))
            // In Fix mode a dashed orange ring makes it obvious the buttons now take stats away
            .overlay(Circle().strokeBorder(Color.brandOrange, style: StrokeStyle(lineWidth: 4, dash: [8, 6]))
                .opacity(fixing ? 1 : 0))
            .shadow(color: .black.opacity(configuration.isPressed ? 0.1 : 0.25),
                    radius: configuration.isPressed ? 1 : 3, y: configuration.isPressed ? 1 : 2.5)
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.easeOut(duration: 0.08), value: configuration.isPressed)
    }
}

extension Color {
    static let statGreen = Color(red: 0.11, green: 0.50, blue: 0.24)
    static let statGreenLight = Color(red: 0.22, green: 0.66, blue: 0.35)
    static let statRed = Color(red: 0.74, green: 0.15, blue: 0.15)
    static let statRedLight = Color(red: 0.90, green: 0.31, blue: 0.29)
    /// App controls (chips, End Game, Season); dark enough for white text
    static let brandOrange = Color(red: 0.78, green: 0.34, blue: 0.02)
}

#Preview {
    GameView()
        .environment(Game())
}

/// Pops back to the game screen, e.g. after resuming a saved game from Season.
struct ReturnToGame {
    var action: () -> Void = {}
    func callAsFunction() { action() }
}

extension EnvironmentValues {
    @Entry var returnToGame = ReturnToGame()
}
