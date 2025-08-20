//
//  NinjaTitle.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/15/25.
//

import SwiftUI

// MARK: - Ninja Title
struct NinjaTitle: View {
    let title: String
    let subtitle: String?
    @Environment(\.colorScheme) var colorScheme
    
    init(_ title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Theme.textPrimary)
                .shadow(
                    color: colorScheme == .dark ? Color.black.opacity(0.8) : Color.clear,
                    radius: colorScheme == .dark ? 2 : 0
                )

            HStack {
                Image("Front - Idle Blinking_001")
                    .rotationEffect(.degrees(-10))
                    .opacity(colorScheme == .dark ? 0.9 : 1.0)
                Spacer()
                Image("Front - Idle Blinking_001")
                    .rotationEffect(.degrees(10))
                    .opacity(colorScheme == .dark ? 0.9 : 1.0)
            }
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}
