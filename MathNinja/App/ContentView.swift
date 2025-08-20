//
//  ContentView.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/15/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var gameStateManager: GameStateManager
    @StateObject private var gameEngine = GameEngine()

    var body: some View {
        Group {
            switch gameStateManager.currentState {
            case .menu:
                MenuView()
            case .difficultySelection:
                DifficultySelectionView()
            case .playing:
                GameView()
                    .environmentObject(gameEngine)
            case .paused:
                GameView() // Keep game view in background
                    .environmentObject(gameEngine)
            case .gameOver:
                GameOverView()
                    .environmentObject(gameEngine)
            case .settings:
                SettingsView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: gameStateManager.currentState)
        .task {
            // Authenticate Game Center on app launch
            await gameEngine.authenticateGameCenter()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(GameStateManager())
}
