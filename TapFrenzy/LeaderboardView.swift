import SwiftUI

struct LeaderboardView: View {
    
    @AppStorage("TapFrenzyHighScore") private var tapFrenzyHighScore = 0
    @AppStorage("LightItUpHighScore") private var lightItUpHighScore = 0
    @AppStorage("QuizRushHighScore") private var quizRushHighScore = 0
    
    var body: some View {
        ZStack {
          
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.2)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 25) {
                
                VStack(spacing: 8) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom))
                        .shadow(color: .orange.opacity(0.3), radius: 10, x: 0, y: 5)
                        .padding(.top, 20)
                    
                    Text("HIGH SCORES")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .tracking(3)
                        .foregroundColor(.primary)
                }
                
             
                VStack(spacing: 20) {
                   
                    LeaderboardRow(
                        title: "TAP FRENZY",
                        score: tapFrenzyHighScore,
                        icon: "bolt.fill",
                        gradientColors: [.blue, .cyan]
                    )
                    
              
                    LeaderboardRow(
                        title: "LIGHT IT UP",
                        score: lightItUpHighScore,
                        icon: "lightbulb.fill",
                        gradientColors: [.purple, .indigo]
                    )
                    
                    LeaderboardRow(
                        title: "QUIZ RUSH",
                        score: quizRushHighScore,
                        icon: "bolt.horizontal.fill",
                        gradientColors: [.orange, .red]
                    )
                }
                .padding(.horizontal, 25)
                
                Spacer()
      
                Button(role: .destructive, action: resetAllScores) {
                    HStack {
                        Image(systemName: "trash.fill")
                        Text("Reset High Scores")
                            .fontWeight(.semibold)
                    }
                    .font(.subheadline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Capsule().fill(Color(.systemBackground).opacity(0.6)))
                    .shadow(color: Color.black.opacity(0.05), radius: 3)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 20)
            }
        }
        .navigationTitle("Leaderboard")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func resetAllScores() {
        tapFrenzyHighScore = 0
        lightItUpHighScore = 0
        quizRushHighScore = 0
    }
}

struct LeaderboardRow: View {
    let title: String
    let score: Int
    let icon: String
    let gradientColors: [Color]
    
    var body: some View {
        HStack(spacing: 15) {
            Circle()
                .fill(LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: icon)
                        .foregroundColor(.white)
                        .font(.title3.bold())
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
               // Text("Personal Best")
                    //.font(.caption)
                   // .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(score)")
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundColor(.primary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.systemBackground).opacity(0.7))
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

