import Foundation
import Combine

final class StatsViewModel: ObservableObject {
    @Published private(set) var sessions: [GameSession] = []

    private let store: SessionStore
    private var cancellable: AnyCancellable?

    init(store: SessionStore = .shared) {
        self.store = store
        self.sessions = store.sessions
     
        refresh()
    }


    func refresh() {
        sessions = store.sessions
    }

    // Overview

    var totalGamesPlayed: Int {
        sessions.count
    }

    var totalScoreAcrossAllModes: Int {
        sessions.reduce(0) { $0 + $1.score }
    }

    func bestScore(for mode: GameMode) -> Int {
        sessions.filter { $0.mode == mode }.map(\.score).max() ?? 0
    }

    func gamesPlayed(for mode: GameMode) -> Int {
        sessions.filter { $0.mode == mode }.count
    }

    func averageScore(for mode: GameMode) -> Double {
        let modeSessions = sessions.filter { $0.mode == mode }
        guard !modeSessions.isEmpty else { return 0 }
        let total = modeSessions.reduce(0) { $0 + $1.score }
        return Double(total) / Double(modeSessions.count)
    }

    // Lists

    var recentSessions: [GameSession] {
        sessions.sorted { $0.timestamp > $1.timestamp }.prefix(10).map { $0 }
    }

    func sessions(for mode: GameMode) -> [GameSession] {
        sessions.filter { $0.mode == mode }.sorted { $0.timestamp > $1.timestamp }
    }

    // Chart data

   
    var chartData: [GameSession] {
        sessions.sorted { $0.timestamp < $1.timestamp }
    }

    // Actions

    func resetAllStats() {
        store.resetAll()
        refresh()
    }
}
