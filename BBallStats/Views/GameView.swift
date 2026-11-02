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
    private let plus = PlusStore.shared

    // Shot buttons on the left (two per row), hustle stats on the right
    private let leftStats: [Stat] = [.madeTwo, .missedTwo, .madeThree, .missedThree,
                                     .madeFreeThrow, .missedFreeThrow, .turnover, .foul]
    private let rightStats: [Stat] = [.rebound, .assist, .steal, .block]

    var body: some View {
        NavigationStack {
            GeometryReader { screen in
                // Text scales with the space available (with or without the ad banner, iPhone or iPad)
                let textSize = min(screen.size.height / 26, screen.size.width / 12)

                VStack(spacing: 8) {
                    if plus.isPlus {
                        PlayerSwitcher(fontSize: min(textSize * 0.7, 26))
                            .padding(.top, 4)
                    }
                    StatsView(fontSize: textSize)
                        .padding(.top, plus.isPlus ? 0 : 8)

                    GeometryReader { area in
                        buttonGrid(in: area.size)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }

                    controls(fontSize: min(textSize * 0.7, 28))

                    HStack(spacing: 16) {
                        if WallaceAds.privacyOptionsRequired {
                            Button("Ad privacy settings") {
                                WallaceAds.presentPrivacyOptions()
                            }
                        }
                    }
                    .font(.footnote)
                    .foregroundColor(.gray)

                    if !plus.isPlus {
                        BannerAdView(size: .compact)
                    }
                    Color.clear.frame(height: 10)
                }
            }
            .background(Color.white)
            .ignoresSafeArea(edges: .bottom)
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

    /// 4 rows: two columns of shot buttons, a divider, and one column of hustle stats.
    private func buttonGrid(in size: CGSize) -> some View {
        let spacing: CGFloat = 6
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
            Rectangle()
                .fill(Color.black)
                .frame(width: 2, height: diameter * 4 + spacing * 3)
            VStack(spacing: spacing) {
                ForEach(rightStats) { statButton($0, diameter: diameter) }
            }
        }
    }

    private func statButton(_ stat: Stat, diameter: CGFloat) -> some View {
        Button(showFix ? stat.undoTitle : stat.buttonTitle) {
            if showFix { game.undo(stat) } else { game.record(stat) }
        }
        .buttonStyle(StatButtonStyle(color: stat.isPositive ? .statGreen : .statRed, diameter: diameter))
        .accessibilityLabel(showFix ? "Undo \(stat.spokenName)" : stat.spokenName)
    }

    /// Fix switches the buttons to undo; End Game (New Game when free) finishes it; Season is BBaller+.
    private func controls(fontSize: CGFloat) -> some View {
        HStack(spacing: 20) {
            Toggle(isOn: $showFix) {
                Text("Fix")
                    .font(.system(size: fontSize, weight: .bold))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .frame(width: 100, height: 40)
                    .foregroundColor(.white)
                    .background(showFix ? Color.blue : Color.gray)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.blue, lineWidth: 2))
            }
            .toggleStyle(.button)

            NavigationLink(destination: EndGameView()) {
                Text(plus.isPlus ? "End Game" : "New Game")
                    .font(.system(size: fontSize, weight: .bold))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .frame(width: 100, height: 40)
                    .foregroundColor(.white)
                    .background(Color.red)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.red.opacity(0.8), lineWidth: 2))
            }

            Button {
                if plus.isPlus { showSeason = true } else { showPaywall = true }
            } label: {
                Text("Season")
                    .font(.system(size: fontSize, weight: .bold))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .frame(width: 100, height: 40)
                    .foregroundColor(.white)
                    .background(Color.seasonOrange)
                    .clipShape(Capsule())
            }
            .accessibilityHint(plus.isPlus ? "Season averages and saved games" : "BBaller+ subscription")
        }
    }
}

/// Round stat button that grows and fades while pressed.
struct StatButtonStyle: ButtonStyle {
    let color: Color
    let diameter: CGFloat

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .multilineTextAlignment(.center)
            .font(.system(size: diameter * 0.163, weight: .bold))
            .foregroundColor(.white)
            .frame(width: diameter, height: diameter)
            .background(color)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.black, lineWidth: 4))
            .scaleEffect(configuration.isPressed ? 1.1 : 1.0)
            .opacity(configuration.isPressed ? 0.6 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

extension Color {
    static let statGreen = Color(red: 0, green: 100 / 255, blue: 0)
    static let statRed = Color(red: 178 / 255, green: 34 / 255, blue: 34 / 255)
    static let statDivider = Color(red: 0, green: 0, blue: 205 / 255)
    static let seasonOrange = Color(red: 0.75, green: 0.33, blue: 0)
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
