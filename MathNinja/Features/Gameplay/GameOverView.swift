//
//  GameOverView.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/16/25.
//


import SwiftUI

struct GameOverView: View {
    @EnvironmentObject var gameStateManager: GameStateManager
    @AppStorage("highScore") private var highScore = 0
    
    // These would typically be passed as parameters
    @State private var finalScore = 1850
    @State private var problemsSolved = 12
    @State private var accuracy = 85
    @State private var maxStreak = 8
    @State private var isNewHighScore = false
    
    var body: some View {
        ZStack {
            NinjaBackground()
            
            VStack(spacing: 30) {
                // Game Over Title
                VStack(spacing: 12) {
                    Text("💀")
                        .font(.system(size: 60))
                    
                    Text("Game Over!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.textPrimary)
                    
                    if isNewHighScore {
                        Text("🎉 NEW HIGH SCORE! 🎉")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(Theme.secondaryColor)
                            .scaleEffect(1.1)
                            .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: isNewHighScore)
                    }
                }
                
                // Final Stats
                MenuCard {
                    VStack(spacing: 20) {
                        // Final Score
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Final Score")
                                    .font(.headline)
                                    .foregroundColor(Theme.textPrimary)
                                
                                Text("\(finalScore)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(Theme.primaryColor)
                            }
                            
                            Spacer()
                            
                            if isNewHighScore {
                                Image(systemName: "crown.fill")
                                    .font(.title2)
                                    .foregroundColor(Theme.secondaryColor)
                            }
                        }
                        
                        Divider()
                            .background(Theme.textSecondary.opacity(0.3))
                        
                        // Detailed Stats
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            StatCard(title: "Problems", value: "\(problemsSolved)", icon: "checkmark.circle")
                            StatCard(title: "Accuracy", value: "\(accuracy)%", icon: "target")
                            StatCard(title: "Best Streak", value: "\(maxStreak)", icon: "flame")
                            StatCard(title: "High Score", value: "\(highScore)", icon: "star")
                        }
                    }
                }
                
                // Action buttons
                VStack(spacing: 16) {
                    Button("Play Again") {
                        gameStateManager.transition(to: .difficultySelection)
                    }
                    .buttonStyle(NinjaButtonStyle())
                    
                    HStack(spacing: 16) {
                        Button("Main Menu") {
                            gameStateManager.transition(to: .menu)
                        }
                        .buttonStyle(NinjaButtonStyle(isSecondary: true))
                        
                        Button("Share Score") {
                            shareScore()
                        }
                        .buttonStyle(NinjaButtonStyle(isSecondary: true))
                    }
                }
                
                Spacer()
            }
            .padding(24)
        }
        .onAppear {
            checkForNewHighScore()
        }
    }
    
    private func checkForNewHighScore() {
        if finalScore > highScore {
            isNewHighScore = true
            highScore = finalScore
        }
    }
    
    private func shareScore() {
        let shareText = "I just scored \(finalScore) points in Math Ninja! 🥷✨ Can you beat my score?"
        
        let activityViewController = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityViewController, animated: true)
        }
    }
}

#Preview {
    GameOverView()
        .environmentObject(GameStateManager())
}
