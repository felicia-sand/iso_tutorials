import Foundation
import Combine

enum QuizState {
    case loading
    case loaded
    case failed(String)
    case finished
}


@MainActor
final class QuizViewModel: ObservableObject {
    @Published var state: QuizState = .loading
    @Published var questions: [TriviaQuestion] = []
    @Published var currentIndex = 0
    @Published var score = 0
    @Published var streak = 0
    @Published var currentAnswers: [String] = []
    @Published var selectedAnswer: String? = nil
    @Published var isCorrectSelection: Bool? = nil

    private let service = TriviaService()

    var currentQuestion: TriviaQuestion? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }

    var progressText: String {
        "\(min(currentIndex + 1, questions.count)) of \(questions.count)"
    }

   


    func load() async {
        state = .loading
        do {
            let fetched = try await service.fetchQuestions()
            questions = fetched
            currentIndex = 0
            score = 0
            streak = 0
            loadAnswersForCurrentQuestion()
            state = .loaded
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func retry() {
        Task { await load() }
    }

    func playAgain() {
        Task { await load() }
    }

    

    private func loadAnswersForCurrentQuestion() {
        guard let question = currentQuestion else { return }
        currentAnswers = question.shuffledAnswers
        selectedAnswer = nil
        isCorrectSelection = nil
    }

    func selectAnswer(_ answer: String) {
        // Ignore taps after the first one, or once the round is finished.
        guard selectedAnswer == nil, let question = currentQuestion else { return }

        selectedAnswer = answer
        let correct = answer == question.decodedCorrectAnswer
        isCorrectSelection = correct

        if correct {
            streak += 1
            let bonus = streak >= 3 ? 15 : 10 // small streak bonus
            score += bonus
        } else {
            streak = 0
            score = max(0, score - 5) // small penalty, never goes negative
        }

     
        Task {
            try? await Task.sleep(nanoseconds: 700_000_000)
            self.advance()
        }
    }

    private func advance() {
        if currentIndex + 1 < questions.count {
            currentIndex += 1
            loadAnswersForCurrentQuestion()
        } else {
            state = .finished
        }
    }
}

