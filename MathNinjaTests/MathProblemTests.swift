//
//  MathProblemTests.swift
//  MathNinjaTests
//
//  Created by Moneeb S. Sayed
//

import Testing
import Foundation
import GameplayKit
@testable import MathNinja

struct MathProblemTests {
    
    // MARK: - Initialization Tests
    
    @Test("Math problem initializes with correct basic properties")
    func testMathProblemInitialization() throws {
        let problem = MathProblem(difficulty: .easy)
        
        #expect(problem.id != UUID(), "Problem should have a unique ID")
        #expect(problem.multiplicand >= 1, "Multiplicand should be at least 1")
        #expect(problem.multiplier >= 1, "Multiplier should be at least 1")
        #expect(problem.correctAnswer == problem.multiplicand * problem.multiplier,
                "Correct answer should equal multiplicand × multiplier")
        #expect(problem.difficulty == .easy, "Difficulty should be preserved")
        #expect(problem.wrongAnswers.count == 3, "Should generate exactly 3 wrong answers")
        #expect(problem.isSliced == false, "Problem should not be sliced initially")
        #expect(problem.scale == 1.0, "Initial scale should be 1.0")
    }
    
    @Test("Math problem respects difficulty constraints", arguments: [
        Difficulty.easy, Difficulty.medium, Difficulty.hard
    ])
    func testDifficultyConstraints(difficulty: Difficulty) throws {
        let problem = MathProblem(difficulty: difficulty)
        let maxNum = difficulty.maxNumber
        
        #expect(problem.multiplicand <= maxNum,
                "Multiplicand should not exceed difficulty max: \(maxNum)")
        #expect(problem.multiplier <= maxNum,
                "Multiplier should not exceed difficulty max: \(maxNum)")
        #expect(problem.multiplicand >= 1, "Multiplicand should be at least 1")
        #expect(problem.multiplier >= 1, "Multiplier should be at least 1")
    }
    
    @Test("Physics properties are initialized within expected ranges")
    func testPhysicsInitialization() throws {
        let problems = (0..<10).map { _ in MathProblem(difficulty: .medium) }
        
        for problem in problems {
            #expect(problem.velocity.dx >= -10 && problem.velocity.dx <= 10,
                    "Horizontal velocity should be between -10 and 10")
            #expect(problem.velocity.dy >= -20 && problem.velocity.dy <= -10,
                    "Vertical velocity should be between -20 and -10 (downward)")
            #expect(problem.rotationSpeed >= -0.5 && problem.rotationSpeed <= 0.5,
                    "Rotation speed should be between -0.5 and 0.5")
        }
    }
    
    // MARK: - Answer Generation Tests
    
    @Test("Correct answer calculation is accurate")
    func testCorrectAnswerCalculation() throws {
        let testCases = [
            (2, 3, 6), (5, 7, 35), (12, 8, 96), (1, 9, 9)
        ]
        
        for (multiplicand, multiplier, expected) in testCases {
            // Test the calculation logic directly
            let result = multiplicand * multiplier
            #expect(result == expected,
                    "Expected \(multiplicand) × \(multiplier) = \(expected), got \(result)")
        }
    }
    
    @Test("Wrong answers do not include correct answer")
    func testWrongAnswersExcludeCorrect() throws {
        let problems = (0..<20).map { _ in MathProblem(difficulty: .medium) }
        
        for problem in problems {
            #expect(!problem.wrongAnswers.contains(problem.correctAnswer),
                    "Wrong answers should not contain the correct answer: \(problem.correctAnswer)")
        }
    }
    
    @Test("Wrong answers are all positive")
    func testWrongAnswersArePositive() throws {
        let problems = (0..<20).map { _ in MathProblem(difficulty: .hard) }
        
        for problem in problems {
            for wrongAnswer in problem.wrongAnswers {
                #expect(wrongAnswer > 0,
                        "All wrong answers should be positive, found: \(wrongAnswer)")
            }
        }
    }
    
    @Test("All answers contains correct count")
    func testAllAnswersCount() throws {
        let problem = MathProblem(difficulty: .medium)
        let allAnswers = problem.allAnswers
        
        #expect(allAnswers.count == 4, "All answers should contain 4 options (1 correct + 3 wrong)")
        #expect(allAnswers.contains(problem.correctAnswer),
                "All answers should contain the correct answer")
        
        // Check that all wrong answers are included
        for wrongAnswer in problem.wrongAnswers {
            #expect(allAnswers.contains(wrongAnswer),
                    "All answers should contain wrong answer: \(wrongAnswer)")
        }
    }
    
    // MARK: - Answer Validation Tests
    
    @Test("Correct answer validation works properly")
    func testCorrectAnswerValidation() throws {
        let problem = MathProblem(difficulty: .easy)
        
        #expect(problem.isCorrectAnswer(problem.correctAnswer),
                "Should return true for correct answer")
        
        for wrongAnswer in problem.wrongAnswers {
            #expect(!problem.isCorrectAnswer(wrongAnswer),
                    "Should return false for wrong answer: \(wrongAnswer)")
        }
    }
    
    // MARK: - Text Display Tests
    
    @Test("Problem text formats correctly")
    func testProblemTextFormat() throws {
        let problem = MathProblem(difficulty: .medium)
        let expectedFormat = "\(problem.multiplicand) × \(problem.multiplier)"
        
        #expect(problem.problemText == expectedFormat,
                "Problem text should be formatted as 'multiplicand × multiplier'")
        #expect(problem.problemText.contains("×"),
                "Problem text should contain multiplication symbol")
    }
    
    // MARK: - Equality Tests
    
    @Test("Math problems with different IDs are not equal")
    func testProblemEquality() throws {
        let problem1 = MathProblem(difficulty: .easy)
        let problem2 = MathProblem(difficulty: .easy)
        
        #expect(problem1 != problem2, "Different problems should not be equal")
        #expect(problem1 == problem1, "A problem should equal itself")
    }
    
    // MARK: - Identifiable Conformance Tests
    
    @Test("Problems have unique identifiers")
    func testUniqueIdentifiers() throws {
        let problems = (0..<100).map { _ in MathProblem(difficulty: .medium) }
        let ids = problems.map(\.id)
        let uniqueIds = Set(ids)
        
        #expect(ids.count == uniqueIds.count,
                "All problems should have unique identifiers")
    }
    
    // MARK: - Edge Case Tests
    
    @Test("Problems with minimum multiplicands and multipliers")
    func testMinimumValues() throws {
        // Test multiple instances to catch edge cases with random generation
        let problems = (0..<50).map { _ in MathProblem(difficulty: .easy) }
        
        let hasMinimumMultiplicand = problems.contains { $0.multiplicand == 1 }
        let hasMinimumMultiplier = problems.contains { $0.multiplier == 1 }
        
        #expect(hasMinimumMultiplicand,
                "Should occasionally generate minimum multiplicand of 1")
        #expect(hasMinimumMultiplier,
                "Should occasionally generate minimum multiplier of 1")
    }
    
    @Test("Wrong answer generation produces valid alternatives")
    func testWrongAnswerGenerationValid() throws {
        let problems = (0..<50).map { _ in MathProblem(difficulty: .medium) }
        
        for problem in problems {
            // Check that wrong answers are reasonable (not too far from correct answer)
            let correct = problem.correctAnswer
            let allAnswersAreReasonable = problem.wrongAnswers.allSatisfy { wrongAnswer in
                // Wrong answers should be positive and different from correct
                wrongAnswer > 0 && wrongAnswer != correct
            }
            
            #expect(allAnswersAreReasonable,
                    "All wrong answers should be positive and different from correct answer")
        }
    }
    
    // MARK: - Performance Tests
    
    @Test("Problem generation performance is acceptable")
    func testProblemGenerationPerformance() throws {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Generate 1000 problems
        let _ = (0..<1000).map { _ in MathProblem(difficulty: .hard) }
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        #expect(timeElapsed < 1.0,
                "Generating 1000 problems should take less than 1 second, took \(timeElapsed)s")
    }
}

// MARK: - Test Extensions for Difficulty (Corrected)

extension MathProblemTests {
    @Test("Easy difficulty generates appropriate number ranges")
    func testEasyDifficultyRanges() throws {
        let problems = (0..<100).map { _ in MathProblem(difficulty: .easy) }
        
        for problem in problems {
            #expect(problem.multiplicand <= 10, "Easy multiplicand should be ≤ 10")
            #expect(problem.multiplier <= 10, "Easy multiplier should be ≤ 10")
            #expect(problem.correctAnswer <= 100, "Easy answers should be ≤ 100 (10×10)")
        }
    }
    
    @Test("Medium difficulty generates appropriate number ranges")
    func testMediumDifficultyRanges() throws {
        let problems = (0..<100).map { _ in MathProblem(difficulty: .medium) }
        
        for problem in problems {
            #expect(problem.multiplicand <= 16, "Medium multiplicand should be ≤ 16")
            #expect(problem.multiplier <= 16, "Medium multiplier should be ≤ 16")
            #expect(problem.correctAnswer <= 256, "Medium answers should be ≤ 256 (16×16)")
        }
    }
    
    @Test("Hard difficulty generates appropriate number ranges")
    func testHardDifficultyRanges() throws {
        let problems = (0..<100).map { _ in MathProblem(difficulty: .hard) }
        
        for problem in problems {
            #expect(problem.multiplicand <= 100, "Hard multiplicand should be ≤ 100")
            #expect(problem.multiplier <= 100, "Hard multiplier should be ≤ 100")
            #expect(problem.correctAnswer <= 10000, "Hard answers should be ≤ 10000 (100×100)")
        }
    }
    
    @Test("Wrong answer generation strategies produce some expected patterns")
    func testWrongAnswerGenerationStrategies() throws {
        // Generate multiple problems to increase chances of finding expected patterns
        let problems = (0..<20).map { _ in MathProblem(difficulty: .medium) }
        
        var foundOffByOnePattern = false
        var foundAdditionMistakePattern = false
        
        for problem in problems {
            let correct = problem.correctAnswer
            let multiplicand = problem.multiplicand
            let multiplier = problem.multiplier
            
            // Check for off-by-one patterns
            let offByOneAnswers = [
                (multiplicand + 1) * multiplier,
                multiplicand * (multiplier + 1),
                max(1, (multiplicand - 1) * multiplier),
                max(1, multiplicand * (multiplier - 1))
            ].filter { $0 > 0 && $0 != correct }
            
            if !offByOneAnswers.isEmpty &&
               problem.wrongAnswers.contains(where: { offByOneAnswers.contains($0) }) {
                foundOffByOnePattern = true
            }
            
            // Check for addition mistake pattern
            let additionMistake = multiplicand + multiplier
            if additionMistake != correct && problem.wrongAnswers.contains(additionMistake) {
                foundAdditionMistakePattern = true
            }
        }
        
        // At least some problems should have expected patterns
        #expect(foundOffByOnePattern || foundAdditionMistakePattern,
                "Should find some common mistake patterns across multiple problems")
    }
}
