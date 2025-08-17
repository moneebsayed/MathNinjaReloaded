//
//  GameState.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/15/25.
//


import Foundation
import GameplayKit

enum GameState {
    case menu
    case difficultySelection
    case playing
    case paused
    case gameOver
    case settings
}

class GameStateManager: ObservableObject {
    @Published var currentState: GameState = .menu
    @Published var isTransitioning = false
    
    private let stateMachine: GKStateMachine
    
    init() {
        // Initialize the state machine with states that don't need manager reference yet
        let states: [GKState] = [
            MenuState(),
            DifficultySelectionState(),
            PlayingState(),
            PausedState(),
            GameOverState(),
            SettingsState()
        ]
        
        stateMachine = GKStateMachine(states: states)
        
        // Now set the manager reference for each state after initialization
        states.forEach { state in
            if let managedState = state as? ManagedState {
                managedState.setManager(self)
            }
        }
        
        stateMachine.enter(MenuState.self)
    }
    
    func transition(to state: GameState) {
        isTransitioning = true
        
        // Add a small delay for smooth transitions
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.currentState = state
            self.isTransitioning = false
        }
        
        // Handle state machine transitions
        switch state {
        case .menu:
            stateMachine.enter(MenuState.self)
        case .difficultySelection:
            stateMachine.enter(DifficultySelectionState.self)
        case .playing:
            stateMachine.enter(PlayingState.self)
        case .paused:
            stateMachine.enter(PausedState.self)
        case .gameOver:
            stateMachine.enter(GameOverState.self)
        case .settings:
            stateMachine.enter(SettingsState.self)
        }
    }
}

// MARK: - Protocol for States that need Manager Reference

protocol ManagedState: AnyObject {
    func setManager(_ manager: GameStateManager)
}

// MARK: - GameplayKit States
