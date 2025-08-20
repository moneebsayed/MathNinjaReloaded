//
//  PauseButton.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/16/25.
//

import SwiftUI

struct PauseButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "pause.fill")
                .font(.title2)
                .foregroundColor(Theme.textPrimary)
                .frame(width: 44, height: 44) // Ensure minimum touch target
                .background(
                    Circle()
                        .fill(Theme.cardBackground)
                        .stroke(Theme.primaryColor.opacity(0.3), lineWidth: 1)
                )
                .accessibilityIdentifier("PauseButton")
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())                    // ✅ enlarge tappable area to the button’s frame
        .allowsHitTesting(true)                       // ✅ ensure taps aren’t swallowed by SpriteKit
        .zIndex(999)                                  // ✅ keep the button above the game surface
        .accessibilityIdentifier("PauseButton")
        .accessibilityLabel("Pause Game")
        .accessibilityHint("Pause the current game")
        .accessibilityElement(children: .combine)     // ✅ make the Button itself the element
        .accessibilityAddTraits(.isButton)
        .accessibilityRespondsToUserInteraction(true)
    }
}
