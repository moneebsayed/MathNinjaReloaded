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
    
    init(_ title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }
    
    var body: some View {
        VStack {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Theme.textPrimary)

            HStack {
                Image("Front - Idle Blinking_001")
                    .rotationEffect(.degrees(-10))
                Spacer()
                Image("Front - Idle Blinking_001")
                    .rotationEffect(.degrees(10))

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
