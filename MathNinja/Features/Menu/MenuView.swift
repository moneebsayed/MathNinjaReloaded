//
//  MenuView.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/15/25.
//


import SwiftUI
import SpriteKit

struct MenuView: View {
    @EnvironmentObject var gameStateManager: GameStateManager
    @State private var showingAbout = false
    
    var body: some View {
        ZStack {
            NinjaBackground()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Title
                NinjaTitle("Math Ninja", subtitle: "Slice your way to math mastery!")
                
                // Main Menu Card
                MenuCard {
                    VStack(spacing: 20) {
                        Button("Start Game") {
                            gameStateManager.transition(to: .difficultySelection)
                        }
                        .buttonStyle(NinjaButtonStyle())
                        
                        Button("Settings") {
                            gameStateManager.transition(to: .settings)
                        }
                        .buttonStyle(NinjaButtonStyle(isSecondary: true))
                        
                        Button("About") {
                            showingAbout = true
                        }
                        .buttonStyle(NinjaButtonStyle(isSecondary: true))
                    }
                }
                
                Spacer()
                // Chase scene at the bottom
                SpriteView(scene: createChaseScene())
                    .frame(height: 150)
                    .background(Color.clear) // Make sure this is clear
                    .allowsHitTesting(false)
                
                // Version info
                Text("Version 2.0")
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
            }
            .padding(24)
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
    }
    
    private func createChaseScene() -> ChaseSlashScene {
        let scene = ChaseSlashScene()
        // Let the scene handle its own scale mode
        return scene
    }
}

#Preview {
    MenuView()
        .environmentObject(GameStateManager())
}

