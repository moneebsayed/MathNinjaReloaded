//
//  GameHUD.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/16/25.
//


import SwiftUI

struct GameHUD: View {
    let maxLives: Int
    let lives: Int
    let score: Int
    let timeRemaining: TimeInterval
    let streak: Int
    let difficulty: Difficulty
    let onPause: () -> Void
    
    @State private var timeWarning = false
    
    var body: some View {
        HStack(alignment: .top) {
            // Left side - Score and Streak
            VStack(alignment: .leading) {
                ScoreDisplay(score: score)
                if streak > 0 {
                    StreakDisplay(streak: streak)
                }
            }
            
            Spacer()
            
            // Center - Difficulty indicator
            VStack {
                DifficultyBadge(difficulty: difficulty)
                
                PauseButton(action: onPause)
                    .padding()
            }
            
            Spacer()
            
            // Right side - Timer and Pause
            VStack(alignment: .trailing, spacing: 4) {
                TimerDisplay(
                    timeRemaining: timeRemaining,
                    isWarning: timeWarning
                )
                LivesIndicator(lives: lives, maxLives: maxLives)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical)
        .onChange(of: timeRemaining) { _, newTime in
            timeWarning = newTime <= 10
        }
    }
}

// MARK: - HUD Components

struct StreakDisplay: View {
    let streak: Int
    
    var body: some View {
        HStack {
            Text("\(streak)X Combo!")
                .fontWeight(.bold)
                .foregroundColor(Theme.dangerColor)
            Image(systemName: "flame.fill")
                .foregroundColor(Theme.dangerColor)
                .fontWeight(.bold)

        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(
            Capsule()
                .fill(Theme.dangerColor.opacity(0.2))
                .stroke(Theme.dangerColor, lineWidth: 1)
        )
    }
}

struct DifficultyBadge: View {
    let difficulty: Difficulty
    
    var body: some View {
        HStack(spacing: 4) {
            Text(difficulty.emoji)
                .font(.caption)
            
            Text(difficulty.rawValue)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(Theme.textSecondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Theme.cardBackground)
                .stroke(Theme.primaryColor.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    GameHUD(
        maxLives: 5,
        lives: 3,
        score: 1250,
        timeRemaining: 45,
        streak: 7,
        difficulty: .medium
    ) {
        print("Pause tapped")
    }
    .background(Theme.backgroundGradient)
}
