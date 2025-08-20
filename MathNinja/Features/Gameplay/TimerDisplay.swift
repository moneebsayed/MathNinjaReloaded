//
//  TimerDisplay.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/16/25.
//

import SwiftUI

struct TimerDisplay: View {
    let timeRemaining: TimeInterval
    let isWarning: Bool
    
    private var formattedTime: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "timer")
                .foregroundColor(isWarning ? Theme.dangerColor : Theme.primaryColor)
                .font(.caption)
                .accessibilityIdentifier("TimerIcon")
            
            Text(formattedTime)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(isWarning ? Theme.dangerColor : Theme.textPrimary)
                .accessibilityIdentifier("TimerValue")
        }
        .scaleEffect(isWarning ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.5).repeatCount(isWarning ? .max : 1), value: isWarning)
        .accessibilityIdentifier("TimerDisplay")
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Time remaining: \(formattedTime)")
        .accessibilityValue(isWarning ? "Warning: Low time" : "Normal")
        .accessibilityHint(isWarning ? "Time is running out" : "Time remaining in the game")
    }
}
