//
//  SettingsRow.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/15/25.
//

import SwiftUI

struct SettingsRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Theme.primaryColor)
                .frame(width: 30)
            
            Text(title)
                .foregroundColor(Theme.textPrimary)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: Theme.primaryColor))
                .accessibilityIdentifier("\(title.replacingOccurrences(of: " ", with: ""))Toggle")
        }
        .accessibilityIdentifier("\(title.replacingOccurrences(of: " ", with: ""))Row")
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityValue(isOn ? "On" : "Off")
    }
}
