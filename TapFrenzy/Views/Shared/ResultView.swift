import SwiftUI

struct ResultView: View {
    let mode: GameMode
    let score: Int
    var onPlayAgain: () -> Void

    private var shareText: String {
        "I just scored \(score) on \(mode.displayName) — beat that!"
    }

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: mode.icon)
                .font(.system(size: 48))
                .foregroundStyle(Color.accentColor)

            Text("\(mode.displayName) Complete")
                .font(.title2.bold())

            ScoreBadge(score: score)
                .scaleEffect(1.5)

            ShareLink(item: shareText) {
                Label("Share Score", systemImage: "square.and.arrow.up")
            }
            .buttonStyle(.bordered)

            Button("Play Again", action: onPlayAgain)
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .onAppear {
            LocationService.shared.requestLocation()
           
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                SessionStore.shared.record(
                    mode: mode,
                    score: score,
                    coordinate: LocationService.shared.currentLocation
                )
            }
        }
    }
}
