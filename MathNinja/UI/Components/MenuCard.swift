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
                .fill(Theme.cardBackground)
                .stroke(Theme.primaryColor.opacity(0.3), lineWidth: 1)
        )
    }
}
