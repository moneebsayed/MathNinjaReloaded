//
//  GameView.swift
//  MathNinja
//

import SwiftUI
import Combine
import SpriteKit

struct GameView: View {
    @EnvironmentObject var gameStateManager: GameStateManager
    @EnvironmentObject var gameEngine: GameEngine
    
    @State private var gameScene: GameScene?
    @State private var showingPauseMenu = false
    @State private var selectedDifficulty: Difficulty = .medium
    @State private var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        ZStack {
            // Game Scene Layer
            if let scene = gameScene {
                SpriteView(scene: scene)
                    .ignoresSafeArea()
                    .allowsHitTesting(!showingPauseMenu) // Disable when paused
                    .accessibilityIdentifier("GameScene")
            } else {
                Color.black.ignoresSafeArea()
                Text("Loading Game Scene...")
                    .foregroundColor(.white)
                    .accessibilityIdentifier("GameLoadingText")
            }
            
            // SwiftUI HUD Overlay - CRITICAL: Add proper layering
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
                    print("🎯 Pause button tapped!") // Debug print
                    pauseGame()
                }
                .allowsHitTesting(true) // Enable HUD touches
                .zIndex(100) // Ensure HUD is on top
                .accessibilityIdentifier("GameHUD")
                
                Spacer()
                
                if gameEngine.streak >= 3 {
                    StreakIndicator(streak: gameEngine.streak)
                        .transition(.scale.combined(with: .opacity))
                        .allowsHitTesting(false) // Don't block touches
                        .accessibilityIdentifier("StreakIndicator")
                }
            }
            .animation(.easeInOut(duration: 0.3), value: gameEngine.streak)
        }
        .accessibilityIdentifier("GameView")
        .onAppear {
            print("🎮 GameView appeared")
            setupGameScene()
            startGame()
            setupGameCallbacks()
            setupPublisherSubscriptions()
        }
        .onDisappear {
            print("🎮 GameView disappeared")
            cleanupSubscriptions()
            gameEngine.endGameWithGameCenter()
        }
        .sheet(isPresented: $showingPauseMenu) {
            PauseMenuView(
                score: gameEngine.score,
                timeRemaining: gameEngine.timeRemaining,
                onResume: {
                    resumeGame()
                }
            )
            .accessibilityIdentifier("PauseMenuSheet")
        }
    }
    
    private func setupPublisherSubscriptions() {
        cancellables.removeAll()
        
        gameEngine.$currentProblems
            .receive(on: DispatchQueue.main)
            .sink { [weak gameScene] problems in
                print("📡 Received \(problems.count) problems from engine")
                gameScene?.updateProblemNodes(with: problems)
            }
            .store(in: &cancellables)
    }
    
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
        if let difficultyString = UserDefaults.standard.object(forKey: "selectedDifficulty") as? String,
           let difficulty = Difficulty(rawValue: difficultyString) {
            selectedDifficulty = difficulty
        } else {
            selectedDifficulty = .medium
        }
        
        gameEngine.startGameWithGameCenter(difficulty: selectedDifficulty)
    }
    
    private func pauseGame() {
        print("⏸️ Pausing game...") // Debug print
        gameEngine.pauseGame()
        gameScene?.setGamePaused(true)
        showingPauseMenu = true
    }

    private func resumeGame() {
        print("▶️ Resuming game...") // Debug print
        showingPauseMenu = false
        gameScene?.setGamePaused(false)
        gameEngine.resumeGame()
    }
    
    private func setupGameCallbacks() {
        gameEngine.onGameOver = { [weak gameStateManager] in
            DispatchQueue.main.async {
                if gameStateManager?.currentState != .menu {
                    gameStateManager?.transition(to: .gameOver)
                }
            }
        }
        
        gameEngine.onCorrectAnswer = {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        }
        
        gameEngine.onWrongAnswer = {
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.impactOccurred()
        }
    }
}

#Preview {
    GameView()
        .environmentObject(GameStateManager())
}
