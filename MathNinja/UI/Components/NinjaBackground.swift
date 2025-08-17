//
//  NinjaBackground.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/15/25.
//


import SwiftUI

// MARK: - Animated Background
struct NinjaBackground: View {
    @State private var animateGradient = false
    
    var body: some View {
        ZStack {
            // Base gradient
            Theme.backgroundGradient
                .ignoresSafeArea()
            
            // Animated stars/sparkles
            ForEach(0..<20, id: \.self) { _ in
                Circle()
                    .fill(Theme.primaryColor.opacity(0.1))
                    .frame(width: .random(in: 2...6))
                    .position(
                        x: .random(in: 0...UIScreen.main.bounds.width),
                        y: .random(in: 0...UIScreen.main.bounds.height)
                    )
                    .animation(
                        .easeInOut(duration: .random(in: 2...4))
                        .repeatForever(autoreverses: true),
                        value: animateGradient
                    )
            }
        }
        .onAppear {
            animateGradient = true
        }
    }
}
