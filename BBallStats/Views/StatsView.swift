//
//  StatsView.swift
//  BBaller Stats
//
//  Created by Chad Wallace on 11/2/22.
//

import SwiftUI

/// The box score above the buttons.
struct StatsView: View {
    @Environment(Game.self) private var game
    let fontSize: CGFloat

    var body: some View {
        let s = game.line
        VStack(spacing: 2) {
            line("\(s.points) (tot pts)", "\(s.twoMade)-\(s.twoAttempted) (2-pt)")
            line("\(s.threeMade)-\(s.threeAttempted) (3-pt)", "\(s.ftMade)-\(s.ftAttempted) (FT)")
            line("\(s.rebounds) Reb", "\(s.assists) Asst", "\(s.steals) Stls")
            line("\(s.turnovers) TO", "\(s.blocks) Blks", "\(s.fouls) Fls")
        }
        .font(.system(size: fontSize, weight: .bold))
        .lineLimit(1)
        .minimumScaleFactor(0.6)
    }

    /// Items separated by blue bars
    private func line(_ items: String...) -> some View {
        HStack {
            ForEach(Array(items.enumerated()), id: \.offset) { i, item in
                if i > 0 { Text("|").foregroundColor(.statDivider) }
                Text(item)
            }
        }
        .accessibilityElement(children: .combine)
    }
}
