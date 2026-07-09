import SwiftUI
import Combine

struct TapFrenzyView: View {
    @State private var score = 0
    @State private var timeRemaining = 10
    @State private var isGameOver = false
    @AppStorage("TapFrenzyHighScore") private var highScore = 0
    
    @State private var buttonOffset = CGSize.zero
    @State private var hasRecordedThisRound = false

    let moveTimer = Timer.publish(every: 1.5, on: .main, in: .common).autoconnect()
    let gameTimer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                if !isGameOver {
                    VStack(spacing: 30) {
                        Text("TAP FRENZY")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .tracking(4)
                            .foregroundStyle(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing))
                            .multilineTextAlignment(.center)
                            .padding(.top, 20)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("SCORE")
                                    .font(.caption)
                                    .bold()
                                    .foregroundColor(.secondary)
                                Text("\(score)")
                                    .font(.system(size: 40, weight: .black, design: .rounded))
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("TIME LEFT")
                                    .font(.caption)
                                    .bold()
                                    .foregroundColor(.secondary)
                                Text("\(timeRemaining)s")
                                    .font(.system(size: 40, weight: .black, design: .rounded))
                                    .foregroundColor(timeRemaining <= 3 ? .red : .primary)
                            }
                        }
                        .padding(.horizontal, 30)
                        .padding(.top, 20)
                        
                        Spacer()
                        
                        Button(action: {
                            self.handleTap()
                        }) {
                            Text("TAP!")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(width: 120, height: 120)
                                .background(Circle().fill(Color.accentColor))
                                .shadow(radius: 10)
                        }
                        .scaleEffect(calculateButtonScale())
                        .offset(buttonOffset)
                        
                        Spacer()
                        
                        Text("High Score: \(highScore)")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 20)
                    }
                    .onReceive(gameTimer) { _ in
                        if timeRemaining > 0 {
                            timeRemaining -= 1
                        } else {
                            endGame()
                        }
                    }
                    .onReceive(moveTimer) { _ in
                        if !isGameOver {
                            moveButtonRandomly(in: geometry.size)
                        }
                    }
                    
                } else {
                    VStack(spacing: 25) {
                        Text("Game Over!")
                            .font(.system(size: 48, weight: .black, design: .rounded))
                            .foregroundColor(.red)
                        
                        VStack(spacing: 10) {
                            Text("Final Score")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("\(score)")
                                .font(.system(size: 72, weight: .bold, design: .rounded))
                        }
                        .padding()
                        
                        if score >= highScore && score > 0 {
                            Text("🎉 NEW HIGH SCORE!")
                                .font(.title3)
                                .bold()
                                .foregroundColor(.orange)
                        }
                        
                       
                        
                        Button(action: {
                            self.resetGame()
                        }) {
                            Text("Play Again")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 200)
                                .background(Capsule().fill(Color.green))
                                .shadow(radius: 5)
                        }
                        .padding(.top, 20)
                    }
                    .transition(.scale)
                }
            }
        }
        .navigationTitle("Tap Frenzy")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }
    
    private func handleTap() {
        score += 1
    }
    
    private func endGame() {
        isGameOver = true
        if score > highScore {
            highScore = score
        }

        guard !hasRecordedThisRound else { return }
        hasRecordedThisRound = true

        LocationService.shared.requestLocation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            SessionStore.shared.record(
                mode: .tapFrenzy,
                score: score,
                coordinate: LocationService.shared.currentLocation
            )
        }
    }
    
    private func resetGame() {
        score = 0
        timeRemaining = 10
        buttonOffset = .zero
        hasRecordedThisRound = false
        withAnimation {
            isGameOver = false
        }
    }
    
    private func moveButtonRandomly(in size: CGSize) {
        let maxX = size.width / 2 - 80
        let maxY = size.height / 3 - 80
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            buttonOffset = CGSize(
                width: CGFloat.random(in: -maxX...maxX),
                height: CGFloat.random(in: -maxY...maxY)
            )
        }
    }
    
    private func calculateButtonScale() -> CGFloat {
        let percentageLeft = CGFloat(timeRemaining) / 10.0
        return 0.4 + (percentageLeft * 0.6)
    }
}
