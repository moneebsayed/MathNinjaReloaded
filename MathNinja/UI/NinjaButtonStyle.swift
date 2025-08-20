//
//  NinjaButtonStyle.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/15/25.
//

import SwiftUI

struct NinjaButtonStyle: ButtonStyle {
    let isSecondary: Bool
    @Environment(\.colorScheme) var colorScheme
    
    init(isSecondary: Bool = false) {
        self.isSecondary = isSecondary
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(isSecondary ? Theme.adaptivePrimaryColor : .white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSecondary ? Theme.backgroundGradient : Theme.primaryGradient)
                    .stroke(isSecondary ? Theme.adaptivePrimaryColor : Color.clear, lineWidth: 2)
                    .shadow(
                        color: colorScheme == .dark ? Color.black.opacity(0.4) : Color.gray.opacity(0.2),
                        radius: colorScheme == .dark ? 6 : 3,
                        x: 0,
                        y: colorScheme == .dark ? 3 : 1
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .padding(.horizontal)
            .accessibilityAddTraits(.isButton)
    }
}
