import SwiftUI

enum QuizState {
    case loading
    case loaded
    case failed
}

@MainActor // Crucial modifier ensures all published visual properties refresh explicitly on the main thread
class QuizRushViewModel: ObservableObject {
    @Published var viewState: QuizState = .loading
    @Published var questions: [Question] = []
    @Published var currentQuestionIndex = 0
    @Published var score = 0
    @Published var streak = 0
    @Published var isGameOver = false
    @Published var shuffledAnswers: [String] = []
    
    // UI Feedback Helpers
    @Published var flashGreen = false
    @Published var shakeRed = false
    
    private let networkService = QuizNetworkService()
    
    func loadQuiz() async {
        viewState = .loading
        do {
            let fetchedQuestions = try await networkService.fetchQuestions()
            if fetchedQuestions.isEmpty {
                viewState = .failed
            } else {
                self.questions = fetchedQuestions
                self.currentQuestionIndex = 0
                self.score = 0
                self.streak = 0
                self.isGameOver = false
                prepareCurrentQuestion()
                viewState = .loaded
            }
        } catch {
            viewState = .failed
        }
    }
    
    func prepareCurrentQuestion() {
        guard currentQuestionIndex < questions.count else { return }
        shuffledAnswers = questions[currentQuestionIndex].allAnswers
    }
    
    func submitAnswer(_ answer: String, highScoreStorage: inout Int) {
        let currentQuestion = questions[currentQuestionIndex]
        let isCorrect = (answer == currentQuestion.correctAnswer.decodedHTMLSymbols)
        
        if isCorrect {
            streak += 1
            // Score tracking: base + bonus points based on matching consecutive win streaks
            let bonus = streak >= 3 ? 5 : 0
            score += 10 + bonus
            
            withAnimation(.easeInOut(duration: 0.2)) {
                flashGreen = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.flashGreen = false
                self.advanceQuestion(highScoreStorage: &highScoreStorage)
            }
        } else {
            streak = 0
            // Apply small penalty, but cap it at zero points
            score = max(0, score - 2)
            
            withAnimation(.default) {
                shakeRed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.shakeRed = false
                self.advanceQuestion(highScoreStorage: &highScoreStorage)
            }
        }
    }
    
    private func advanceQuestion(highScoreStorage: inout Int) {
        if currentQuestionIndex + 1 < questions.count {
            currentQuestionIndex += 1
            prepareCurrentQuestion()
        } else {
            isGameOver = true
            if score > highScoreStorage {
                highScoreStorage = score
            }
        }
    }
}
