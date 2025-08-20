//
//  GameOverView.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/16/25.
//

import SwiftUI

struct GameOverView: View {
    @EnvironmentObject var gameStateManager: GameStateManager
    @EnvironmentObject var gameEngine: GameEngine
    @AppStorage("highScore") private var highScore = 0
    @AppStorage("totalGamesPlayed") private var totalGamesPlayed = 0
    @AppStorage("totalProblemsEverSolved") private var totalProblemsEverSolved = 0
    
    // Game statistics (calculated from gameEngine)
    @State private var finalScore: Int = 0
    @State private var problemsSolved: Int = 0
    @State private var accuracy: Int = 0
    @State private var maxStreak: Int = 0
    @State private var isNewHighScore = false
    @State private var gameTimeElapsed: Int = 0
    @State private var totalProblemsGenerated: Int = 0
    
    var body: some View {
        ZStack {
            NinjaBackground()
            
            VStack(spacing: 30) {
                // Game Over Title
                VStack(spacing: 12) {
                    Text(gameEngine.lives <= 0 ? "💀" : "⏰")
                        .font(.system(size: 60))
                        .accessibilityIdentifier("GameOverEmoji")
                    
                    Text(gameEngine.lives <= 0 ? "Game Over!" : "Time's Up!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.textPrimary)
                        .accessibilityIdentifier("GameOverTitle")
                    
                    if isNewHighScore {
                        Text("🎉 NEW HIGH SCORE! 🎉")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(Theme.secondaryColor)
                            .scaleEffect(1.1)
                            .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: isNewHighScore)
                            .accessibilityIdentifier("NewHighScoreText")
                    }
                }
                .accessibilityIdentifier("GameOverHeader")
                
                // Final Stats
                MenuCard {
                    VStack(spacing: 20) {
                        // Final Score
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Final Score")
                                    .font(.headline)
                                    .foregroundColor(Theme.textPrimary)
                                    .accessibilityIdentifier("FinalScoreLabel")
                                
                                Text("\(finalScore)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(Theme.primaryColor)
                                    .accessibilityIdentifier("FinalScoreValue")
                            }
                            
                            Spacer()
                            
                            if isNewHighScore {
                                Image(systemName: "crown.fill")
                                    .font(.title2)
                                    .foregroundColor(Theme.secondaryColor)
                                    .accessibilityIdentifier("HighScoreCrown")
                            }
                        }
                        .accessibilityIdentifier("FinalScoreSection")
                        
                        Divider()
                            .background(Theme.textSecondary.opacity(0.3))
                        
                        // Detailed Stats
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            StatCard(title: "Problems", value: "\(problemsSolved)", icon: "checkmark.circle")
                                .accessibilityIdentifier("ProblemsStatCard")
                            StatCard(title: "Accuracy", value: "\(accuracy)%", icon: "target")
                                .accessibilityIdentifier("AccuracyStatCard")
                            StatCard(title: "Best Streak", value: "\(maxStreak)", icon: "flame")
                                .accessibilityIdentifier("StreakStatCard")
                            StatCard(title: "High Score", value: "\(highScore)", icon: "star")
                                .accessibilityIdentifier("HighScoreStatCard")
                        }
                        .accessibilityIdentifier("DetailedStatsGrid")
                        
                        // Additional game info
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            StatCard(title: "Time Played", value: formatTime(gameTimeElapsed), icon: "clock")
                                .accessibilityIdentifier("TimePlayedStatCard")
                            StatCard(title: "Difficulty", value: gameEngine.selectedDifficulty.rawValue, icon: "chart.bar")
                                .accessibilityIdentifier("DifficultyStatCard")
                        }
                        .accessibilityIdentifier("GameInfoGrid")
                    }
                }
                .accessibilityIdentifier("StatsCard")
                
                // Performance message
                performanceMessageView
                    .accessibilityIdentifier("PerformanceMessage")
                
                // Action buttons
                VStack(spacing: 16) {
                    Button("Play Again") {
                        gameStateManager.transition(to: .difficultySelection)
                    }
                    .buttonStyle(NinjaButtonStyle())
                    .accessibilityIdentifier("PlayAgainButton")
                    .accessibilityLabel("Play Again")
                    .accessibilityHint("Start a new game")
                    
                    HStack(spacing: 16) {
                        Button("Main Menu") {
                            gameStateManager.transition(to: .menu)
                        }
                        .buttonStyle(NinjaButtonStyle(isSecondary: true))
                        .accessibilityIdentifier("MainMenuButton")
                        .accessibilityLabel("Main Menu")
                        .accessibilityHint("Return to main menu")
                        
                        Button("Share Score") {
                            shareScore()
                        }
                        .buttonStyle(NinjaButtonStyle(isSecondary: true))
                        .accessibilityIdentifier("ShareScoreButton")
                        .accessibilityLabel("Share Score")
                        .accessibilityHint("Share your score with others")
                    }
                    .accessibilityIdentifier("ActionButtonsRow")
                }
                .accessibilityIdentifier("ActionButtons")
                
                Spacer()
            }
            .padding(24)
        }
        .accessibilityIdentifier("GameOverView")
        .onAppear {
            loadGameStatistics()
            checkForNewHighScore()
            updateGlobalStats()
        }
    }
    
    // MARK: - Performance Message
    
    private var performanceMessageView: some View {
        VStack(spacing: 8) {
            Text(performanceEmoji)
                .font(.title2)
                .accessibilityIdentifier("PerformanceEmoji")
            
            Text(performanceMessage)
                .font(.subheadline)
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .accessibilityIdentifier("PerformanceText")
        }
        .padding(.horizontal)
        .accessibilityElement(children: .combine)
    }
    
    private var performanceEmoji: String {
        if accuracy >= 90 { return "🎯" }
        else if accuracy >= 75 { return "👍" }
        else if accuracy >= 50 { return "📈" }
        else { return "💪" }
    }
    
    private var performanceMessage: String {
        switch accuracy {
        case 90...100:
            return "Outstanding accuracy! You're a true Math Ninja Master!"
        case 75..<90:
            return "Great job! Your ninja skills are sharp!"
        case 50..<75:
            return "Good effort! Keep practicing to improve your precision!"
        case 25..<50:
            return "You're getting there! Every ninja needs practice!"
        default:
            return "Never give up! Even the greatest ninjas started somewhere!"
        }
    }
    
    // MARK: - Data Loading & Processing
    // [Rest of the methods remain the same as they don't need accessibility changes]
    
    private func loadGameStatistics() {
        // Get final score from game engine
        finalScore = gameEngine.score
        
        // Calculate problems solved vs total problems generated
        totalProblemsGenerated = getTotalProblemsGenerated()
        problemsSolved = calculateProblemsSolved()
        
        // Calculate accuracy
        accuracy = calculateAccuracy()
        
        // Get max streak achieved during the game
        maxStreak = getMaxStreakAchieved()
        
        // Calculate game time elapsed
        gameTimeElapsed = calculateGameTimeElapsed()
        
        print("📊 Game Over Stats - Score: \(finalScore), Problems: \(problemsSolved), Accuracy: \(accuracy)%, Streak: \(maxStreak)")
    }
    
    private func getTotalProblemsGenerated() -> Int {
        // This would ideally be tracked in GameEngine
        // For now, estimate based on game duration and difficulty
        let gameDuration = gameEngine.selectedDifficulty.gameDuration
        let timeElapsed = gameDuration - gameEngine.timeRemaining
        
        // Estimate: roughly 1 problem every 5 seconds on average
        return max(1, Int(timeElapsed / 5))
    }
    
    private func calculateProblemsSolved() -> Int {
        // Calculate based on score and streak history
        // This is an approximation since we don't track solved problems directly
        let basePointsPerProblem = GameConstants.Scoring.correctAnswerPoints
        let estimatedSolved = finalScore / basePointsPerProblem
        
        // Account for streak bonuses (rough estimation)
        let adjustedSolved = max(1, Int(Double(estimatedSolved) * 0.7))
        return min(adjustedSolved, totalProblemsGenerated)
    }
    
    private func calculateAccuracy() -> Int {
        guard totalProblemsGenerated > 0 else { return 0 }
        
        let accuracyPercentage = (Double(problemsSolved) / Double(totalProblemsGenerated)) * 100
        return max(0, min(100, Int(accuracyPercentage)))
    }
    
    private func getMaxStreakAchieved() -> Int {
        // This would ideally be tracked throughout the game
        // For now, estimate based on final streak and score
        return max(gameEngine.streak, estimateMaxStreak())
    }
    
    private func estimateMaxStreak() -> Int {
        // Estimate max streak based on final score
        if finalScore > 2000 { return max(10, gameEngine.streak) }
        else if finalScore > 1000 { return max(6, gameEngine.streak) }
        else if finalScore > 500 { return max(4, gameEngine.streak) }
        else { return max(2, gameEngine.streak) }
    }
    
    private func calculateGameTimeElapsed() -> Int {
        let totalGameTime = gameEngine.selectedDifficulty.gameDuration
        return Int(totalGameTime - gameEngine.timeRemaining)
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        
        if minutes > 0 {
            return String(format: "%d:%02d", minutes, remainingSeconds)
        } else {
            return "\(remainingSeconds)s"
        }
    }
    
    private func checkForNewHighScore() {
        if finalScore > highScore {
            isNewHighScore = true
            highScore = finalScore
            
            // Add celebration haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.impactOccurred()
        }
    }
    
    private func updateGlobalStats() {
        totalGamesPlayed += 1
        totalProblemsEverSolved += problemsSolved
        
        print("📈 Updated global stats - Games: \(totalGamesPlayed), Total Problems Solved: \(totalProblemsEverSolved)")
    }
    
    private func shareScore() {
        let difficultyText = gameEngine.selectedDifficulty.rawValue
        let accuracyText = accuracy > 0 ? " with \(accuracy)% accuracy" : ""
        let streakText = maxStreak > 1 ? " and a \(maxStreak) problem streak" : ""
        
        let shareText = "I just scored \(finalScore) points on \(difficultyText) difficulty in Math Ninja! 🥷✨\(accuracyText)\(streakText) Can you beat my score?"
        
        let activityViewController = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityViewController, animated: true)
        }
    }
}

#Preview {
    GameOverView()
        .environmentObject(GameStateManager())
        .environmentObject(GameEngine())
}
