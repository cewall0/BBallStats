//
//  Season.swift
//  BBaller Stats
//
//  BBaller+: players and saved games, kept in a JSON file on the device.
//

import Foundation
import Observation

extension StatLine {
    var fieldGoalsMade: Int { twoMade + threeMade }
    var fieldGoalsAttempted: Int { twoAttempted + threeAttempted }

    /// "14 pts, 6 reb, 3 ast" – the stats worth mentioning, points always first.
    var summary: String {
        var parts = ["\(points) pts"]
        for (value, name) in [(rebounds, "reb"), (assists, "ast"), (steals, "stl"), (blocks, "blk")] where value > 0 {
            parts.append("\(value) \(name)")
        }
        return parts.joined(separator: ", ")
    }

    var shooting: String {
        "FG \(fieldGoalsMade)-\(fieldGoalsAttempted) · 3P \(threeMade)-\(threeAttempted) · FT \(ftMade)-\(ftAttempted)"
    }
}

struct Player: Codable, Identifiable, Hashable {
    var id = UUID()
    var name: String
}

struct GameRecord: Codable, Identifiable, Hashable {
    var id = UUID()
    var playerID: UUID
    var date: Date
    var opponent: String
    var line: StatLine
}

/// Per-game averages and shooting percentages over a set of games.
struct SeasonAverages {
    let games: Int
    let points, rebounds, assists, steals, blocks, turnovers: Double
    let fieldGoalPct, threePct, freeThrowPct: Double?

    init(_ lines: [StatLine]) {
        games = lines.count
        func avg(_ value: (StatLine) -> Int) -> Double {
            lines.isEmpty ? 0 : Double(lines.map(value).reduce(0, +)) / Double(lines.count)
        }
        func pct(_ made: (StatLine) -> Int, _ attempted: (StatLine) -> Int) -> Double? {
            let a = lines.map(attempted).reduce(0, +)
            return a == 0 ? nil : Double(lines.map(made).reduce(0, +)) / Double(a)
        }
        points = avg(\.points); rebounds = avg(\.rebounds); assists = avg(\.assists)
        steals = avg(\.steals); blocks = avg(\.blocks); turnovers = avg(\.turnovers)
        fieldGoalPct = pct(\.fieldGoalsMade, \.fieldGoalsAttempted)
        threePct = pct(\.threeMade, \.threeAttempted)
        freeThrowPct = pct(\.ftMade, \.ftAttempted)
    }
}

@Observable
final class SeasonStore {
    static let shared = SeasonStore()

    private(set) var players: [Player] = []
    private(set) var games: [GameRecord] = []
    var currentPlayerID: UUID? {
        didSet { UserDefaults.standard.set(currentPlayerID?.uuidString, forKey: "currentPlayerID") }
    }

    private struct Saved: Codable { var players: [Player]; var games: [GameRecord] }
    private let url = URL.applicationSupportDirectory.appending(path: "season.json")

    private init() {
        if let data = try? Data(contentsOf: url), let saved = try? JSONDecoder().decode(Saved.self, from: data) {
            players = saved.players
            games = saved.games
        }
        #if DEBUG
        if CommandLine.arguments.contains("-seedDemoSeason") { seedDemo() }
        #endif
        let stored = UserDefaults.standard.string(forKey: "currentPlayerID").flatMap(UUID.init)
        currentPlayerID = players.first(where: { $0.id == stored })?.id ?? players.first?.id
    }

    var currentPlayer: Player? { players.first { $0.id == currentPlayerID } }

    func games(for playerID: UUID?) -> [GameRecord] {
        games.filter { $0.playerID == playerID }.sorted { $0.date > $1.date }
    }

    @discardableResult
    func addPlayer(named name: String) -> Player {
        let player = Player(name: name.trimmingCharacters(in: .whitespaces))
        players.append(player)
        if currentPlayerID == nil { currentPlayerID = player.id }
        save()
        return player
    }

    func rename(_ player: Player, to name: String) {
        guard let i = players.firstIndex(of: player) else { return }
        players[i].name = name.trimmingCharacters(in: .whitespaces)
        save()
    }

    /// Removes the player and all of their saved games.
    func delete(_ player: Player) {
        players.removeAll { $0.id == player.id }
        games.removeAll { $0.playerID == player.id }
        if currentPlayerID == player.id { currentPlayerID = players.first?.id }
        save()
    }

    func record(_ line: StatLine, opponent: String, for playerID: UUID) {
        games.append(GameRecord(playerID: playerID, date: .now, opponent: opponent.trimmingCharacters(in: .whitespaces), line: line))
        save()
    }

    func delete(_ game: GameRecord) {
        games.removeAll { $0.id == game.id }
        save()
    }

    private func save() {
        try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try? JSONEncoder().encode(Saved(players: players, games: games)).write(to: url, options: [.atomic, .completeFileProtection])
    }

    #if DEBUG
    /// A mid-season sample for App Store screenshots
    private func seedDemo() {
        let ava = Player(name: "Ava")
        let jack = Player(name: "Jack")
        players = [ava, jack]
        let opponents = ["Eagles", "Wildcats", "Hornets", "Tigers", "Panthers", "Rockets", "Falcons", "Bulldogs"]
        let points = [8, 12, 6, 14, 11, 16, 13, 18]
        games = opponents.enumerated().map { i, opp in
            let p = points[i]
            let threes = i % 3, fts = (i + 1) % 3
            let twos = (p - threes * 3 - fts) / 2
            let line = StatLine(points: twos * 2 + threes * 3 + fts, twoMade: twos, twoAttempted: twos + 3 + i % 2,
                                threeMade: threes, threeAttempted: threes + 2, ftMade: fts, ftAttempted: fts + 1,
                                rebounds: 3 + i % 4, assists: 2 + i % 3, steals: 1 + i % 2, blocks: i % 2, turnovers: 2 - i % 2, fouls: 2)
            return GameRecord(playerID: ava.id, date: Calendar.current.date(byAdding: .day, value: (i - opponents.count) * 4, to: .now)!,
                              opponent: opp, line: line)
        }
        currentPlayerID = ava.id
    }
    #endif
}
