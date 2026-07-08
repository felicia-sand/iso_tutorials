import SwiftUI

struct ContentView: View {
    @AppStorage("TapFrenzyHighScore") private var tapFrenzyHighScore = 0

    @AppStorage("LightItUpHighScore") private var lightItUpHighScore = 0
    
    @AppStorage("QuizRushHighScore") private var quizRushHighScore = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.2)]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    VStack(spacing: 10) {
                        Text("Game Hub")
                            .font(.system(size: 40, weight: .black, design: .rounded))
                            .tracking(5)
                            .foregroundStyle(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing))
                        
                        Text("Pick one challenge")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .bold()
                    }
                    .padding(.top, 40)
                    
                    Spacer()
                        .frame(height: 50)
                    
                    VStack(spacing: 25) {
                        NavigationLink(destination: TapFrenzyView()) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Challenge 1")
                                    .font(.subheadline)
                                Text("TAP FRENZY")
                                    .font(.title2)
                                    .fontWeight(.heavy)
                                Text("High Score: \(tapFrenzyHighScore)")
                                    .font(.caption)
                                    .opacity(0.8)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 20).fill(LinearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing)))
                            .shadow(radius: 5)
                        }
                        
                        NavigationLink(destination: LightItUpView()) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Challenge 2")
                                    .font(.subheadline)
                                Text("LIGHT IT UP")
                                    .font(.title2)
                                    .fontWeight(.heavy)
                                Text("High Score: \(lightItUpHighScore)")
                                    .font(.caption)
                                    .opacity(0.8)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 20).fill(LinearGradient(colors: [.purple, .indigo], startPoint: .leading, endPoint: .trailing)))
                            .shadow(radius: 5)
                        }
                        
                        NavigationLink(destination: QuizRushView()) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Challenge 3")
                                    .font(.subheadline)
                                Text("QUIZ RUSH")
                                    .font(.title2)
                                    .fontWeight(.heavy)
                                Text("High Score: \(quizRushHighScore)")
                                    .font(.caption)
                                    .opacity(0.8)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 20).fill(LinearGradient(colors: [.green, .mint], startPoint: .leading, endPoint: .trailing)))
                            .shadow(radius: 5)
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                }
            }
           
        }
    }
}

#Preview {
    ContentView()
}
