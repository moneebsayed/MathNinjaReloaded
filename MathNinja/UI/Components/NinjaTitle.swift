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
        VStack(spacing: 8) {
            HStack {
                Text("🥷")
                    .font(.system(size: 40))
                    .rotationEffect(.degrees(-10))
                
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.textPrimary)
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
