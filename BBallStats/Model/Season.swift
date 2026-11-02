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
    private(set) var currentPlayerID: UUID? {
        didSet { UserDefaults.standard.set(currentPlayerID?.uuidString, forKey: "currentPlayerID") }
    }
    /// Each player's game in progress while another player is on screen
    private var liveGames: [UUID: StatLine] = [:]
    /// Player → saved game they resumed; ending that game updates it instead of adding a new one
    private(set) var resumed: [UUID: UUID] = [:]

    private struct Saved: Codable {
        var players: [Player]
        var games: [GameRecord]
        var liveGames: [UUID: StatLine]? = nil   // added in 1.5; older files don't have them
        var resumed: [UUID: UUID]? = nil
    }
    private let url = URL.applicationSupportDirectory.appending(path: "season.json")

    private init() {
        if let data = try? Data(contentsOf: url), let saved = try? JSONDecoder().decode(Saved.self, from: data) {
            players = saved.players
            games = saved.games
            liveGames = saved.liveGames ?? [:]
            resumed = saved.resumed ?? [:]
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

    /// Puts `id` on screen: parks the current player's game in progress and brings back theirs.
    func switchTo(_ id: UUID, game: Game) {
        guard id != currentPlayerID, players.contains(where: { $0.id == id }) else { return }
        if let current = currentPlayerID { liveGames[current] = game.line }
        currentPlayerID = id
        game.line = liveGames.removeValue(forKey: id) ?? StatLine()
        game.save()
        save()
    }

    /// Removes the player, their saved games and their game in progress.
    func delete(_ player: Player, game: Game) {
        if currentPlayerID == player.id, let next = players.first(where: { $0.id != player.id }) {
            switchTo(next.id, game: game)
        }
        players.removeAll { $0.id == player.id }
        games.removeAll { $0.playerID == player.id }
        liveGames[player.id] = nil
        resumed[player.id] = nil
        if currentPlayerID == player.id { currentPlayerID = nil }
        save()
    }

    /// Ends a player's game: saves it to their season, or updates the saved game they resumed.
    func record(_ line: StatLine, opponent: String, for playerID: UUID) {
        store(line, opponent: opponent, for: playerID, date: .now)
        save()
    }

    private func store(_ line: StatLine, opponent: String, for playerID: UUID, date: Date) {
        let opponent = opponent.trimmingCharacters(in: .whitespaces)
        if let id = resumed.removeValue(forKey: playerID), let i = games.firstIndex(where: { $0.id == id }) {
            games[i].line = line
            games[i].opponent = opponent
        } else {
            games.append(GameRecord(playerID: playerID, date: date, opponent: opponent, line: line))
        }
    }

    /// The saved game the player on screen resumed, if any
    var resumedGame: GameRecord? {
        currentPlayerID.flatMap { resumed[$0] }.flatMap { id in games.first { $0.id == id } }
    }

    /// Puts a saved game back on the main screen to keep tracking. A game the player
    /// already had in progress is saved to their season first, so nothing is lost.
    func resume(_ record: GameRecord, game: Game) {
        if currentPlayerID != record.playerID { switchTo(record.playerID, game: game) }
        if game.line != StatLine() { store(game.line, opponent: "", for: record.playerID, date: .now) }
        game.line = record.line
        resumed[record.playerID] = record.id
        game.save()
        save()
    }

    /// Saves corrections to a finished game.
    func update(_ record: GameRecord) {
        guard let i = games.firstIndex(where: { $0.id == record.id }) else { return }
        games[i] = record
        save()
    }

    /// Players other than the one on screen who have a game in progress
    var playersWithLiveGames: [Player] { players.filter { hasLiveGame($0.id) } }

    /// A paused player's game in progress (the on-screen player's is the Game itself)
    func liveGame(for playerID: UUID) -> StatLine? { liveGames[playerID] }

    /// Ends the game for the chosen players: saves each one's stats (updating a resumed game)
    /// and clears their game in progress. Players not chosen keep theirs.
    func endGame(saving ids: Set<UUID>, onScreen line: StatLine, opponent: String) {
        let date = Date.now
        for id in ids {
            let stats = id == currentPlayerID ? line : liveGames[id]
            if let stats { store(stats, opponent: opponent, for: id, date: date) }
            liveGames[id] = nil
        }
        save()
    }

    /// Throws away the chosen players' games in progress (resumed games stay as they were saved).
    func discardGames(_ ids: Set<UUID>) {
        for id in ids {
            liveGames[id] = nil
            resumed[id] = nil
        }
        save()
    }

    /// True when a player other than the one on screen has a game in progress
    func hasLiveGame(_ playerID: UUID) -> Bool {
        playerID != currentPlayerID && liveGames[playerID].map { $0 != StatLine() } == true
    }

    func delete(_ game: GameRecord) {
        games.removeAll { $0.id == game.id }
        resumed = resumed.filter { $0.value != game.id }
        save()
    }

    private func save() {
        try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try? JSONEncoder().encode(Saved(players: players, games: games, liveGames: liveGames, resumed: resumed))
            .write(to: url, options: [.atomic, .completeFileProtection])
    }

    #if DEBUG
    /// A mid-season sample for App Store screenshots
    private func seedDemo() {
        let ava = Player(name: "Ava")
        let jack = Player(name: "Jack")
        players = [ava, jack] + ["Mia", "Leo", "Zoe", "Sam"].map { Player(name: $0) }
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
