//
//  SeasonView.swift
//  BBaller Stats
//
//  BBaller+: season averages, trend chart, saved games and share cards.
//

import SwiftUI
import Charts

struct SeasonView: View {
    private let season = SeasonStore.shared
    @State private var metric: Metric = .points
    @State private var showPlayers = false

    enum Metric: String, CaseIterable, Identifiable {
        case points = "PTS", rebounds = "REB", assists = "AST", fieldGoal = "FG%"
        var id: String { rawValue }

        func value(_ line: StatLine) -> Double? {
            switch self {
            case .points: return Double(line.points)
            case .rebounds: return Double(line.rebounds)
            case .assists: return Double(line.assists)
            case .fieldGoal:
                return line.fieldGoalsAttempted == 0 ? nil : 100 * Double(line.fieldGoalsMade) / Double(line.fieldGoalsAttempted)
            }
        }
    }

    private var games: [GameRecord] { season.games(for: season.currentPlayerID) }

    var body: some View {
        List {
            Section {
                PlayerMenu(showPlayers: $showPlayers)
            }

            if season.players.isEmpty {
                Section {
                    Text("Add a player to start saving games to their season.")
                    Button("Add a player") { showPlayers = true }
                }
            } else if games.isEmpty {
                Section {
                    Text("No saved games yet. When a game ends, tap Reset and choose **Save game** to add it here.")
                }
            } else {
                Section("Season averages · \(games.count) game\(games.count == 1 ? "" : "s")") {
                    AveragesGrid(averages: SeasonAverages(games.map(\.line)))
                }

                if games.count > 1 {
                    Section {
                        Picker("Stat", selection: $metric) {
                            ForEach(Metric.allCases) { Text($0.rawValue).tag($0) }
                        }
                        .pickerStyle(.segmented)
                        TrendChart(games: games.reversed(), metric: metric)
                            .frame(height: 180)
                    } header: {
                        Text("Trend")
                    }
                }

                Section("Games") {
                    ForEach(games) { game in
                        NavigationLink {
                            GameDetailView(game: game, playerName: season.currentPlayer?.name ?? "")
                        } label: {
                            GameRow(game: game)
                        }
                    }
                    .onDelete { offsets in
                        offsets.map { games[$0] }.forEach(season.delete)
                    }
                }
            }
        }
        .navigationTitle("Season")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPlayers) { PlayersView() }
    }
}

/// Shows the current player; switches players or opens player management.
struct PlayerMenu: View {
    private let season = SeasonStore.shared
    @Binding var showPlayers: Bool

    var body: some View {
        Menu {
            ForEach(season.players) { player in
                Button {
                    season.currentPlayerID = player.id
                } label: {
                    if player.id == season.currentPlayerID { Label(player.name, systemImage: "checkmark") } else { Text(player.name) }
                }
            }
            Divider()
            Button("Manage players…", systemImage: "person.2") { showPlayers = true }
        } label: {
            HStack {
                Image(systemName: "person.crop.circle.fill").font(.title2)
                Text(season.currentPlayer?.name ?? "No player")
                    .font(.title3.bold())
                Spacer()
                Image(systemName: "chevron.up.chevron.down").foregroundStyle(.secondary)
            }
        }
        .accessibilityLabel("Player: \(season.currentPlayer?.name ?? "none"). Change player")
    }
}

private struct AveragesGrid: View {
    let averages: SeasonAverages

    var body: some View {
        Grid(horizontalSpacing: 12, verticalSpacing: 12) {
            GridRow {
                tile("PPG", averages.points)
                tile("RPG", averages.rebounds)
                tile("APG", averages.assists)
            }
            GridRow {
                tile("SPG", averages.steals)
                tile("BPG", averages.blocks)
                tile("TOPG", averages.turnovers)
            }
            GridRow {
                pct("FG%", averages.fieldGoalPct)
                pct("3P%", averages.threePct)
                pct("FT%", averages.freeThrowPct)
            }
        }
        .padding(.vertical, 4)
    }

    private func tile(_ label: String, _ value: Double) -> some View {
        cell(label, String(format: "%.1f", value))
    }

    private func pct(_ label: String, _ value: Double?) -> some View {
        cell(label, value.map { String(format: "%.0f%%", $0 * 100) } ?? "–")
    }

    private func cell(_ label: String, _ value: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.title2.bold().monospacedDigit())
            Text(label).font(.caption.bold()).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}

private struct TrendChart: View {
    let games: [GameRecord]   // oldest first
    let metric: SeasonView.Metric

    var body: some View {
        let points = games.enumerated().compactMap { i, g in metric.value(g.line).map { (i + 1, $0, g) } }
        Chart {
            ForEach(points, id: \.0) { n, value, _ in
                LineMark(x: .value("Game", n), y: .value(metric.rawValue, value))
                    .foregroundStyle(.orange)
                PointMark(x: .value("Game", n), y: .value(metric.rawValue, value))
                    .foregroundStyle(.orange)
            }
            if let avg = average(points.map(\.1)) {
                RuleMark(y: .value("Average", avg))
                    .foregroundStyle(.secondary)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .annotation(position: .top, alignment: .leading) {
                        Text("avg \(String(format: "%.1f", avg))").font(.caption2).foregroundStyle(.secondary)
                    }
            }
        }
        .chartXAxisLabel("Game")
        .chartXAxis { AxisMarks(values: .automatic(desiredCount: min(games.count, 8))) }
        .accessibilityLabel("\(metric.rawValue) by game")
    }

    private func average(_ values: [Double]) -> Double? {
        values.isEmpty ? nil : values.reduce(0, +) / Double(values.count)
    }
}

private struct GameRow: View {
    let game: GameRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Text(game.opponent.isEmpty ? "Game" : "vs \(game.opponent)").font(.headline)
                Spacer()
                Text(game.date.formatted(date: .abbreviated, time: .omitted)).font(.subheadline).foregroundStyle(.secondary)
            }
            Text(game.line.summary).font(.subheadline)
        }
        .accessibilityElement(children: .combine)
    }
}

struct GameDetailView: View {
    let game: GameRecord
    let playerName: String

    var body: some View {
        List {
            Section {
                ShareCard(game: game, playerName: playerName)
                    .listRowInsets(EdgeInsets())
            }
            Section("Box score") {
                row("Points", "\(game.line.points)")
                row("2-pointers", "\(game.line.twoMade)-\(game.line.twoAttempted)")
                row("3-pointers", "\(game.line.threeMade)-\(game.line.threeAttempted)")
                row("Free throws", "\(game.line.ftMade)-\(game.line.ftAttempted)")
                row("Rebounds", "\(game.line.rebounds)")
                row("Assists", "\(game.line.assists)")
                row("Steals", "\(game.line.steals)")
                row("Blocks", "\(game.line.blocks)")
                row("Turnovers", "\(game.line.turnovers)")
                row("Fouls", "\(game.line.fouls)")
            }
        }
        .navigationTitle(game.opponent.isEmpty ? "Game" : "vs \(game.opponent)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if let image = ShareCard.render(game: game, playerName: playerName) {
                    ShareLink(item: image, preview: SharePreview("\(playerName) – \(game.line.summary)", image: image)) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                }
            }
        }
    }

    private func row(_ label: String, _ value: String) -> some View {
        LabeledContent(label, value: value).monospacedDigit()
    }
}

/// The image people text to family: player, opponent, date and the stat line.
struct ShareCard: View {
    let game: GameRecord
    let playerName: String

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: "basketball.fill").foregroundStyle(.orange)
                Text(playerName).font(.title2.bold())
                Spacer()
                Text(game.date.formatted(date: .abbreviated, time: .omitted)).font(.subheadline)
            }
            if !game.opponent.isEmpty {
                Text("vs \(game.opponent)").font(.headline).frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("\(game.line.points)").font(.system(size: 64, weight: .heavy, design: .rounded))
                Text("PTS").font(.title3.bold())
                Spacer()
            }
            HStack {
                stat(game.line.rebounds, "REB"); stat(game.line.assists, "AST")
                stat(game.line.steals, "STL"); stat(game.line.blocks, "BLK")
            }
            Text(game.line.shooting).font(.footnote.monospacedDigit()).frame(maxWidth: .infinity, alignment: .leading)
            Text("Tracked with My BBaller Stats").font(.caption2).opacity(0.8).frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(18)
        .foregroundStyle(.white)
        .background(LinearGradient(colors: [Color(red: 0.0, green: 0.39, blue: 0.0), Color(red: 0.0, green: 0.25, blue: 0.1)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing))
        .accessibilityElement(children: .combine)
    }

    private func stat(_ value: Int, _ label: String) -> some View {
        VStack(spacing: 0) {
            Text("\(value)").font(.title2.bold().monospacedDigit())
            Text(label).font(.caption.bold())
        }
        .frame(maxWidth: .infinity)
    }

    @MainActor
    static func render(game: GameRecord, playerName: String) -> Image? {
        let renderer = ImageRenderer(content: ShareCard(game: game, playerName: playerName).frame(width: 360))
        renderer.scale = 3
        return renderer.uiImage.map { Image(uiImage: $0) }
    }
}

struct PlayersView: View {
    private let season = SeasonStore.shared
    @Environment(\.dismiss) private var dismiss
    @State private var newName = ""
    @State private var renaming: Player?
    @State private var renameText = ""
    @State private var deleting: Player?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        TextField("Player name", text: $newName)
                            .textContentType(.givenName)
                            .submitLabel(.done)
                            .onSubmit(add)
                        Button("Add", action: add)
                            .disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                } header: {
                    Text("Add a player")
                }
                if !season.players.isEmpty {
                    Section {
                        ForEach(season.players) { player in
                            Button {
                                season.currentPlayerID = player.id
                            } label: {
                                HStack {
                                    Text(player.name).foregroundStyle(.primary)
                                    Spacer()
                                    Text("\(season.games(for: player.id).count) games").foregroundStyle(.secondary)
                                    if player.id == season.currentPlayerID {
                                        Image(systemName: "checkmark").foregroundStyle(Color.accentColor)
                                    }
                                }
                            }
                            .swipeActions {
                                Button("Delete", role: .destructive) { deleting = player }
                                Button("Rename") { renameText = player.name; renaming = player }
                                    .tint(.blue)
                            }
                        }
                    } header: {
                        Text("Players")
                    } footer: {
                        Text("Tap a player to track them. Swipe to rename or delete.")
                    }
                }
            }
            .navigationTitle("Players")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
            .alert("Rename player", isPresented: Binding(get: { renaming != nil }, set: { if !$0 { renaming = nil } })) {
                TextField("Name", text: $renameText)
                Button("Save") { if let p = renaming, !renameText.trimmingCharacters(in: .whitespaces).isEmpty { season.rename(p, to: renameText) } }
                Button("Cancel", role: .cancel) {}
            }
            .confirmationDialog("Delete \(deleting?.name ?? "")?", isPresented: Binding(get: { deleting != nil }, set: { if !$0 { deleting = nil } }),
                                titleVisibility: .visible) {
                Button("Delete player and their games", role: .destructive) { if let p = deleting { season.delete(p) } }
            } message: {
                Text("This removes \(deleting.map { season.games(for: $0.id).count } ?? 0) saved games.")
            }
        }
    }

    private func add() {
        let name = newName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        let player = season.addPlayer(named: name)
        season.currentPlayerID = player.id
        newName = ""
    }
}
