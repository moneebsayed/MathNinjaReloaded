//
//  GameConstants.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/15/25.
//


import Foundation
import CoreGraphics

struct GameConstants {
    struct Timing {
        static let defaultGameDuration: TimeInterval = 60
        static let easyGameDuration: TimeInterval = 90
        static let hardGameDuration: TimeInterval = 45
    }
    
    struct Scoring {
        static let correctAnswerPoints = 10
        static let timeBonus = 5
        static let streakMultiplier = 2
    }
    
    struct Animation {
        static let sliceAnimationDuration: TimeInterval = 0.3
        static let problemAppearDuration: TimeInterval = 0.5
        static let explosionDuration: TimeInterval = 1.0
    }
    
    struct Layout {
        static let problemSpacing: CGFloat = 80
        static let minProblemSize: CGSize = CGSize(width: 120, height: 80)
        static let maxProblemsOnScreen = 3
    }
}