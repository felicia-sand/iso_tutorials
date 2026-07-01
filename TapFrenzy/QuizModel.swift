import Foundation

// The outer wrapper matching the API response
struct TriviaResponse: Codable {
    let results: [Question]
}

// The individual question object
struct Question: Codable, Identifiable {
    // Generate a unique ID since the API doesn't provide one
    var id: UUID { UUID() }
    
    let category: String
    let type: String
    let difficulty: String
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]
    
    // CodingKeys map the API's snake_case to Swift's camelCase
    enum CodingKeys: String, CodingKey {
        case category, type, difficulty, question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }
    
    // Helper property to combine and shuffle answers for the UI
    var allAnswers: [String] {
        var answers = incorrectAnswers
        answers.append(correctAnswer)
        return answers.shuffled()
    }
}

// String extension helper to automatically remove API strings' HTML escapes like &quot; or &#039;
extension String {
    var decodedHTMLSymbols: String {
        guard let data = self.data(using: .utf8) else { return self }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        if let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            return attributedString.string
        }
        return self
    }
}
