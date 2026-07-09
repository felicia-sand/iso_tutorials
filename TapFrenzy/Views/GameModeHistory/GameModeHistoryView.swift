import SwiftUI
import Charts

struct GameModeHistoryView: View {
    let mode: GameMode
    let store: SessionStore

    private var modeSessions: [GameSession] {
        store.sessions(for: mode)
    }

    private var bestScore: Int {
        store.bestScore(for: mode)
    }

    private var averageScore: Double {
        guard !modeSessions.isEmpty else { return 0 }
        let total = modeSessions.reduce(0) { $0 + $1.score }
        return Double(total) / Double(modeSessions.count)
    }

    private var chartData: [GameSession] {
        modeSessions.sorted { $0.timestamp < $1.timestamp }
    }

    var body: some View {
        List {
            Section("Overview") {
                LabeledContent("Games played", value: "\(modeSessions.count)")
                LabeledContent("Best score", value: "\(bestScore)")
                
            }

            if !chartData.isEmpty {
                Section("Score progression") {
                    Chart(chartData) { session in
                        LineMark(
                            x: .value("Date", session.timestamp),
                            y: .value("Score", session.score)
                        )
                        .symbol(.circle)

                        PointMark(
                            x: .value("Date", session.timestamp),
                            y: .value("Score", session.score)
                        )
                    }
                    .frame(height: 200)
                }
            }

            Section("All games") {
                if modeSessions.isEmpty {
                    Text("No games played yet.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(modeSessions) { session in
                        NavigationLink {
                            GameSessionDetailView(session: session)
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(session.timestamp.formatted(date: .abbreviated, time: .shortened))
                                        .font(.subheadline)
                                    if session.score == bestScore {
                                        Text("Personal best")
                                            .font(.caption)
                                            .foregroundStyle(.orange)
                                    }
                                }
                                Spacer()
                                ScoreBadge(score: session.score)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(mode.displayName)
        .navigationBarTitleDisplayMode(.inline)
    }
}
