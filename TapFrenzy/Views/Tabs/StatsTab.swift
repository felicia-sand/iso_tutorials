import SwiftUI
import Charts
struct StatsTab: View {
    private var store = SessionStore.shared

    var body: some View {
        List {
            Section("Overview") {
                LabeledContent("Total games played", value: "\(store.totalGamesPlayed)")
                
                ForEach(GameMode.allCases) { mode in
                    HStack {
                        // Your normal row content
                        LabeledContent("\(mode.displayName) best", value: "\(store.bestScore(for: mode))")
                        
                        // Explicitly add a blue chevron arrow
                        Image(systemName: "chevron.right")
                            .font(.footnote.weight(.semibold))
                            .foregroundColor(.blue)
                    }
                    .background(
                        // Invisible NavigationLink that handles the actual tap and transition
                        NavigationLink(destination: GameModeHistoryView(mode: mode, store: store)) {
                            EmptyView()
                        }
                        .opacity(0)
                    )
                }
            }


            Section("Scores by mode") {
                Chart(store.sessions) { session in
                    BarMark(
                        x: .value("Date", session.timestamp, unit: .day),
                        y: .value("Score", session.score)
                    )
                    .foregroundStyle(by: .value("Mode", session.mode.displayName))
                }
                .frame(height: 220)
            }
            
           
            Section("Recent games") {
                if store.recent.isEmpty {
                    Text("No games played yet.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(store.recent) { session in
                        HStack {
                            Label(session.mode.displayName, systemImage: session.mode.icon)
                            Spacer()
                            ScoreBadge(score: session.score)
                        }
                    }
                }
            }
        }
        .navigationTitle("Statistics")
    }
}
