//
//  Theme.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/15/25.
//


import SwiftUI

struct Theme {
    static let primaryColor = Color(red: 0.2, green: 0.8, blue: 0.4) // Ninja green
    static let secondaryColor = Color(red: 1.0, green: 0.6, blue: 0.0) // Orange accent
    static let dangerColor = Color(red: 0.9, green: 0.3, blue: 0.3) // Red
    static let backgroundColor = Color(red: 0.1, green: 0.1, blue: 0.15) // Dark blue
    static let cardBackground = Color(red: 0.15, green: 0.15, blue: 0.2)
    static let textPrimary = Color.white
    static let textSecondary = Color(white: 0.7)
    
    // Gradients
    static let primaryGradient = LinearGradient(
        colors: [primaryColor, primaryColor.opacity(0.8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let backgroundGradient = LinearGradient(
        colors: [backgroundColor, backgroundColor.opacity(0.8)],
        startPoint: .top,
        endPoint: .bottom
    )
}
