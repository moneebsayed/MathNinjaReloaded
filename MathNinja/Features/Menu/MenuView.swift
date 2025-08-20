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

            // Decorative Sprite layer, stays underneath
            VStack {
                Spacer()
                SpriteView(scene: createChaseScene(), options: [.allowsTransparency])
                    .frame(maxWidth: .infinity, maxHeight: 150)
                    .ignoresSafeArea(.all)
                    .allowsHitTesting(false)
                    .background(.clear)
            }
            .zIndex(0)

            // Main content
            VStack(spacing: 40) {
                Spacer()
                
                NinjaTitle("Math Ninja", subtitle: "Slice your way to math mastery!")
                
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
                
                Spacer(minLength: 0) // content ends here; version goes in safe-area inset below
            }
            .padding(24)
            .zIndex(1)
        }
        .accessibilityIdentifier("MenuView")
        // ✅ This guarantees the version label is visible & accessible on all devices
        .safeAreaInset(edge: .bottom) {
            Text("Version 2.0")
                .font(.caption)
                .foregroundColor(Theme.textSecondary)
                .accessibilityIdentifier("VersionInfo")
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 8)
        }
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
