//
//  GameView.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/15/25.
//

import SwiftUI
import SpriteKit

struct GameView: View {
    @EnvironmentObject var gameStateManager: GameStateManager
    @StateObject private var gameEngine = GameEngine()
    @State private var gameScene: GameScene?
    @State private var showingPauseMenu = false
    @State private var selectedDifficulty: Difficulty = .medium
    
    var body: some View {
        ZStack {
            if let scene = gameScene {
                SpriteView(scene: scene)
                    .ignoresSafeArea()
                    // Remove the red debug background
            } else {
                // Loading placeholder
                Color.black.ignoresSafeArea()
                Text("Loading Game Scene...")
                    .foregroundColor(.white)
            }
            
            // SwiftUI HUD Overlay
            VStack {
                // Top HUD
                GameHUD(
                    score: gameEngine.score,
                    timeRemaining: gameEngine.timeRemaining,
                    streak: gameEngine.streak,
                    difficulty: selectedDifficulty
                ) {
                    pauseGame()
                }
                
                Spacer()
                
                // Replace the debug info section with:
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
        }
        .onDisappear {
            print("🎮 GameView disappeared")
            gameEngine.endGame()
        }
        .onReceive(gameEngine.$currentProblems) { problems in
            print("📡 Received \(problems.count) problems from engine")
            gameScene?.updateProblemNodes(with: problems)
        }
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
