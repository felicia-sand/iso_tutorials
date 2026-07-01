import SwiftUI

struct QuizRushView: View {
    @StateObject private var viewModel = QuizRushViewModel()
    @AppStorage("QuizRushHighScore") private var highScore = 0
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.15), Color.orange.opacity(0.15)]),
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            switch viewModel.viewState {
            case .loading:
                VStack(spacing: 15) {
                    ProgressView()
                        .scaleEffect(1.8)
                        .tint(.orange)
                    Text("Fetching Live Trivia...")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
            case .failed:
                VStack(spacing: 20) {
                    Image(systemName: "wifi.exclamationmark")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                    Text("Connection Failure")
                        .font(.title3.bold())
                    Text("Could not connect to Open Trivia DB.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button(action: {
                        Task { await viewModel.loadQuiz() }
                    }) {
                        Text("Retry Connection")
                            .bold()
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 180)
                            .background(Capsule().fill(Color.orange))
                    }
                }
                
            case .loaded:
                if !viewModel.isGameOver {
                    VStack(spacing: 20) {
                        // Game Status Header Row Data Tracker elements
                        HStack {
                            VStack(alignment: .leading) {
                                Text("SCORE")
                                    .font(.caption).bold().foregroundColor(.secondary)
                                Text("\(viewModel.score)")
                                    .font(.title2.bold())
                            }
                            Spacer()
                            if viewModel.streak >= 3 {
                                Text("🔥 \(viewModel.streak) Streak!")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.orange)
                                Spacer()
                            }
                            VStack(alignment: .trailing) {
                                Text("QUESTION")
                                    .font(.caption).bold().foregroundColor(.secondary)
                                Text("\(viewModel.currentQuestionIndex + 1) of 10")
                                    .font(.title2.bold())
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                        
                        // Question Card Section View Interface block
                        VStack {
                            Text(viewModel.questions[viewModel.currentQuestionIndex].question.decodedHTMLSymbols)
                                .font(.title3)
                                .fontWeight(.medium)
                                .multilineTextAlignment(.center)
                                .padding()
                        }
                        .frame(maxWidth: .infinity, minHeight: 160)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(viewModel.flashGreen ? Color.green.opacity(0.4) : (viewModel.shakeRed ? Color.red.opacity(0.4) : Color(.systemBackground).opacity(0.8)))
                        )
                        .offset(x: viewModel.shakeRed ? -10 : 0)
                        .padding(.horizontal)
                        
                        Spacer()
                        
                        // Dynamic 4 Buttons selection block grids layout
                        VStack(spacing: 12) {
                            ForEach(viewModel.shuffledAnswers, id: \.self) { answer in
                                Button(action: {
                                    viewModel.submitAnswer(answer, highScoreStorage: &highScore)
                                }) {
                                    Text(answer)
                                        .font(.body)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(RoundedRectangle(cornerRadius: 15).fill(Color(.systemBackground).opacity(0.6)))
                                        .shadow(color: Color.black.opacity(0.05), radius: 4)
                                }
                                .disabled(viewModel.flashGreen || viewModel.shakeRed)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    }
                } else {
                    // Quiz End Completion Game Over state visual cards interface layout
                    VStack(spacing: 25) {
                        Text("Quiz Completed!")
                            .font(.system(size: 40, weight: .black, design: .rounded))
                            .foregroundColor(.orange)
                        
                        VStack(spacing: 10) {
                            Text("Final Score")
                                .font(.headline).foregroundColor(.secondary)
                            Text("\(viewModel.score)")
                                .font(.system(size: 72, weight: .bold, design: .rounded))
                        }
                        .padding()
                        
                        if viewModel.score >= highScore && viewModel.score > 0 {
                            Text("🎉 HIGH SCORE!")
                                .font(.title3.bold())
                                .foregroundColor(.orange)
                        }
                        
                        Button(action: {
                            Task { await viewModel.loadQuiz() }
                        }) {
                            Text("Play Again")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 200)
                                .background(Capsule().fill(Color.orange))
                        }
                    }
                }
            }
        }
        .navigationTitle("Quiz Rush")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // Automatically invokes parsing loading execution context safely when rendering screen cleanly
            await viewModel.loadQuiz()
        }
    }
}
