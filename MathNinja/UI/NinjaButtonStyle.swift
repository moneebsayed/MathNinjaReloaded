//
//  NinjaButtonStyle.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/15/25.
//

import SwiftUI

struct NinjaButtonStyle: ButtonStyle {
    let isSecondary: Bool
    
    init(isSecondary: Bool = false) {
        self.isSecondary = isSecondary
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSecondary ? Theme.backgroundGradient : Theme.primaryGradient)
                    .stroke(isSecondary ? Theme.primaryColor : Color.clear, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .padding(.horizontal)
    }
}
