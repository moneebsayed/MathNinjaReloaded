//
//  StreakIndicator.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/16/25.
//


import SwiftUI

struct StreakIndicator: View {
    let streak: Int
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "bolt.fill")
                .foregroundColor(Theme.secondaryColor)
                .font(.title2)
            
            Text("STREAK \(streak)!")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(Theme.secondaryColor)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Theme.secondaryColor.opacity(0.2))
                .stroke(Theme.secondaryColor, lineWidth: 2)
        )
        .shadow(color: Theme.secondaryColor.opacity(0.5), radius: 8)
    }
}
