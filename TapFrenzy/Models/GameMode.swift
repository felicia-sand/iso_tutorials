import Foundation

enum GameMode: String, Codable, CaseIterable, Identifiable {
    case tapFrenzy
    case lightItUp
    case quizRush

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .tapFrenzy: return "Tap Frenzy"
        case .lightItUp: return "Light It Up"
        case .quizRush: return "Quiz Rush"
        }
    }

    var icon: String {
        switch self {
        case .tapFrenzy: return "bolt.fill"
        case .lightItUp: return "lightbulb.fill"
        case .quizRush: return "brain.head.profile"
        }
    }
}

