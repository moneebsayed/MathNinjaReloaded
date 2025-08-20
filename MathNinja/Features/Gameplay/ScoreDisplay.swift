//
//  ScoreDisplay.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/16/25.
//

import SwiftUI

struct ScoreDisplay: View {
    let score: Int
    @State private var previousScore = 0
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .foregroundColor(Theme.secondaryColor)
                .font(.caption)
                .accessibilityIdentifier("ScoreIcon")
            
            Text("\(score)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(Theme.textPrimary)
                .contentTransition(.numericText(value: Double(score)))
                .animation(.easeInOut(duration: 0.3), value: score)
                .accessibilityIdentifier("ScoreValue")
        }
        .scaleEffect(score != previousScore ? 1.2 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: score)
        .onChange(of: score) { oldValue, newValue in
            previousScore = oldValue
            
            // Reset scale after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                previousScore = newValue
            }
        }
        .accessibilityIdentifier("ScoreDisplay")
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Current score: \(score) points")
        .accessibilityValue("\(score)")
    }
}
