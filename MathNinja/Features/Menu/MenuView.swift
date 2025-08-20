//
//  MenuView.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/15/25.
//

import SwiftUI
import SpriteKit

//
//  MenuView.swift
//  MathNinja
//

import SwiftUI
import SpriteKit

struct MenuView: View {
    @EnvironmentObject var gameStateManager: GameStateManager
    @State private var showingAbout = false
    
    var body: some View {
        ZStack {
            NinjaBackground()

            VStack {
                Spacer()
                SpriteView(scene: createChaseScene(), options: [.allowsTransparency])
                    .frame(maxWidth: .infinity, maxHeight: 150)
                    .ignoresSafeArea(.all)
                    .allowsHitTesting(false)
                    .background(.clear)
            }

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
                        .accessibilityIdentifier("StartGame")
                        .accessibilityElement(children: .ignore)
                        
                        Button("Settings") {
                            gameStateManager.transition(to: .settings)
                        }
                        .buttonStyle(NinjaButtonStyle(isSecondary: true))
                        .accessibilityIdentifier("Settings")
                        .accessibilityElement(children: .ignore)
                        
                        Button("About") {
                            showingAbout = true
                        }
                        .buttonStyle(NinjaButtonStyle(isSecondary: true))
                        .accessibilityIdentifier("About")
                        .accessibilityElement(children: .ignore)
                    }
                }
                
                Spacer()
                
                // Version info - Make sure it has the identifier
                Text("Version 2.0")
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
                    .accessibilityIdentifier("VersionInfo")
            }
            .padding(24)
        }
        .accessibilityIdentifier("MenuView")
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
    }
    
    private func createChaseScene() -> ChaseSlashScene {
        let scene = ChaseSlashScene()
        scene.backgroundColor = .clear
        return scene
    }
}
