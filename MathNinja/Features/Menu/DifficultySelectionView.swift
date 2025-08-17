//
//  DifficultySelectionView.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/15/25.
//


import SwiftUI

struct DifficultySelectionView: View {
    @EnvironmentObject var gameStateManager: GameStateManager
    @State private var selectedDifficulty: Difficulty?
    @State private var showingGameView = false
    
    var body: some View {
        ZStack {
            NinjaBackground()
            
            VStack(spacing: 30) {
                // Back button
                HStack {
                    Button(action: {
                        gameStateManager.transition(to: .menu)
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(Theme.primaryColor)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                
                // Title
                NinjaTitle("Choose Difficulty", subtitle: "Select your challenge level")
                
                // Difficulty Cards
                VStack(spacing: 20) {
                    ForEach(Difficulty.allCases) { difficulty in
                        DifficultyCard(
                            difficulty: difficulty,
                            isSelected: selectedDifficulty == difficulty
                        ) {
                            selectedDifficulty = difficulty
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                // Replace the "Start Game" button section with:
                if selectedDifficulty != nil {
                    Button("Start Game") {
                        // Pass the selected difficulty to the game
                        if let difficulty = selectedDifficulty {
                            UserDefaults.standard.set(difficulty.rawValue, forKey: "selectedDifficulty")
                        }
                        gameStateManager.transition(to: .playing)
                    }
                    .buttonStyle(NinjaButtonStyle())
                    .transition(.scale.combined(with: .opacity))
                }
                
                
                Spacer()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: selectedDifficulty)
    }
}

#Preview {
    DifficultySelectionView()
        .environmentObject(GameStateManager())
}
