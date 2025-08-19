//
//  LivesIndicator.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/19/25.
//


import SwiftUI

struct LivesIndicator: View {
    let lives: Int
    let maxLives: Int
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<maxLives, id: \.self) { index in
                Image(systemName: index < lives ? "suit.heart.fill" : "suit.heart")
                    .foregroundColor(index < lives ? .red : .gray.opacity(0.4))
                    .font(.title3)
                    .scaleEffect(
                        // Animate the last lost life
                        index == lives && lives >= 0 ? 1.2 : 1.0
                    )
                    .animation(.bouncy(duration: 0.4), value: lives)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

#Preview {
    LivesIndicator(lives: 3, maxLives: 5)
}
