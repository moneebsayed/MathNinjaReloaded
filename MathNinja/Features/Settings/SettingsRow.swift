//
//  SettingsRow.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/15/25.
//

import SwiftUI

// MARK: - Settings Row Component
struct SettingsRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Theme.primaryColor)
                .frame(width: 24)
            
            Text(title)
                .foregroundColor(Theme.textPrimary)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: Theme.primaryColor))
        }
    }
}
