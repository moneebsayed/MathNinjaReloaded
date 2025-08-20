//
//  SettingsView.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/15/25.
//

//
//  SettingsView.swift
//  MathNinja
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var gameStateManager: GameStateManager
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("vibrationEnabled") private var vibrationEnabled = true
    @AppStorage("showHints") private var showHints = true
    
    var body: some View {
        ZStack {
            NinjaBackground()
            
            VStack(spacing: 30) {
                // Back button
                HStack {
                    Button(action: {
                        gameStateManager.transition(to: .menu)
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(Theme.primaryColor)
                    }
                    .accessibilityIdentifier("BackButton")
                    .accessibilityElement(children: .ignore)
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                
                // Title
                NinjaTitle("Settings", subtitle: "Customize your ninja experience")
                
                // Settings Card
                MenuCard {
                    VStack(spacing: 20) {
                        SettingsRow(
                            icon: "speaker.wave.3",
                            title: "Sound Effects",
                            isOn: $soundEnabled
                        )
                        
                        Divider()
                            .background(Theme.textSecondary.opacity(0.3))
                        
                        SettingsRow(
                            icon: "iphone.radiowaves.left.and.right",
                            title: "Vibration",
                            isOn: $vibrationEnabled
                        )
                        
                        Divider()
                            .background(Theme.textSecondary.opacity(0.3))
                        
                        SettingsRow(
                            icon: "lightbulb",
                            title: "Show Hints",
                            isOn: $showHints
                        )
                    }
                }
                
                Spacer()
            }
            .padding(24)
        }
        .accessibilityIdentifier("SettingsView") // Move outside of ZStack
    }
}

#Preview {
    SettingsView()
        .environmentObject(GameStateManager())
}
