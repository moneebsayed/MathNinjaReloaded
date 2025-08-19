import SwiftUI
import Combine
import SpriteKit

struct GameView: View {
    @EnvironmentObject var gameStateManager: GameStateManager
    @StateObject private var gameEngine = GameEngine()
    @State private var gameScene: GameScene?
    @State private var showingPauseMenu = false
    @State private var selectedDifficulty: Difficulty = .medium
    @State private var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        ZStack {
            if let scene = gameScene {
                SpriteView(scene: scene)
                    .ignoresSafeArea()
            } else {
                Color.black.ignoresSafeArea()
                Text("Loading Game Scene...")
                    .foregroundColor(.white)
            }
            
            // SwiftUI HUD Overlay
            VStack {
                // Top HUD
                GameHUD(
                    maxLives: gameEngine.maxLives,
                    lives: gameEngine.lives,
                    score: gameEngine.score,
                    timeRemaining: gameEngine.timeRemaining,
                    streak: gameEngine.streak,
                    difficulty: selectedDifficulty
                ) {
                    pauseGame()
                }
                
                Spacer()
                
                if gameEngine.streak >= 3 {
                    StreakIndicator(streak: gameEngine.streak)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: gameEngine.streak)
        }
        .onAppear {
            print("🎮 GameView appeared")
            setupGameScene()
            startGame()
            setupGameCallbacks()
            setupPublisherSubscriptions() // Add this
        }
        .onDisappear {
            print("🎮 GameView disappeared")
            cleanupSubscriptions() // Add this
            gameEngine.endGame()
        }
        // REMOVE the .onReceive - we'll handle it differently
        .sheet(isPresented: $showingPauseMenu) {
            PauseMenuView(
                score: gameEngine.score,
                timeRemaining: gameEngine.timeRemaining,
                onResume: {
                    resumeGame()
                }
            )
        }
    }
    
    // Add this new method to handle subscriptions safely
    private func setupPublisherSubscriptions() {
        // Clear any existing subscriptions first
        cancellables.removeAll()
        
        // Subscribe to currentProblems changes safely
        gameEngine.$currentProblems
            .receive(on: DispatchQueue.main)
            .sink { [weak gameScene] problems in
                print("📡 Received \(problems.count) problems from engine")
                gameScene?.updateProblemNodes(with: problems)
            }
            .store(in: &cancellables)
    }
    
    // Add this cleanup method
    private func cleanupSubscriptions() {
        cancellables.removeAll()
    }
    
    private func setupGameScene() {
        print("🎬 Setting up game scene")
        let scene = GameScene()
        scene.size = CGSize(
            width: UIScreen.main.bounds.width,
            height: UIScreen.main.bounds.height
        )
        scene.scaleMode = .aspectFill
        scene.gameEngine = gameEngine
        
        self.gameScene = scene
        print("✅ Game scene setup complete")
    }

    private func startGame() {
        // Get difficulty from UserDefaults or use medium as default
        if let difficultyString = UserDefaults.standard.object(forKey: "selectedDifficulty") as? String,
           let difficulty = Difficulty(rawValue: difficultyString) {
            selectedDifficulty = difficulty
        } else {
            selectedDifficulty = .medium
        }
        
        gameEngine.startGame(difficulty: selectedDifficulty)
    }
    
    private func pauseGame() {
        gameEngine.pauseGame()
        gameScene?.setGamePaused(true)
        showingPauseMenu = true
    }

    private func resumeGame() {
        showingPauseMenu = false
        gameScene?.setGamePaused(false)
        gameEngine.resumeGame()
    }
    
    private func setupGameCallbacks() {
        // Use weak references to prevent retain cycles
        gameEngine.onGameOver = { [weak gameStateManager] in
            DispatchQueue.main.async {
                gameStateManager?.transition(to: .gameOver)
            }
        }
        
        gameEngine.onCorrectAnswer = {
            // Add haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        }
        
        gameEngine.onWrongAnswer = {
            // Add haptic feedback for wrong answer
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.impactOccurred()
        }
    }
}

#Preview {
    GameView()
        .environmentObject(GameStateManager())
}
