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

struct LightItUpView: View {
    @AppStorage("LightItUpHighScore") private var highScore = 0
    
    @State private var score = 0
    @State private var timeRemaining = 60
    @State private var isGameOver = false
    @State private var cards: [Card] = []
    @State private var currentLevel: GameLevel = .l1
    @State private var showLevelUpFlash = false
    @State private var lives = 3
    

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
    }
    
    private func resetGame() {
        score = 0
        timeRemaining = 60
        lives = 3
        currentLevel = .l1
        isGameOver = false
        setupLevel()
    }
}



struct TapFrenzyView: View {
    @State private var score = 0
    @State private var timeRemaining = 10
    @State private var isGameOver = false
    @AppStorage("TapFrenzyHighScore") private var highScore = 0
    
    @State private var buttonOffset = CGSize.zero

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
    }
    
    private func handleTap() {
        score += 1
    }
    
    private func endGame() {
        isGameOver = true
        if score > highScore {
            highScore = score
        }
    }
    
    private func resetGame() {
        score = 0
        timeRemaining = 10
        buttonOffset = .zero
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



#Preview {
    ContentView()
}
