import Foundation
import CoreLocation
import Observation


@Observable
final class SessionStore {
    static let shared = SessionStore()

    private(set) var sessions: [GameSession] = []
    private let storageKey = "tapfrenzy.sessions.v1"

    private init() {
        load()
    }

    func record(mode: GameMode, score: Int, coordinate: CLLocationCoordinate2D?) {
        let session = GameSession(
            mode: mode,
            score: score,
            latitude: coordinate?.latitude ?? 0,
            longitude: coordinate?.longitude ?? 0
        )
        sessions.append(session)
        save()
    }

    func resetAll() {
        sessions.removeAll()
        save()
    }

 

    func sessions(for mode: GameMode) -> [GameSession] {
        sessions.filter { $0.mode == mode }.sorted { $0.timestamp > $1.timestamp }
    }

    func bestScore(for mode: GameMode) -> Int {
        sessions(for: mode).map(\.score).max() ?? 0
    }

    
    var totalGamesPlayed: Int { sessions.count }
    var recent: [GameSession] {
        sessions.sorted { $0.timestamp > $1.timestamp }.prefix(10).map { $0 }
    }



    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            sessions = try JSONDecoder().decode([GameSession].self, from: data)
        } catch {
            print("SessionStore load error: \(error)")
        }
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(sessions)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("SessionStore save error: \(error)")
        }
    }
}

