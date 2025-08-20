//
//  Theme.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/15/25.
//

import SwiftUI

struct Theme {
    // MARK: - Primary Colors (Now Adaptive by Default)
    static var primaryColor: Color {
        Color(light: Color(red: 0.2, green: 0.7, blue: 0.4),     // Light green
              dark: Color(red: 0.3, green: 0.8, blue: 0.5))      // Brighter green
    }
    
    static var secondaryColor: Color {
        Color(light: Color(red: 0.9, green: 0.5, blue: 0.1),     // Orange
              dark: Color(red: 1.0, green: 0.6, blue: 0.2))      // Brighter orange
    }
    
    static var dangerColor: Color {
        Color(light: Color(red: 0.8, green: 0.2, blue: 0.2),     // Red
              dark: Color(red: 0.9, green: 0.3, blue: 0.3))      // Brighter red
    }
    
    static var backgroundColor: Color {
        Color(light: Color(red: 0.95, green: 0.95, blue: 0.97),  // Light gray
              dark: Color(red: 0.1, green: 0.1, blue: 0.15))     // Dark blue
    }
    
    static var cardBackground: Color {
        Color(light: Color.white.opacity(0.9),
              dark: Color(red: 0.15, green: 0.15, blue: 0.2))    // Dark card
    }
    
    // MARK: - Text Colors (Adaptive)
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    
    // MARK: - Gradients (Adaptive)
    static var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [primaryColor, primaryColor.opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [backgroundColor, backgroundColor.opacity(0.9)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    // MARK: - Place-like Background Gradients
    static var dojoGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(light: Color(red: 0.9, green: 0.85, blue: 0.8),   // Light wooden dojo
                       dark: Color(red: 0.05, green: 0.1, blue: 0.15)),  // Dark mystical dojo
                Color(light: Color(red: 0.85, green: 0.8, blue: 0.75),
                       dark: Color(red: 0.1, green: 0.15, blue: 0.2))
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    static var mountainGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(light: Color(red: 0.8, green: 0.9, blue: 1.0),    // Light sky
                       dark: Color(red: 0.1, green: 0.1, blue: 0.2)),    // Night sky
                Color(light: Color(red: 0.7, green: 0.8, blue: 0.9),
                       dark: Color(red: 0.15, green: 0.15, blue: 0.25)),
                Color(light: Color(red: 0.5, green: 0.6, blue: 0.4),    // Mountains
                       dark: Color(red: 0.2, green: 0.25, blue: 0.3))
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    // MARK: - Legacy Support (Keep the adaptive versions for compatibility)
    static var adaptivePrimaryColor: Color { primaryColor }
    static var adaptiveSecondaryColor: Color { secondaryColor }
    static var adaptiveDangerColor: Color { dangerColor }
    static var adaptiveBackgroundColor: Color { backgroundColor }
    static var adaptiveCardBackground: Color { cardBackground }
}

// MARK: - Color Extension for Light/Dark Mode
extension Color {
    init(light: Color, dark: Color) {
        self.init(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}
