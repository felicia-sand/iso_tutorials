import SwiftUI

struct ScoreBadge: View {
    let score: Int

    var body: some View {
        Text("\(score)")
            .font(.headline)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Capsule().fill(Color.accentColor.opacity(0.15)))
            .foregroundStyle(Color.accentColor)
    }
}

