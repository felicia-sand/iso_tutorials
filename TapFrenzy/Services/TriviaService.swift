import Foundation

enum TriviaError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingFailed
    case emptyResults

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The trivia URL was invalid."
        case .invalidResponse:
            return "The server returned an unexpected response."
        case .decodingFailed:
            return "Couldn't read the trivia data."
        case .emptyResults:
            return "No questions were returned. Please try again."
        }
    }
}

/// Talks to opentdb.com. Kept as a single-purpose struct so the ViewModel
/// doesn't need to know anything about URLSession or JSON.
struct TriviaService {
    private let urlString = "https://opentdb.com/api.php?amount=10&type=multiple"

    func fetchQuestions() async throws -> [TriviaQuestion] {
        guard let url = URL(string: urlString) else {
            throw TriviaError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw TriviaError.invalidResponse
        }

        do {
            let decoded = try JSONDecoder().decode(TriviaResponse.self, from: data)
            guard !decoded.results.isEmpty else {
                throw TriviaError.emptyResults
            }
            return decoded.results
        } catch let error as TriviaError {
            throw error
        } catch {
            throw TriviaError.decodingFailed
        }
    }
}

