//
//  DifficultyCard.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/15/25.
//

import SwiftUI

struct DifficultyCard: View {
    let difficulty: Difficulty
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Emoji and difficulty name
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(difficulty.emoji)
                            .font(.system(size: 24))
                        
                        Text(difficulty.rawValue)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Theme.textPrimary)
                    }
                    
                    Text(difficulty.description)
                        .font(.subheadline)
                        .foregroundColor(Theme.textSecondary)
                }
                
                Spacer()
                
                // Game duration and selection indicator
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(Int(difficulty.gameDuration))s")
                        .font(.headline)
                        .foregroundColor(colorForDifficulty(difficulty))
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(colorForDifficulty(difficulty))
                            .font(.title2)
                    } else {
                        Image(systemName: "circle")
                            .foregroundColor(Theme.textSecondary)
                            .font(.title2)
                    }
                }
            }
            .padding(20)
        }
        .buttonStyle(DifficultyCardStyle(difficulty: difficulty))
    }
    
    private func colorForDifficulty(_ difficulty: Difficulty) -> Color {
        switch difficulty {
        case .easy: return Theme.primaryColor
        case .medium: return Theme.secondaryColor
        case .hard: return Theme.dangerColor
        }
    }
}
