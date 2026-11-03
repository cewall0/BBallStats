//
//  StatsView.swift
//  BBaller Stats
//
//  Created by Chad Wallace on 11/2/22.
//

import SwiftUI

/// The scoreboard above the buttons: big points, then shooting and the other stats as tiles.
struct StatsView: View {
    @Environment(Game.self) private var game
    let fontSize: CGFloat

    var body: some View {
        let s = game.line
        VStack(spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("\(s.points)")
                    .font(.system(size: fontSize * 1.9, weight: .heavy, design: .rounded))
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(.snappy, value: s.points)
                Text("PTS")
                    .font(.system(size: fontSize * 0.55, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(s.points) points")
            .accessibilityIdentifier("points")

            HStack(spacing: 6) {
                tile("2PT", "\(s.twoMade)-\(s.twoAttempted)", spoken: "2 pointers \(s.twoMade) of \(s.twoAttempted)")
                tile("3PT", "\(s.threeMade)-\(s.threeAttempted)", spoken: "3 pointers \(s.threeMade) of \(s.threeAttempted)")
                tile("FT", "\(s.ftMade)-\(s.ftAttempted)", spoken: "Free throws \(s.ftMade) of \(s.ftAttempted)")
            }
            HStack(spacing: 6) {
                tile("REB", "\(s.rebounds)", spoken: "\(s.rebounds) rebounds")
                tile("AST", "\(s.assists)", spoken: "\(s.assists) assists")
                tile("STL", "\(s.steals)", spoken: "\(s.steals) steals")
                tile("BLK", "\(s.blocks)", spoken: "\(s.blocks) blocks")
                tile("TO", "\(s.turnovers)", spoken: "\(s.turnovers) turnovers")
                tile("PF", "\(s.fouls)", spoken: "\(s.fouls) fouls" + (s.fouls >= StatLine.maxFouls ? ", fouled out" : ""),
                     tint: s.fouls >= StatLine.maxFouls ? .statRed : (s.fouls == StatLine.maxFouls - 1 ? .brandOrange : nil))
            }
        }
    }

    /// A stat tile; a tint highlights foul trouble.
    private func tile(_ label: String, _ value: String, spoken: String, tint: Color? = nil) -> some View {
        VStack(spacing: 0) {
            Text(value)
                .font(.system(size: fontSize * 0.62, weight: .bold, design: .rounded))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(label)
                .font(.system(size: max(10, fontSize * 0.3), weight: .bold, design: .rounded))
                .foregroundStyle(tint == nil ? Color.secondary : Color.white.opacity(0.9))
        }
        .foregroundStyle(tint == nil ? Color.primary : Color.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 5)
        .background(RoundedRectangle(cornerRadius: 10).fill(tint ?? Color(.secondarySystemBackground)))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spoken)
    }
}
