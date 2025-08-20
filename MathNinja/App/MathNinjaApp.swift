//
//  MathNinjaApp.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/15/25.
//

import SwiftUI

@main
struct MathNinjaApp: App {
    @StateObject private var gameStateManager = GameStateManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameStateManager)
        }
    }
}
