import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
}

class QuizNetworkService {
    func fetchQuestions() async throws -> [Question] {
        guard let url = URL(string: "https://opentdb.com/api.php?amount=10&type=multiple") else {
            throw NetworkError.invalidURL
        }
        
        // Native Swift concurrency syntax pulling data cleanly
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        do {
            let decodedResponse = try JSONDecoder().decode(TriviaResponse.self, from: data)
            return decodedResponse.results
        } catch {
            throw NetworkError.decodingError
        }
    }
}
