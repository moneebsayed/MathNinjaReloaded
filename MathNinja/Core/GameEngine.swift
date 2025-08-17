//
//  GameEngine.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/16/25.
//


import Foundation
import GameplayKit
import Combine
import CoreGraphics

class GameEngine: ObservableObject {
    // Published properties for UI
    @Published var score: Int = 0
    @Published var timeRemaining: TimeInterval = 60
    @Published var currentProblems: [MathProblem] = []
    @Published var streak: Int = 0
    @Published var isGameActive: Bool = false
    @Published var isPaused: Bool = false
    @Published var selectedDifficulty: Difficulty = .medium
    
    // Game state
    private var gameTimer: Timer?
    private var problemGenerationTimer: Timer?
    private let maxProblemsOnScreen = 3
    private var totalProblemsGenerated = 0
    
    // GameplayKit components
    private let randomSource = GKRandomSource.sharedRandom()
    
    // Callbacks
    var onGameOver: (() -> Void)?
    var onCorrectAnswer: (() -> Void)?
    var onWrongAnswer: (() -> Void)?
    
    func startGame(difficulty: Difficulty) {
        print("🚀 Starting game with difficulty: \(difficulty)")
        
        selectedDifficulty = difficulty
        timeRemaining = difficulty.gameDuration
        score = 0
        streak = 0
        currentProblems = []
        totalProblemsGenerated = 0
        isGameActive = true
        isPaused = false
        
        startGameTimer()
        startProblemGeneration()
        
        // Generate ONE problem in center of screen
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        
        let centerPosition = CGPoint(x: screenWidth / 2, y: screenHeight / 2)
        let problem = MathProblem(difficulty: difficulty, position: centerPosition)
        currentProblems.append(problem)
        totalProblemsGenerated += 1
        
        print("🎯 Generated initial problem: \(problem.problemText) at \(problem.position)")
        print("✅ Game started with \(currentProblems.count) problem")
    }

    private func generateNewProblem() {
        // Only generate if no problems exist
        guard isGameActive, !isPaused, currentProblems.isEmpty else {
            print("🚫 Cannot generate - Active: \(isGameActive), Paused: \(isPaused), Count: \(currentProblems.count)")
            return
        }
        
        // Generate in center of screen
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        let centerPosition = CGPoint(x: screenWidth / 2, y: screenHeight / 2)
        
        let newProblem = MathProblem(
            difficulty: selectedDifficulty,
            position: centerPosition
        )
        
        currentProblems.append(newProblem)
        totalProblemsGenerated += 1
        
        print("✅ Generated new problem: \(newProblem.problemText) at center")
        print("📝 Current problems count: \(currentProblems.count)")
    }

    private func startProblemGeneration() {
        // Generate new problem immediately when current one is solved
        problemGenerationTimer?.invalidate()
        
        // Check every second if we need a new problem
        problemGenerationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.generateNewProblem()
        }
    }
    
    func pauseGame() {
        guard isGameActive, !isPaused else { return }
        
        isPaused = true
        stopTimers()
    }
    
    func resumeGame() {
        guard isGameActive, isPaused else { return }
        
        isPaused = false
        startGameTimer()
        startProblemGeneration()
    }
    
    func endGame() {
        isGameActive = false
        isPaused = false
        stopTimers()
        onGameOver?()
    }
    
    // MARK: - Problem Management
    
    func removeProblem(_ problem: MathProblem) {
        currentProblems.removeAll { $0.id == problem.id }
    }
    
    func handleAnswerSelection(problem: MathProblem, selectedAnswer: Int) {
        print("🎯 Handling answer: \(selectedAnswer) for problem: \(problem.problemText)")
        
        // Remove the problem first
        removeProblem(problem)
        
        if problem.isCorrectAnswer(selectedAnswer) {
            print("✅ CORRECT ANSWER!")
            handleCorrectAnswer()
        } else {
            print("❌ WRONG ANSWER! Correct was: \(problem.correctAnswer)")
            handleWrongAnswer()
        }
    }

    private func handleCorrectAnswer() {
        // Calculate score with streak multiplier
        let basePoints = GameConstants.Scoring.correctAnswerPoints
        let streakBonus = streak * GameConstants.Scoring.streakMultiplier
        let timeBonus = timeRemaining > 30 ? GameConstants.Scoring.timeBonus : 0
        
        score += basePoints + streakBonus + timeBonus
        streak += 1
        
        print("🎉 Score: +\(basePoints + streakBonus + timeBonus) (Total: \(score), Streak: \(streak))")
        
        onCorrectAnswer?()
    }

    private func handleWrongAnswer() {
        streak = 0
        print("💥 Streak reset! Score remains: \(score)")
        onWrongAnswer?()
    }
    
    // MARK: - Timer Management
    
    private func startGameTimer() {
        // Make sure we stop any existing timer first
        gameTimer?.invalidate()
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // Only decrement time if game is active AND not paused
            guard self.isGameActive && !self.isPaused else { return }
            
            self.timeRemaining -= 1
            
            if self.timeRemaining <= 0 {
                self.endGame()
            }
        }
    }
        
    private func stopTimers() {
        gameTimer?.invalidate()
        problemGenerationTimer?.invalidate()
        gameTimer = nil
        problemGenerationTimer = nil
    }
    
    deinit {
        stopTimers()
    }
}
