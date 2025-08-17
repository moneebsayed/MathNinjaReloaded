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
                .font(.title3)
                .foregroundColor(Theme.textPrimary)
        }
        .buttonStyle(.plain)
    }
}
