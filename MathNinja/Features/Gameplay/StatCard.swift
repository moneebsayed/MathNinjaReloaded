//
//  StatCard.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/16/25.
//


import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Theme.primaryColor)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(Theme.textPrimary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(Theme.textSecondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Theme.cardBackground)
                .stroke(Theme.primaryColor.opacity(0.3), lineWidth: 1)
        )
    }
}

