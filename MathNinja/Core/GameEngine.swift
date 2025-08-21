import Foundation
import GameKit
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
    @Published var isGameCenterAuthenticated = false
    @Published var gameCenterError: String?
    
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
        
        // 🔄 NEW: Reset characters when new problem is generated
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.75) {
            NotificationCenter.default.post(name: .resetCharacters, object: nil)
        }
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
            handleCorrectAnswerWithGameCenter()
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
    
    func authenticateGameCenter() async {
        await MainActor.run {
            gameCenterError = nil
        }
        
        // Correct authentication pattern
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            Task { @MainActor in
                guard let self = self else { return }
                
                if let error = error {
                    self.gameCenterError = error.localizedDescription
                    self.isGameCenterAuthenticated = false
                    print("🎮 Game Center authentication error: \(error)")
                } else if let viewController = viewController {
                    // Need to present authentication UI
                    self.isGameCenterAuthenticated = false
                    // Handle authentication UI presentation
                    NotificationCenter.default.post(
                        name: .presentGameCenterAuth,
                        object: viewController
                    )
                } else {
                    // Authentication successful
                    self.isGameCenterAuthenticated = GKLocalPlayer.local.isAuthenticated
                    if self.isGameCenterAuthenticated {
                        self.configureGameCenter()
                        print("🎮 \(GKLocalPlayer.local.alias) is ready to play!")
                    }
                }
            }
        }
    }
    
    private func configureGameCenter() {
        // Configure Game Center access point
        GKAccessPoint.shared.location = .bottomTrailing
        GKAccessPoint.shared.showHighlights = true
        GKAccessPoint.shared.isActive = true
    }
    
    // MARK: - Score Submission (Correct Latest API)
    private func submitScoreToGameCenter() async {
        guard isGameCenterAuthenticated else { return }
        
        do {
            // Use the correct modern API
            try await GKLeaderboard.submitScore(
                score,
                context: 0,
                player: GKLocalPlayer.local,
                leaderboardIDs: ["com.score.multiplyninja"]
            )
            print("🏆 Score \(score) submitted to Game Center")
        } catch {
            print("🏆 Failed to submit score: \(error)")
        }
    }
    
    // MARK: - Achievement Reporting
    private func reportAchievements(_ achievements: [GKAchievement]) async {
        guard !achievements.isEmpty, isGameCenterAuthenticated else { return }
        
        do {
            try await GKAchievement.report(achievements)
            print("🏅 Successfully reported \(achievements.count) achievements")
        } catch {
            print("🏅 Failed to report achievements: \(error)")
        }
    }
    
    private func checkAndReportAchievements() async {
        guard isGameCenterAuthenticated else { return }
        
        var achievementsToReport: [GKAchievement] = []
        
        // Score-based achievements
        let scoreAchievements = [
            (10, "10p"), (25, "25p"), (50, "50p"), (75, "75p")
        ]
        
        for (threshold, identifier) in scoreAchievements {
            if score >= threshold && !hasAchievement(identifier) {
                let achievement = GKAchievement(identifier: identifier)
                achievement.percentComplete = 100.0
                achievement.showsCompletionBanner = true
                achievementsToReport.append(achievement)
                markAchievementEarned(identifier)
            }
        }
        
        // Play count achievements
        let gamesPlayed = getGamesPlayedCount()
        let playCountAchievements = [
            (1, "startAdv"), (10, "beenNice"), (20, "beenWhile"),
            (50, "beenLong"), (100, "superLong")
        ]
        
        for (threshold, identifier) in playCountAchievements {
            if gamesPlayed >= threshold && !hasAchievement(identifier) {
                let achievement = GKAchievement(identifier: identifier)
                achievement.percentComplete = 100.0
                achievement.showsCompletionBanner = true
                achievementsToReport.append(achievement)
                markAchievementEarned(identifier)
            }
        }
        
        await reportAchievements(achievementsToReport)
    }
    
    // MARK: - UserDefaults Helpers
    private func getGamesPlayedCount() -> Int {
        UserDefaults.standard.integer(forKey: "gamesPlayedCount")
    }
    
    private func incrementGamesPlayedCount() {
        let current = getGamesPlayedCount()
        UserDefaults.standard.set(current + 1, forKey: "gamesPlayedCount")
    }
    
    private func hasAchievement(_ identifier: String) -> Bool {
        UserDefaults.standard.bool(forKey: "achievement_\(identifier)")
    }
    
    private func markAchievementEarned(_ identifier: String) {
        UserDefaults.standard.set(true, forKey: "achievement_\(identifier)")
    }
    
    // MARK: - Game Integration Points
    func startGameWithGameCenter(difficulty: Difficulty) {
        incrementGamesPlayedCount()
        startGame(difficulty: difficulty)
        
        Task {
            await checkAndReportAchievements()
        }
    }
    
    // MARK: - Corrected handleCorrectAnswer integration
    private func handleCorrectAnswerWithGameCenter() {
        // Call the original handleCorrectAnswer logic
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Calculate score with streak multiplier (your existing logic)
            let basePoints = GameConstants.Scoring.correctAnswerPoints
            let streakBonus = self.streak * GameConstants.Scoring.streakMultiplier
            let timeBonus = self.timeRemaining > 30 ? GameConstants.Scoring.timeBonus : 0
            
            self.score += basePoints + streakBonus + timeBonus
            self.streak += 1
            
            print("🎉 Score: +\(basePoints + streakBonus + timeBonus) (Total: \(self.score), Streak: \(self.streak))")
        }
        
        onCorrectAnswer?()
        
        // Check achievements after score update
        Task {
            await checkAndReportAchievements()
        }
    }
    
    func endGameWithGameCenter() {
        Task {
            await submitScoreToGameCenter()
            await checkAndReportAchievements()
        }
        endGame()
    }
    
    // MARK: - Public Methods for UI (CORRECTED)
    func showGameCenterDashboard() {
        guard isGameCenterAuthenticated else { return }
        
        // Correct usage with required handler parameter
        GKAccessPoint.shared.trigger {
            print("🎮 Game Center dashboard presented")
            // Handle any post-presentation logic if needed
        }
    }
    
    // Optional: Show specific Game Center sections
    func showGameCenterLeaderboards() {
        guard isGameCenterAuthenticated else { return }
        
        GKAccessPoint.shared.trigger(state: .leaderboards) {
            print("🏆 Game Center leaderboards presented")
        }
    }
    
    func showGameCenterAchievements() {
        guard isGameCenterAuthenticated else { return }
        
        GKAccessPoint.shared.trigger(state: .achievements) {
            print("🏅 Game Center achievements presented")
        }
    }
}

// Add this extension at the end of your GameEngine.swift file
extension Notification.Name {
    static let resetCharacters = Notification.Name("resetCharacters")
    static let presentGameCenterAuth = Notification.Name("presentGameCenterAuth")
}
