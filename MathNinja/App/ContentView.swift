//
//  ContentView.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/15/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var gameStateManager: GameStateManager
    
    var body: some View {
        Group {
            switch gameStateManager.currentState {
            case .menu:
                MenuView()
            case .difficultySelection:
                DifficultySelectionView()
            case .playing:
                GameView()
            case .paused:
                GameView() // Keep game view in background
            case .gameOver:
                GameOverView()
            case .settings:
                SettingsView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: gameStateManager.currentState)
    }
}

#Preview {
    ContentView()
        .environmentObject(GameStateManager())
}
