//
//  StatRow.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/16/25.
//

import SwiftUI

struct StatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(Theme.textSecondary)
                .accessibilityIdentifier("\(label)Label")
            
            Spacer()
            
            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(Theme.textPrimary)
                .accessibilityIdentifier("\(label)Value")
        }
        .accessibilityIdentifier("\(label)StatRow")
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
        .accessibilityValue(value)
    }
}
