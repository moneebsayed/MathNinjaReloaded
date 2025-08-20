//
//  DifficultyCard.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/15/25.
//

import SwiftUI

// Provide a stable, capitalized key for accessibility & tests.
private extension Difficulty {
    var axKey: String {
        switch self {
        case .easy:   return "Easy"
        case .medium: return "Medium"
        case .hard:   return "Hard"
        }
    }
}

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

                        // You can still show whatever case you like visually,
                        // but for AX we’ll use the stable key.
                        Text(difficulty.axKey)
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
                            // 🔑 Match the test exactly: "EasySelected", "MediumSelected", "HardSelected"
                            .accessibilityIdentifier("\(difficulty.axKey)Selected")
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
        // 🔑 Make the button itself discoverable as "Easy" (etc.) for taps in tests.
        .accessibilityIdentifier(difficulty.axKey)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(difficulty.axKey) difficulty")
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
    }

    private func colorForDifficulty(_ difficulty: Difficulty) -> Color {
        switch difficulty {
        case .easy: return Theme.primaryColor
        case .medium: return Theme.secondaryColor
        case .hard: return Theme.dangerColor
        }
    }
}
