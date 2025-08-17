//
//  MathProblem.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/16/25.
//


import Foundation
import GameplayKit
import CoreGraphics

struct MathProblem: Identifiable, Equatable {
    let id = UUID()
    let multiplicand: Int
    let multiplier: Int
    let correctAnswer: Int
    let wrongAnswers: [Int]
    let difficulty: Difficulty
    
    // Visual properties
    var position: CGPoint = .zero
    var velocity: CGVector = .zero
    var rotationSpeed: CGFloat = 0
    var scale: CGFloat = 1.0
    var isSliced: Bool = false
    
    // Display text
    var problemText: String {
        return "\(multiplicand) × \(multiplier)"
    }
    
    // All possible answers (correct + wrong) shuffled
    var allAnswers: [Int] {
        return ([correctAnswer] + wrongAnswers).shuffled()
    }
    
    init(difficulty: Difficulty, position: CGPoint = .zero) {
        self.difficulty = difficulty
        self.position = position
        
        let random = GKRandomSource.sharedRandom()
        
        // Generate numbers based on difficulty
        let maxNum = difficulty.maxNumber
        self.multiplicand = random.nextInt(upperBound: maxNum) + 1
        self.multiplier = random.nextInt(upperBound: maxNum) + 1
        self.correctAnswer = multiplicand * multiplier
        
        // Generate wrong answers that are believable but incorrect
        self.wrongAnswers = Self.generateWrongAnswers(
            correct: correctAnswer,
            multiplicand: multiplicand,
            multiplier: multiplier,
            random: random
        )
        
        // Set physics properties - MUCH slower movement
        self.velocity = CGVector(
            dx: CGFloat.random(in: -10...10), // Very small horizontal drift
            dy: CGFloat.random(in: -20...(-10)) // Very slow downward movement
        )
        self.rotationSpeed = CGFloat.random(in: -0.5...0.5) // Slower rotation
    }
    
    static func generateWrongAnswers(correct: Int, multiplicand: Int, multiplier: Int, random: GKRandomSource) -> [Int] {
        var wrongAnswers: Set<Int> = []
        
        // Strategy 1: Off by one factor
        wrongAnswers.insert((multiplicand + 1) * multiplier)
        wrongAnswers.insert(multiplicand * (multiplier + 1))
        wrongAnswers.insert((multiplicand - 1) * multiplier)
        wrongAnswers.insert(multiplicand * (multiplier - 1))
        
        // Strategy 2: Common mistakes (addition instead of multiplication)
        wrongAnswers.insert(multiplicand + multiplier)
        
        // Strategy 3: Close numbers
        wrongAnswers.insert(correct + random.nextInt(upperBound: 10) + 1)
        wrongAnswers.insert(correct - random.nextInt(upperBound: min(correct, 10)) - 1)
        
        // Remove correct answer if accidentally included
        wrongAnswers.remove(correct)
        
        // Remove any negative or zero answers
        wrongAnswers = wrongAnswers.filter { $0 > 0 }
        
        // Return 3 wrong answers, fill with random if needed
        var result = Array(wrongAnswers.prefix(3))
        while result.count < 3 {
            let randomWrong = correct + random.nextInt(upperBound: 20) - 10
            if randomWrong > 0 && randomWrong != correct && !result.contains(randomWrong) {
                result.append(randomWrong)
            }
        }
        
        return result
    }
    
    func isCorrectAnswer(_ answer: Int) -> Bool {
        return answer == correctAnswer
    }
    
    static func == (lhs: MathProblem, rhs: MathProblem) -> Bool {
        return lhs.id == rhs.id
    }
}
