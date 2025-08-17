//
//  PlayingState.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/15/25.
//


import GameplayKit

class PlayingState: GKState, ManagedState {
    weak var manager: GameStateManager?
    
    func setManager(_ manager: GameStateManager) {
        self.manager = manager
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == PausedState.self || stateClass == GameOverState.self
    }
    
    override func didEnter(from previousState: GKState?) {
        print("🎮 Entered Playing State")
    }
    
    override func willExit(to nextState: GKState) {
        print("🎮 Exiting Playing State")
    }
}
