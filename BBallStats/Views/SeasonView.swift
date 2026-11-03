//
//  SeasonView.swift
//  BBaller Stats
//
//  BBaller+: season averages, trend chart, saved games and share cards.
//

import SwiftUI
import Charts

struct SeasonView: View {
    @Environment(Game.self) private var game
    @Environment(\.returnToGame) private var returnToGame
    private let season = SeasonStore.shared
    @State private var tab: Tab = .players
    @State private var viewedPlayerID: UUID?
    @State private var metric: Metric = .points
    @State private var showPlayers = false

    enum Tab: String, CaseIterable, Identifiable {
        case players = "Players", games = "Games"
        var id: Self { self }
    }

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

    /// The player being browsed here; independent of who is being tracked on the main screen
    private var viewedID: UUID? { viewedPlayerID ?? season.currentPlayerID }
    private var games: [GameRecord] { season.games(for: viewedID) }

    var body: some View {
        List {
            Section {
                Picker("View", selection: $tab) {
                    ForEach(Tab.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }

            if season.players.isEmpty {
                Section {
                    Text("Add a player to start saving games to their season.")
                    Button("Add a player") { showPlayers = true }
                }
            } else if tab == .players {
                playersTab
            } else {
                gamesTab
            }
        }
        .navigationTitle("Season")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPlayers) { PlayersView() }
    }

    // MARK: Players: one player's season at a time, switched with name chips

    @ViewBuilder private var playersTab: some View {
        Section {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(season.players) { player in
                        let selected = player.id == viewedID
                        Button { viewedPlayerID = player.id } label: {
                            Text(player.name)
                                .font(.headline)
                                .padding(.horizontal, 14)
                                .frame(minWidth: 44, minHeight: 36)
                                .background(Capsule().fill(selected ? Color.brandOrange : Color.brandOrange.opacity(0.14)))
                                .foregroundStyle(selected ? Color.white : Color.brandOrange)
                        }
                        .buttonStyle(.plain)
                        .accessibilityAddTraits(selected ? .isSelected : [])
                    }
                    Button { showPlayers = true } label: {
                        Image(systemName: "person.2.fill")
                            .font(.headline)
                            .frame(minWidth: 44, minHeight: 36)
                            .background(Capsule().fill(Color.brandOrange.opacity(0.14)))
                            .foregroundStyle(Color.brandOrange)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Manage players")
                }
            }
            .listRowInsets(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
        }

        if viewedID == season.currentPlayerID, game.line != StatLine() {
            Section {
                Button { returnToGame() } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(season.resumedGame.map { "Resumed: " + ($0.opponent.isEmpty ? "game" : "vs \($0.opponent)") } ?? "Current game")
                                .font(.headline)
                            Text(game.line.summary).font(.subheadline)
                        }
                        .foregroundStyle(.primary)
                        Spacer()
                        Text("Back to game").font(.subheadline.bold()).foregroundStyle(Color.accentColor)
                    }
                }
                .tint(.primary)
            } header: {
                Text("In progress")
            } footer: {
                Text("Saved on this phone as you go. Tap End Game when it's over to add it to the season.")
            }
        }

        if games.isEmpty {
            Section {
                Text("No saved games yet. When a game ends, tap **End Game** and choose **Save & Start New Game** to add it here.")
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
                ForEach(games) { record in
                    NavigationLink {
                        GamePager(playerID: record.playerID, startID: record.id)
                    } label: {
                        GameRow(game: record)
                    }
                }
                .onDelete { offsets in
                    offsets.map { games[$0] }.forEach(season.delete)
                }
            }
        }
    }

    // MARK: Games: each game with every player tracked in it

    @ViewBuilder private var gamesTab: some View {
        let teamGames = season.teamGames
        if teamGames.isEmpty {
            Section {
                Text("No saved games yet. When a game ends, tap **End Game** and choose **Save & Start New Game** to add it here.")
            }
        } else {
            Section {
                ForEach(teamGames) { teamGame in
                    NavigationLink {
                        TeamGameView(teamGame: teamGame)
                    } label: {
                        VStack(alignment: .leading, spacing: 3) {
                            HStack {
                                Text(teamGame.opponent.isEmpty ? "Game" : "vs \(teamGame.opponent)").font(.headline)
                                Spacer()
                                Text(teamGame.date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.subheadline).foregroundStyle(.secondary)
                            }
                            Text(teamGame.records.map { "\(season.name(of: $0.playerID)) \($0.line.points)" }.joined(separator: " · "))
                                .font(.subheadline)
                                .lineLimit(2)
                        }
                        .accessibilityElement(children: .combine)
                    }
                }
            } header: {
                Text("\(teamGames.count) game\(teamGames.count == 1 ? "" : "s")")
            } footer: {
                Text("Tap a game to see every player's box score from it.")
            }
        }
    }
}

/// Every player's box score from one game.
struct TeamGameView: View {
    let teamGame: TeamGame
    private let season = SeasonStore.shared
    @Environment(\.dismiss) private var dismiss
    @State private var confirmDelete = false

    private var names: String {
        teamGame.records.map { season.name(of: $0.playerID) }.formatted(.list(type: .and))
    }

    var body: some View {
        List {
            Section {
                Grid(alignment: .trailing, horizontalSpacing: 10, verticalSpacing: 10) {
                    GridRow {
                        Text("Player").gridColumnAlignment(.leading)
                        Text("PTS"); Text("REB"); Text("AST"); Text("STL"); Text("BLK"); Text("FG")
                    }
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                    Divider()
                    ForEach(teamGame.records) { r in
                        GridRow {
                            Text(season.name(of: r.playerID)).font(.headline).lineLimit(1).gridColumnAlignment(.leading)
                            Text("\(r.line.points)").bold()
                            Text("\(r.line.rebounds)"); Text("\(r.line.assists)")
                            Text("\(r.line.steals)"); Text("\(r.line.blocks)")
                            Text("\(r.line.fieldGoalsMade)-\(r.line.fieldGoalsAttempted)")
                        }
                        .monospacedDigit()
                        .accessibilityElement(children: .combine)
                    }
                    if teamGame.records.count > 1 {
                        Divider()
                        GridRow {
                            Text("Team").font(.headline).gridColumnAlignment(.leading)
                            Text("\(teamGame.totalPoints)").bold()
                            Text("\(teamGame.records.map(\.line.rebounds).reduce(0, +))")
                            Text("\(teamGame.records.map(\.line.assists).reduce(0, +))")
                            Text("\(teamGame.records.map(\.line.steals).reduce(0, +))")
                            Text("\(teamGame.records.map(\.line.blocks).reduce(0, +))")
                            Text("\(teamGame.records.map(\.line.fieldGoalsMade).reduce(0, +))-\(teamGame.records.map(\.line.fieldGoalsAttempted).reduce(0, +))")
                        }
                        .monospacedDigit()
                        .accessibilityElement(children: .combine)
                    }
                }
                .padding(.vertical, 4)
            } header: {
                Text(teamGame.date.formatted(date: .complete, time: .omitted))
            }

            Section {
                ForEach(teamGame.records) { r in
                    NavigationLink {
                        GamePager(playerID: r.playerID, startID: r.id)
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(season.name(of: r.playerID)).font(.headline)
                            Text(r.line.summary).font(.subheadline)
                        }
                    }
                }
            } header: {
                Text("Players")
            } footer: {
                Text("Tap a player for their full box score, share card, edit and resume.")
            }

            Section {
                Button(teamGame.records.count > 1 ? "Delete Game for All Players" : "Delete Game", role: .destructive) {
                    confirmDelete = true
                }
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle(teamGame.opponent.isEmpty ? "Game" : "vs \(teamGame.opponent)")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Delete this game?", isPresented: $confirmDelete, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                teamGame.records.forEach(season.delete)
                dismiss()
            }
        } message: {
            Text("Removes this game from \(names)'s season. This can't be undone.")
        }
    }
}

/// A player's games, one per page: swipe left and right between them.
struct GamePager: View {
    let playerID: UUID
    @State private var selection: UUID
    @Environment(\.dismiss) private var dismiss
    private let season = SeasonStore.shared

    init(playerID: UUID, startID: UUID) {
        self.playerID = playerID
        _selection = State(initialValue: startID)
    }

    private var games: [GameRecord] { season.games(for: playerID) }   // newest first

    private var index: Int { games.firstIndex { $0.id == selection } ?? 0 }

    /// After a delete, show the next older game (or the newer one), or go back if none are left.
    private func deleted(_ record: GameRecord) {
        let remaining = games
        if remaining.isEmpty { dismiss(); return }
        selection = (remaining.first { $0.date < record.date } ?? remaining.last!).id
    }
    private var current: GameRecord? {
        season.games.first { $0.id == selection } ?? games.first { $0.id == selection }
    }

    var body: some View {
        TabView(selection: $selection) {
            ForEach(games) { record in
                GameDetailView(record: record, playerName: season.name(of: record.playerID)) { deleted(record) }
                    .tag(record.id)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .onAppear { if games.isEmpty { dismiss() } }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(current.map { $0.opponent.isEmpty ? "Game" : "vs \($0.opponent)" } ?? "Game")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if games.count > 1 {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 0) {
                        Text(current.map { $0.opponent.isEmpty ? "Game" : "vs \($0.opponent)" } ?? "Game").font(.headline)
                        Text("\(index + 1) of \(games.count) · swipe for more").font(.caption2).foregroundStyle(.secondary)
                    }
                    .accessibilityElement(children: .combine)
                }
            }
            ToolbarItem(placement: .primaryAction) {
                if let g = current, let image = ShareCard.render(game: g, playerName: season.name(of: g.playerID)) {
                    ShareLink(item: image, preview: SharePreview("\(season.name(of: g.playerID)) – \(g.line.summary)", image: image)) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                }
            }
        }
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
    let record: GameRecord
    let playerName: String
    var onDelete: () -> Void = {}
    @Environment(Game.self) private var game
    @Environment(\.returnToGame) private var returnToGame
    private let season = SeasonStore.shared
    @State private var editing = false
    @State private var confirmResume = false
    @State private var confirmDelete = false

    /// The saved version, so edits show immediately
    private var current: GameRecord { season.games.first { $0.id == record.id } ?? record }

    /// Whether this player already has stats on the board that resuming would set aside
    private var hasGameInProgress: Bool {
        record.playerID == season.currentPlayerID ? game.line != StatLine() : season.hasLiveGame(record.playerID)
    }

    var body: some View {
        let g = current
        List {
            Section {
                ShareCard(game: g, playerName: playerName)
                    .listRowInsets(EdgeInsets())
            }
            Section {
                Button {
                    if hasGameInProgress { confirmResume = true } else { resume() }
                } label: {
                    Label("Resume Game", systemImage: "play.circle.fill")
                }
                Button { editing = true } label: {
                    Label("Edit Game", systemImage: "pencil")
                }
            } footer: {
                Text("Resume puts this game back on the main screen to keep tracking; ending it again updates this game. Edit fixes any stat, the opponent or the date.")
            }
            Section {
                Button("Delete Game", role: .destructive) { confirmDelete = true }
                    .frame(maxWidth: .infinity)
            }
            Section("Box score") {
                row("Points", "\(g.line.points)")
                row("2-pointers", "\(g.line.twoMade)-\(g.line.twoAttempted)")
                row("3-pointers", "\(g.line.threeMade)-\(g.line.threeAttempted)")
                row("Free throws", "\(g.line.ftMade)-\(g.line.ftAttempted)")
                row("Rebounds", "\(g.line.rebounds)")
                row("Assists", "\(g.line.assists)")
                row("Steals", "\(g.line.steals)")
                row("Blocks", "\(g.line.blocks)")
                row("Turnovers", "\(g.line.turnovers)")
                row("Fouls", "\(g.line.fouls)")
            }
        }
        .sheet(isPresented: $editing) { GameEditView(record: g) }
        .confirmationDialog("Delete this game?", isPresented: $confirmDelete, titleVisibility: .visible) {
            Button("Delete Game", role: .destructive) {
                season.delete(current)
                onDelete()
            }
        } message: {
            Text("Removes \(playerName)'s game\(current.opponent.isEmpty ? "" : " vs \(current.opponent)") from the season. This can't be undone.")
        }
        .confirmationDialog("Resume this game?", isPresented: $confirmResume, titleVisibility: .visible) {
            Button("Save Current Game & Resume") { resume() }
        } message: {
            Text("\(playerName) has a game in progress. It will be saved to the season first, then this game goes back on the main screen.")
        }
    }

    private func resume() {
        season.resume(current, game: game)
        returnToGame()
    }

    private func row(_ label: String, _ value: String) -> some View {
        LabeledContent(label, value: value).monospacedDigit()
    }
}

/// Corrections to a finished game. Points follow from the makes.
struct GameEditView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var record: GameRecord

    init(record: GameRecord) { _record = State(initialValue: record) }

    var body: some View {
        NavigationStack {
            Form {
                Section("Game") {
                    TextField("Opponent", text: $record.opponent)
                    DatePicker("Date", selection: $record.date, displayedComponents: .date)
                }
                Section {
                    shots("2-pointers", made: $record.line.twoMade, attempted: $record.line.twoAttempted)
                    shots("3-pointers", made: $record.line.threeMade, attempted: $record.line.threeAttempted)
                    shots("Free throws", made: $record.line.ftMade, attempted: $record.line.ftAttempted)
                } header: {
                    Text("Shooting (made / attempted)")
                } footer: {
                    Text("Points: \(points)")
                }
                Section("Other stats") {
                    count("Rebounds", $record.line.rebounds)
                    count("Assists", $record.line.assists)
                    count("Steals", $record.line.steals)
                    count("Blocks", $record.line.blocks)
                    count("Turnovers", $record.line.turnovers)
                    count("Fouls", $record.line.fouls, max: StatLine.maxFouls)
                }
            }
            .navigationTitle("Edit Game")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        record.line.points = points
                        SeasonStore.shared.update(record)
                        dismiss()
                    }
                }
            }
        }
    }

    private var points: Int { record.line.twoMade * 2 + record.line.threeMade * 3 + record.line.ftMade }

    private func shots(_ label: String, made: Binding<Int>, attempted: Binding<Int>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.headline)
            // Keep made ≤ attempted whichever one changes
            Stepper("Made: \(made.wrappedValue)", value: Binding(get: { made.wrappedValue },
                                                              set: { made.wrappedValue = $0; attempted.wrappedValue = max(attempted.wrappedValue, $0) }),
                    in: 0...99)
            Stepper("Attempted: \(attempted.wrappedValue)", value: Binding(get: { attempted.wrappedValue },
                                                                        set: { attempted.wrappedValue = $0; made.wrappedValue = min(made.wrappedValue, $0) }),
                    in: 0...99)
        }
    }

    private func count(_ label: String, _ value: Binding<Int>, max: Int = 99) -> some View {
        Stepper("\(label): \(value.wrappedValue)", value: value, in: 0...max)
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
    @Environment(Game.self) private var game
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
                            HStack(spacing: 16) {
                                Button {
                                    season.switchTo(player.id, game: game)
                                } label: {
                                    HStack {
                                        Text(player.name).foregroundStyle(.primary)
                                        Spacer()
                                        Text("\(season.games(for: player.id).count) games").foregroundStyle(.secondary)
                                        if player.id == season.currentPlayerID {
                                            Image(systemName: "checkmark").foregroundStyle(Color.accentColor)
                                        }
                                    }
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.borderless)
                                .tint(.primary)
                                Button { renameText = player.name; renaming = player } label: {
                                    Image(systemName: "pencil").font(.body.bold())
                                }
                                .buttonStyle(.borderless)
                                .accessibilityLabel("Rename \(player.name)")
                            }
                            .swipeActions {
                                Button("Delete", role: .destructive) { deleting = player }
                                Button("Rename") { renameText = player.name; renaming = player }
                                    .tint(.blue)
                            }
                            .contextMenu {
                                Button("Rename", systemImage: "pencil") { renameText = player.name; renaming = player }
                                Button("Delete", systemImage: "trash", role: .destructive) { deleting = player }
                            }
                        }
                    } header: {
                        Text("Players")
                    } footer: {
                        Text("Tap a player to track them. Tap the pencil to rename. Press and hold a player (here or on the main screen) to rename or delete.")
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
                Button("Delete player and their games", role: .destructive) { if let p = deleting { season.delete(p, game: game) } }
            } message: {
                Text("This removes \(deleting.map { season.games(for: $0.id).count } ?? 0) saved games.")
            }
        }
    }

    private func add() {
        let name = newName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        let player = season.addPlayer(named: name)
        season.switchTo(player.id, game: game)
        newName = ""
    }
}

/// A player's name in a switch menu: checkmark for the player on screen, a dot for a paused game in progress.
struct PlayerMenuLabel: View {
    let player: Player
    private let season = SeasonStore.shared

    var body: some View {
        if player.id == season.currentPlayerID {
            Label(player.name, systemImage: "checkmark")
        } else if season.hasLiveGame(player.id) {
            Label("\(player.name) · game in progress", systemImage: "circle.fill")
        } else {
            Text(player.name)
        }
    }
}

/// Main-screen player control (BBaller+). With two or more players it is a row of name chips, so a parent
/// or coach tracking a whole team switches in one tap; each player keeps their own game in progress.
struct PlayerSwitcher: View {
    @Environment(Game.self) private var game
    private let season = SeasonStore.shared
    @State private var showPlayers = false
    @State private var renaming: Player?
    @State private var renameText = ""
    @State private var deleting: Player?
    let fontSize: CGFloat

    var body: some View {
        Group {
            if season.players.count >= 2 {
                chips
            } else {
                Button { showPlayers = true } label: {
                    chip(season.currentPlayer?.name ?? "Add player", icon: "person.crop.circle.fill", selected: true)
                }
                .contextMenu { if let player = season.currentPlayer { editMenu(player) } }
                .accessibilityLabel(season.currentPlayer.map { "Player: \($0.name). Add players" } ?? "Add a player")
            }
        }
        .sheet(isPresented: $showPlayers) { PlayersView() }
        .alert("Rename player", isPresented: Binding(get: { renaming != nil }, set: { if !$0 { renaming = nil } })) {
            TextField("Name", text: $renameText)
            Button("Save") {
                if let p = renaming, !renameText.trimmingCharacters(in: .whitespaces).isEmpty { season.rename(p, to: renameText) }
            }
            Button("Cancel", role: .cancel) {}
        }
        .confirmationDialog("Delete \(deleting?.name ?? "")?", isPresented: Binding(get: { deleting != nil }, set: { if !$0 { deleting = nil } }),
                            titleVisibility: .visible) {
            Button("Delete player and their games", role: .destructive) { if let p = deleting { season.delete(p, game: game) } }
        } message: {
            Text("This removes \(deleting.map { season.games(for: $0.id).count } ?? 0) saved games and any game in progress.")
        }
    }

    /// Long-press menu for a player chip
    @ViewBuilder private func editMenu(_ player: Player) -> some View {
        Button("Rename", systemImage: "pencil") { renameText = player.name; renaming = player }
        Button("Delete", systemImage: "trash", role: .destructive) { deleting = player }
        Divider()
        Button("Add or edit players…", systemImage: "person.badge.plus") { showPlayers = true }
    }

    private var chips: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(season.players) { player in
                        let selected = player.id == season.currentPlayerID
                        Button { season.switchTo(player.id, game: game) } label: {
                            chip(player.name, icon: season.hasLiveGame(player.id) ? "circle.fill" : nil, selected: selected)
                        }
                        .id(player.id)
                        .contextMenu { editMenu(player) }
                        .accessibilityLabel(player.name + (season.hasLiveGame(player.id) ? ", game in progress" : ""))
                        .accessibilityHint("Press and hold to rename or delete")
                        .accessibilityAddTraits(selected ? .isSelected : [])
                    }
                    Button { showPlayers = true } label: { chip("", icon: "plus", selected: false) }
                        .accessibilityLabel("Add or edit players")
                }
                .padding(.horizontal, 12)
            }
            .onAppear { proxy.scrollTo(season.currentPlayerID, anchor: .center) }
        }
    }

    private func chip(_ title: String, icon: String?, selected: Bool) -> some View {
        HStack(spacing: 5) {
            if let icon {
                Image(systemName: icon).font(.system(size: icon == "circle.fill" ? fontSize * 0.4 : fontSize * 0.85, weight: .bold))
            }
            if !title.isEmpty { Text(title).lineLimit(1) }
        }
        .font(.system(size: fontSize, weight: .bold))
        .padding(.horizontal, 14)
        .frame(minWidth: 44, minHeight: 40)
        .background(Capsule().fill(selected ? Color.brandOrange : Color.brandOrange.opacity(0.14)))
        .foregroundStyle(selected ? Color.white : Color.brandOrange)
    }
}
