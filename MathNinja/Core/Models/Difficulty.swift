//
//  Difficulty.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/15/25.
//


import Foundation

enum Difficulty: String, CaseIterable, Identifiable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .easy:
            return "Numbers 1-10"
        case .medium:
            return "Numbers 11-20"
        case .hard:
            return "Numbers 1-100"
        }
    }
    
    var maxNumber: Int {
        switch self {
        case .easy: return 10
        case .medium: return 16
        case .hard: return 100
        }
    }
    
    var numberOfLives: Int {
        switch self {
        case .easy: return 3
        case .medium: return 2
        case .hard: return 1
        }
    }
    
    var maxLives: Int {
        switch self {
        case .easy: return 3
        case .medium: return 2
        case .hard: return 1
        }
    }

    var gameDuration: TimeInterval {
        switch self {
        case .easy: return GameConstants.Timing.easyGameDuration
        case .medium: return GameConstants.Timing.defaultGameDuration
        case .hard: return GameConstants.Timing.hardGameDuration
        }
    }
    
    var emoji: String {
        switch self {
        case .easy: return "🟢"
        case .medium: return "🟡"
        case .hard: return "🔴"
        }
    }
}
