//
//  Game.swift
//  BBaller Stats
//
//  Created by Chad Wallace on 10/27/22.
//

import SwiftUI
import Observation

/// Everything a button can record. The order is the order of the buttons.
enum Stat: CaseIterable, Identifiable {
    case madeTwo, missedTwo, madeThree, missedThree, madeFreeThrow, missedFreeThrow, turnover, foul
    case rebound, assist, steal, block

    var id: Self { self }

    /// Good plays are green, misses and mistakes are red
    var isPositive: Bool {
        switch self {
        case .missedTwo, .missedThree, .missedFreeThrow, .turnover, .foul: return false
        default: return true
        }
    }

    var buttonTitle: String {
        switch self {
        case .madeTwo: return "Made\n2 pt"
        case .missedTwo: return "Missed\n2 pt"
        case .madeThree: return "Made\n3 pt"
        case .missedThree: return "Missed\n3 pt"
        case .madeFreeThrow: return "Made\nFree\nThrow"
        case .missedFreeThrow: return "Missed\nFree\nThrow"
        case .turnover: return "Turn\nOver"
        case .foul: return "Foul"
        case .rebound: return "Reb"
        case .assist: return "Assist"
        case .steal: return "Steal"
        case .block: return "Block"
        }
    }

    var undoTitle: String {
        switch self {
        case .madeTwo: return "Undo\nMade 2"
        case .missedTwo: return "Undo\nMissed\n2"
        case .madeThree: return "Undo\nMade 3"
        case .missedThree: return "Undo\nMissed\n3"
        case .madeFreeThrow: return "Undo\nMade\nFT"
        case .missedFreeThrow: return "Undo\nMissed\nFT"
        case .turnover: return "Undo\nTO"
        case .foul: return "Undo\nFoul"
        case .rebound: return "Undo\nReb"
        case .assist: return "Undo\nAssist"
        case .steal: return "Undo\nSteal"
        case .block: return "Undo\nBlock"
        }
    }

    /// What VoiceOver reads
    var spokenName: String {
        switch self {
        case .madeTwo: return "Made 2 pointer"
        case .missedTwo: return "Missed 2 pointer"
        case .madeThree: return "Made 3 pointer"
        case .missedThree: return "Missed 3 pointer"
        case .madeFreeThrow: return "Made free throw"
        case .missedFreeThrow: return "Missed free throw"
        case .turnover: return "Turnover"
        case .foul: return "Foul"
        case .rebound: return "Rebound"
        case .assist: return "Assist"
        case .steal: return "Steal"
        case .block: return "Block"
        }
    }
}

/// One game's box score. The coding keys are the names earlier versions saved,
/// so a game in progress survives the update.
struct StatLine: Codable, Hashable {
    var points = 0
    var twoMade = 0, twoAttempted = 0
    var threeMade = 0, threeAttempted = 0
    var ftMade = 0, ftAttempted = 0
    var rebounds = 0, assists = 0, steals = 0, blocks = 0, turnovers = 0, fouls = 0

    static let maxFouls = 5

    enum CodingKeys: String, CodingKey {
        case points = "totalPoints"
        case twoMade = "twoPointersMade", twoAttempted = "twoPointersAttempted"
        case threeMade = "threePointersMade", threeAttempted = "threePointersAttempted"
        case ftMade = "freeThrowsMade", ftAttempted = "freeThrowsAttempted"
        case rebounds, assists, steals, blocks, turnovers, fouls
    }

    mutating func record(_ stat: Stat) {
        switch stat {
        case .madeTwo: twoMade += 1; twoAttempted += 1; points += 2
        case .missedTwo: twoAttempted += 1
        case .madeThree: threeMade += 1; threeAttempted += 1; points += 3
        case .missedThree: threeAttempted += 1
        case .madeFreeThrow: ftMade += 1; ftAttempted += 1; points += 1
        case .missedFreeThrow: ftAttempted += 1
        case .turnover: turnovers += 1
        case .foul: if fouls < Self.maxFouls { fouls += 1 }  // fouled out
        case .rebound: rebounds += 1
        case .assist: assists += 1
        case .steal: steals += 1
        case .block: blocks += 1
        }
    }

    /// Takes back one of `stat`, never going below zero (and a miss can't remove a make).
    mutating func undo(_ stat: Stat) {
        switch stat {
        case .madeTwo: if twoMade > 0 { twoMade -= 1; twoAttempted -= 1; points -= 2 }
        case .missedTwo: if twoAttempted > twoMade { twoAttempted -= 1 }
        case .madeThree: if threeMade > 0 { threeMade -= 1; threeAttempted -= 1; points -= 3 }
        case .missedThree: if threeAttempted > threeMade { threeAttempted -= 1 }
        case .madeFreeThrow: if ftMade > 0 { ftMade -= 1; ftAttempted -= 1; points -= 1 }
        case .missedFreeThrow: if ftAttempted > ftMade { ftAttempted -= 1 }
        case .turnover: turnovers = max(0, turnovers - 1)
        case .foul: fouls = max(0, fouls - 1)
        case .rebound: rebounds = max(0, rebounds - 1)
        case .assist: assists = max(0, assists - 1)
        case .steal: steals = max(0, steals - 1)
        case .block: blocks = max(0, blocks - 1)
        }
    }
}

@Observable
final class Game {
    var line = StatLine()

    static let savedStatsKey = "savedStats"

    /// The stats from when the app last closed, or a fresh game.
    static func loadSaved() -> Game {
        let game = Game()
        if let data = UserDefaults.standard.data(forKey: savedStatsKey),
           let line = try? JSONDecoder().decode(StatLine.self, from: data) {
            game.line = line
        }
        return game
    }

    func save() {
        if let data = try? JSONEncoder().encode(line) {
            UserDefaults.standard.set(data, forKey: Game.savedStatsKey)
        }
    }

    func record(_ stat: Stat) { line.record(stat) }
    func undo(_ stat: Stat) { line.undo(stat) }

    func reset() {
        line = StatLine()
        save()
    }
}
