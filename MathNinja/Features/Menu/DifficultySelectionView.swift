//
//  DifficultySelectionView.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/15/25.
//

//
//  DifficultySelectionView.swift
//  MathNinja
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
                    .accessibilityIdentifier("BackButton")
                    .accessibilityElement(children: .ignore) // Prevent inheritance
                    
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
                
                // Start Game button appears when difficulty is selected
                if selectedDifficulty != nil {
                    Button("Start Game") {
                        if let difficulty = selectedDifficulty {
                            UserDefaults.standard.set(difficulty.rawValue, forKey: "selectedDifficulty")
                        }
                        gameStateManager.transition(to: .playing)
                    }
                    .buttonStyle(NinjaButtonStyle())
                    .accessibilityIdentifier("StartSelectedGame")
                    .accessibilityElement(children: .ignore) // Prevent inheritance
                    .transition(.scale.combined(with: .opacity))
                }
                
                Spacer()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: selectedDifficulty)
        .accessibilityIdentifier("DifficultySelectionView") // Move outside of ZStack
    }
}

#Preview {
    DifficultySelectionView()
        .environmentObject(GameStateManager())
}
