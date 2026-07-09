import SwiftUI
import Combine

struct Card: Identifiable {
    let id = UUID()
    var isLit: Bool = false
}

enum GameLevel: Int, CaseIterable {
    case l1 = 1, l2, l3, l4
    
    var timeRange: ClosedRange<Int> {
        switch self {
        case .l1: return 45...60
        case .l2: return 30...45
        case .l3: return 15...30
        case .l4: return 0...15
        }
    }
    
    var cardCount: Int {
        switch self {
        case .l1: return 3
        case .l2: return 4
        case .l3: return 6
        case .l4: return 9
        }
    }
    
    var litDuration: Double {
        switch self {
        case .l1: return 1.5
        case .l2: return 1.2
        case .l3: return 1.0
        case .l4: return 0.8
        }
    }
    
    var glowColor: Color {
        switch self {
        case .l1: return .green
        case .l2: return .yellow
        case .l3: return .orange
        case .l4: return .red
        }
    }
    
    var columns: [GridItem] {
        switch self {
        case .l1, .l2:
            return Array(repeating: GridItem(.flexible(), spacing: 15), count: cardCount)
        case .l3:
            return Array(repeating: GridItem(.flexible(), spacing: 15), count: 3)
        case .l4:
            return Array(repeating: GridItem(.flexible(), spacing: 15), count: 3)
        }
    }
}

struct LightItUpView: View {
    @AppStorage("LightItUpHighScore") private var highScore = 0
    
    @State private var score = 0
    @State private var timeRemaining = 60
    @State private var isGameOver = false
    @State private var cards: [Card] = []
    @State private var currentLevel: GameLevel = .l1
    @State private var showLevelUpFlash = false
    @State private var lives = 3
    @State private var hasRecordedThisRound = false

    let roundTimer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    @State private var gameTickTimer = Timer.publish(every: 1.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.2), Color.black.opacity(0.05)]),
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            if !isGameOver {
                VStack(spacing: 20) {
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("LEVEL \(currentLevel.rawValue)")
                                .font(.title3.bold())
                                .foregroundColor(currentLevel.glowColor)
                            Text("Score: \(score)")
                                .font(.title2.bold())
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("⏱️ \(timeRemaining)s")
                                .font(.title2.bold())
                                .foregroundColor(timeRemaining <= 10 ? .red : .primary)
                            
                        
                            HStack(spacing: 3) {
                                ForEach(0..<3) { index in
                                    Image(systemName: index < lives ? "heart.fill" : "heart")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    ProgressView(value: Double(timeRemaining), total: 60)
                        .tint(currentLevel.glowColor)
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    
                    LazyVGrid(columns: currentLevel.columns, spacing: 15) {
                        ForEach(cards) { card in
                            RoundedRectangle(cornerRadius: 15)
                                .fill(card.isLit ? currentLevel.glowColor : Color.gray.opacity(0.3))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(card.isLit ? Color.white : Color.clear, lineWidth: 3)
                                )
                                .shadow(color: card.isLit ? currentLevel.glowColor.opacity(0.8) : .clear, radius: card.isLit ? 15 : 0)
                                .scaleEffect(card.isLit ? 1.05 : 1.0)
                                .frame(height: 100)
                                .onTapGesture {
                                    handleCardTap(card)
                                }
                        }
                    }
                    .padding(25)
                    
                    Spacer()
                }
                .onReceive(roundTimer) { _ in
                    updateRoundClock()
                }
                .onReceive(gameTickTimer) { _ in
                    lightUpRandomCards()
                }
                .onAppear {
                    setupLevel()
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
                            .font(.title3.bold())
                            .foregroundColor(.orange)
                    }
                    
                    Button(action: resetGame) {
                        Text("Play Again")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 200)
                            .background(Capsule().fill(Color.purple))
                    }
                }
            }
            
            
            if showLevelUpFlash {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                Text("LEVEL UP!")
                    .font(.system(size: 50, weight: .black, design: .rounded))
                    .foregroundColor(.yellow)
                    .transition(.scale)
            }
        }
        .navigationTitle("Light It Up")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }
    
    
    private func setupLevel() {
       
        cards = (0..<currentLevel.cardCount).map { _ in Card() }
        
       
        gameTickTimer = Timer.publish(every: currentLevel.litDuration, on: .main, in: .common).autoconnect()
        lightUpRandomCards()
    }
    
    private func updateRoundClock() {
        if timeRemaining > 0 {
            timeRemaining -= 1
            checkForLevelTransitions()
        } else {
            endGame()
        }
    }
    
    private func checkForLevelTransitions() {
        let matchingLevel = GameLevel.allCases.first { $0.timeRange.contains(timeRemaining) } ?? .l4
        
        if matchingLevel != currentLevel {
            withAnimation {
                currentLevel = matchingLevel
                showLevelUpFlash = true
            }
            setupLevel()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation { showLevelUpFlash = false }
            }
        }
    }
    
    private func lightUpRandomCards() {
        
        for i in 0..<cards.count { cards[i].isLit = false }
        
        let litCount = currentLevel == .l4 ? 2 : 1
        var selectedIndices = Set<Int>()
        
        while selectedIndices.count < min(litCount, cards.count) {
            let randomIndex = Int.random(in: 0..<cards.count)
            selectedIndices.insert(randomIndex)
        }
        
        withAnimation(.easeInOut(duration: 0.15)) {
            for index in selectedIndices {
                cards[index].isLit = true
            }
        }
    }
    
    private func handleCardTap(_ card: Card) {
        guard let index = cards.firstIndex(where: { $0.id == card.id }) else { return }
        
        if cards[index].isLit {
            score += 10
            withAnimation { cards[index].isLit = false }
        } else {
            
            if lives > 1 {
                lives -= 1
            } else {
                lives = 0
                endGame()
            }
        }
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
                mode: .lightItUp,
                score: score,
                coordinate: LocationService.shared.currentLocation
            )
        }
    }
    
    private func resetGame() {
        score = 0
        timeRemaining = 60
        lives = 3
        currentLevel = .l1
        isGameOver = false
        hasRecordedThisRound = false
        setupLevel()
    }
}
