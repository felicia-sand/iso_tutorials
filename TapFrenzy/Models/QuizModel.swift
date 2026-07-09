import Foundation

// API Response Wrapper

struct TriviaResponse: Codable {
    let responseCode: Int
    let results: [TriviaQuestion]

    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case results
    }
}



struct TriviaQuestion: Codable, Identifiable {
    let id = UUID()
    let category: String
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]

   
    enum CodingKeys: String, CodingKey {
        case category
        case question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }

    var decodedQuestion: String { question.htmlDecoded }
    var decodedCorrectAnswer: String { correctAnswer.htmlDecoded }
    var decodedIncorrectAnswers: [String] { incorrectAnswers.map { $0.htmlDecoded } }

   
    var shuffledAnswers: [String] {
        (decodedIncorrectAnswers + [decodedCorrectAnswer]).shuffled()
    }
}

// HTML Entity Decoding
// opentdb.com encodes punctuation as HTML entities (e.g. &quot; &#039; &amp;)
// This gives us clean, readable strings without pulling in a big dependency.

extension String {
    var htmlDecoded: String {
        var result = self
        let entities: [String: String] = [
            "&quot;": "\"",
            "&#039;": "'",
            "&apos;": "'",
            "&amp;": "&",
            "&lt;": "<",
            "&gt;": ">",
            "&ldquo;": "\u{201C}",
            "&rdquo;": "\u{201D}",
            "&lsquo;": "\u{2018}",
            "&rsquo;": "\u{2019}",
            "&eacute;": "é",
            "&egrave;": "è",
            "&uuml;": "ü",
            "&ouml;": "ö",
            "&auml;": "ä",
            "&ntilde;": "ñ",
            "&hellip;": "…",
            "&mdash;": "—",
            "&ndash;": "–"
        ]
        for (entity, replacement) in entities {
            result = result.replacingOccurrences(of: entity, with: replacement)
        }
        return result
    }
}

