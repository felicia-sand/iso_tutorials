import SwiftUI

struct QuizRushView: View {
    @StateObject private var viewModel = QuizViewModel()
    @AppStorage("QuizRushHighScore") private var highScore = 0
    @State private var hasRecordedThisRound = false

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.2), Color.mint.opacity(0.15)]),
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            switch viewModel.state {
            case .loading:
                loadingView
            case .failed(let message):
                errorView(message: message)
            case .loaded:
                quizView
            case .finished:
                finishedView
            }
        }
        .navigationTitle("Quiz Rush")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.load()
        }
        .toolbar(.hidden, for: .tabBar)
    }

    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Fetching questions...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 50))
                .foregroundColor(.red)
            Text("Something went wrong")
                .font(.title2.bold())
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            Button(action: { viewModel.retry() }) {
                Text("Retry")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 160)
                    .background(Capsule().fill(Color.green))
            }
        }
    }

    private var quizView: some View {
        VStack(spacing: 25) {
            HStack {
                VStack(alignment: .leading) {
                    Text("SCORE")
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                    Text("\(viewModel.score)")
                        .font(.title.bold())
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("STREAK")
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                    Text("\(viewModel.streak) 🔥")
                        .font(.title.bold())
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)

            Text(viewModel.progressText)
                .font(.subheadline.bold())
                .foregroundColor(.secondary)

            if let question = viewModel.currentQuestion {
                Text(question.decodedQuestion)
                    .font(.title3.bold())
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.7)))
                    .padding(.horizontal)

                VStack(spacing: 12) {
                    ForEach(viewModel.currentAnswers, id: \.self) { answer in
                        answerButton(answer, correctAnswer: question.decodedCorrectAnswer)
                    }
                }
                .padding(.horizontal)
            }

            Spacer()
        }
        .padding(.bottom, 20)
    }

    private func answerButton(_ answer: String, correctAnswer: String) -> some View {
        let isSelected = viewModel.selectedAnswer == answer
        let showCorrect = viewModel.selectedAnswer != nil && answer == correctAnswer
        let showWrong = isSelected && answer != correctAnswer

        return Button(action: {
            viewModel.selectAnswer(answer)
        }) {
            Text(answer)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(showCorrect ? Color.green : (showWrong ? Color.red : Color.blue.opacity(0.8)))
                )
                .scaleEffect(showWrong ? 0.97 : 1.0)
        }
        .disabled(viewModel.selectedAnswer != nil)
        .animation(.easeInOut(duration: 0.2), value: viewModel.selectedAnswer)
    }

    private var shareText: String {
        "I just scored \(viewModel.score) on Quiz Rush — beat that!"
    }

    private var finishedView: some View {
        VStack(spacing: 25) {
            Text("Quiz Completed!")
                .font(.system(size: 40, weight: .black, design: .rounded))
                .foregroundColor(.green)

            VStack(spacing: 10) {
                Text("Final Score")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Text("\(viewModel.score)")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
            }
            .padding()

            if viewModel.score >= highScore && viewModel.score > 0 {
                Text("🎉 NEW HIGH SCORE!")
                    .font(.title3.bold())
                    .foregroundColor(.orange)
            }

            ShareLink(item: shareText) {
                Label("Share Score", systemImage: "square.and.arrow.up")
            }
            .buttonStyle(.bordered)

            Button(action: {
                hasRecordedThisRound = false
                viewModel.playAgain()
            }) {
                Text("Play Again")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 200)
                    .background(Capsule().fill(Color.green))
                    .shadow(radius: 5)
            }
        }
        .onAppear {
            if viewModel.score > highScore {
                highScore = viewModel.score
            }

            guard !hasRecordedThisRound else { return }
            hasRecordedThisRound = true

            LocationService.shared.requestLocation()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                SessionStore.shared.record(
                    mode: .quizRush,
                    score: viewModel.score,
                    coordinate: LocationService.shared.currentLocation
                )
            }
        }
    }
}

#Preview {
    QuizRushView()
}
