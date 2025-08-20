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
        }
        .buttonStyle(PlainButtonStyle()) // This is crucial!
    }
}
