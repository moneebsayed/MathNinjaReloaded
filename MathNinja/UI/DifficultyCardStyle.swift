//
//  DifficultyCardStyle.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/15/25.
//

import SwiftUI

struct DifficultyCardStyle: ButtonStyle {
    let difficulty: Difficulty
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Theme.cardBackground)
                    .stroke(colorForDifficulty(difficulty), lineWidth: 2)
                    .shadow(color: colorForDifficulty(difficulty).opacity(0.3), radius: 8)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
    
    private func colorForDifficulty(_ difficulty: Difficulty) -> Color {
        switch difficulty {
        case .easy: return Theme.primaryColor
        case .medium: return Theme.secondaryColor
        case .hard: return Theme.dangerColor
        }
    }
}
