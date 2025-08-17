//
//  PauseMenuView.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/16/25.
//


import SwiftUI

struct PauseMenuView: View {
    @EnvironmentObject var gameStateManager: GameStateManager
    @Environment(\.dismiss) private var dismiss
    
    let score: Int
    let timeRemaining: TimeInterval
    let onResume: () -> Void
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            // Pause menu content
            VStack(spacing: 24) {
                // Title
                VStack(spacing: 8) {
                    Text("⏸️")
                        .font(.system(size: 50))
                    
                    Text("Game Paused")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.textPrimary)
                }
                
                // Current stats
                MenuCard {
                    VStack(spacing: 16) {
                        StatRow(label: "Current Score", value: "\(score)")
                        StatRow(label: "Time Remaining", value: formatTime(timeRemaining))
                    }
                }
                
                // Menu options
                VStack(spacing: 16) {
                    Button("Resume Game") {
                        dismiss()
                        onResume()
                    }
                    .buttonStyle(NinjaButtonStyle())
                    
                    Button("Main Menu") {
                        dismiss()
                        gameStateManager.transition(to: .menu)
                    }
                    .buttonStyle(NinjaButtonStyle(isSecondary: true))
                }
            }
            .padding(24)
        }
        .interactiveDismissDisabled() // Prevent accidental dismissal
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    PauseMenuView(
        score: 1250,
        timeRemaining: 45,
        onResume: { print("Resume tapped") }
    )
    .environmentObject(GameStateManager())
}
