import Foundation
import GameplayKit
import Combine
import CoreGraphics

class GameEngine: ObservableObject {
    // Published properties for UI
    @Published var lives: Int = 3
    @Published var maxLives: Int = 3
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
    
    // Callbacks - make these weak to prevent retain cycles
    var onGameOver: (() -> Void)?
    var onCorrectAnswer: (() -> Void)?
    var onWrongAnswer: (() -> Void)?
    
    func startGame(difficulty: Difficulty) {
        print("🚀 Starting game with difficulty: \(difficulty)")
        
        // Always update on main thread for @Published properties
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.selectedDifficulty = difficulty
            self.timeRemaining = difficulty.gameDuration
            self.lives = difficulty.numberOfLives
            self.maxLives = difficulty.maxLives
            self.score = 0
            self.streak = 0
            self.currentProblems = []
            self.totalProblemsGenerated = 0
            self.isGameActive = true
            self.isPaused = false
            
            self.startGameTimer()
            self.startProblemGeneration()
            
            // Generate ONE problem in center of screen
            let screenHeight = UIScreen.main.bounds.height
            let screenWidth = UIScreen.main.bounds.width
            
            let centerPosition = CGPoint(x: screenWidth / 2, y: screenHeight / 2)
            let problem = MathProblem(difficulty: difficulty, position: centerPosition)
            self.currentProblems.append(problem)
            self.totalProblemsGenerated += 1
            
            print("🎯 Generated initial problem: \(problem.problemText) at \(problem.position)")
            print("✅ Game started with \(self.currentProblems.count) problem")
        }
    }

    private func startProblemGeneration() {
        // Don't use a timer - generate on demand
        problemGenerationTimer?.invalidate()
        problemGenerationTimer = nil
    }

    // Call this when a problem is removed
    func removeProblem(_ problem: MathProblem) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.currentProblems.removeAll { $0.id == problem.id }
            
            // Generate new problem immediately when one is removed
            if self.currentProblems.isEmpty {
                self.generateNewProblemImmediately()
            }
        }
    }

    private func generateNewProblemImmediately() {
        guard isGameActive, !isPaused else { return }
        
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        let centerPosition = CGPoint(x: screenWidth / 2, y: screenHeight / 2)
        
        let newProblem = MathProblem(
            difficulty: selectedDifficulty,
            position: centerPosition
        )
        
        currentProblems.append(newProblem)
        totalProblemsGenerated += 1
        
        print("✅ Generated new problem immediately: \(newProblem.problemText)")
    }
        
    func pauseGame() {
        guard isGameActive, !isPaused else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.isPaused = true
        }
        stopTimers()
    }
    
    func resumeGame() {
        guard isGameActive, isPaused else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.isPaused = false
        }
        startGameTimer()
        startProblemGeneration()
    }
    
    func endGame() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.isGameActive = false
            self.isPaused = false
        }
        stopTimers()
        onGameOver?()
    }
    
    // MARK: - Problem Management

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
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Calculate score with streak multiplier
            let basePoints = GameConstants.Scoring.correctAnswerPoints
            let streakBonus = self.streak * GameConstants.Scoring.streakMultiplier
            let timeBonus = self.timeRemaining > 30 ? GameConstants.Scoring.timeBonus : 0
            
            self.score += basePoints + streakBonus + timeBonus
            self.streak += 1
            
            print("🎉 Score: +\(basePoints + streakBonus + timeBonus) (Total: \(self.score), Streak: \(self.streak))")
        }
        
        onCorrectAnswer?()
    }

    private func handleWrongAnswer() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            defer {
                if self.lives <= 0 {
                    self.endGame()
                }
            }
            
            self.streak = 0
            self.lives -= 1
            
            print("💥 Streak reset! Score remains: \(self.score)")
        }
        
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
            
            DispatchQueue.main.async {
                self.timeRemaining -= 1
                
                if self.timeRemaining <= 0 {
                    self.endGame()
                }
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
        print("🗑️ GameEngine deinit")
        stopTimers()
    }
}
