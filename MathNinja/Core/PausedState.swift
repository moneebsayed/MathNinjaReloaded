//
//  PausedState.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/15/25.
//

import GameplayKit

class PausedState: GKState, ManagedState {
    weak var manager: GameStateManager?
    
    func setManager(_ manager: GameStateManager) {
        self.manager = manager
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == PlayingState.self || stateClass == MenuState.self
    }
    
    override func didEnter(from previousState: GKState?) {
        print("⏸️ Entered Paused State")
    }
}
