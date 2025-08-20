//
//  DifficultyCardStyle.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/15/25.
//

import SwiftUI

struct DifficultyCardStyle: ButtonStyle {
    let difficulty: Difficulty
    @Environment(\.colorScheme) var colorScheme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Theme.adaptiveCardBackground)
                    .stroke(colorForDifficulty(difficulty), lineWidth: 2)
                    .shadow(
                        color: colorForDifficulty(difficulty).opacity(colorScheme == .dark ? 0.5 : 0.3),
                        radius: colorScheme == .dark ? 10 : 6,
                        x: 0,
                        y: colorScheme == .dark ? 4 : 2
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
    
    private func colorForDifficulty(_ difficulty: Difficulty) -> Color {
        switch difficulty {
        case .easy: return Theme.adaptivePrimaryColor
        case .medium: return Theme.adaptiveSecondaryColor
        case .hard: return Theme.adaptiveDangerColor
        }
    }
}
