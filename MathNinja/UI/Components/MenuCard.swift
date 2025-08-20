//
//  MenuCard.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/15/25.
//

import SwiftUI

// MARK: - Menu Card Container
struct MenuCard<Content: View>: View {
    let content: Content
    @Environment(\.colorScheme) var colorScheme
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack {
            content
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Theme.adaptiveCardBackground)
                .stroke(Theme.adaptivePrimaryColor.opacity(0.3), lineWidth: 1)
                .shadow(
                    color: colorScheme == .dark ? Color.black.opacity(0.5) : Color.gray.opacity(0.2),
                    radius: colorScheme == .dark ? 8 : 4,
                    x: 0,
                    y: colorScheme == .dark ? 4 : 2
                )
        )
        .accessibilityElement(children: .contain) // Allow child elements to be accessible
    }
}
