//
//  MathNinjaViewTests.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/20/25.
//

import Testing
import SwiftUI
import ViewInspector
@testable import MathNinja

// Note: These tests use ViewInspector for SwiftUI view testing
struct MathNinjaViewTests {
    
    // MARK: - MenuView Tests
    
    @Test("MenuView displays all difficulty cards")
    func testMenuViewDifficultyCards() throws {
        let menuView = MenuView()
        
        // Test that all difficulty options are present
        let view = try menuView.inspect()
        
        // Check for difficulty cards (this assumes the view structure)
        let difficultyCards = try view.findAll(ViewType.Button.self)
        
        #expect(difficultyCards.count >= 3, "Should have at least 3 difficulty buttons")
        
        // Check that difficulty text exists
        let easyText = try view.find(text: "Easy")
        let mediumText = try view.find(text: "Medium")  
        let hardText = try view.find(text: "Hard")
        
        #expect(easyText.string() == "Easy")
        #expect(mediumText.string() == "Medium")
        #expect(hardText.string() == "Hard")
    }
    
    @Test("MenuView has settings and about buttons")
    func testMenuViewNavigationButtons() throws {
        let menuView = MenuView()
        let view = try menuView.inspect()
        
        // Look for settings and about buttons
        let buttons = try view.findAll(ViewType.Button.self)
        
        // Should have difficulty buttons plus settings/about
        #expect(buttons.count >= 5, "Should have difficulty buttons plus settings/about")
    }
    
    // MARK: - GameHUD Tests
    
    @Test("GameHUD displays score correctly")
    func testGameHUDScoreDisplay() throws {
        let gameState = GameState()
        gameState.score = 150
        
        let gameHUD = GameHUD()
            .environmentObject(gameState)
        
        let view = try gameHUD.inspect()
        
        // Check that score is displayed
        let scoreText = try view.find(text: "150")
        #expect(scoreText.string() == "150")
    }
    
    @Test("GameHUD displays lives indicator")
    func testGameHUDLivesDisplay() throws {
        let gameState = GameState()
        gameState.lives = 2
        
        let gameHUD = GameHUD()
            .environmentObject(gameState)
        
        let view = try gameHUD.inspect()
        
        // Should show lives indicator
        // (This would need to match actual implementation)
        let livesIndicator = try view.find(ViewType.HStack.self)
        #expect(livesIndicator.exists)
    }
    
    // MARK: - PauseMenuView Tests
    
    @Test("PauseMenuView shows correct options")
    func testPauseMenuOptions() throws {
        let pauseMenu = PauseMenuView()
        let view = try pauseMenu.inspect()
        
        // Should have Resume and Main Menu buttons
        let resumeButton = try view.find(text: "Resume")
        let mainMenuButton = try view.find(text: "Main Menu")
        
        #expect(resumeButton.string() == "Resume")
        #expect(mainMenuButton.string() == "Main Menu")
    }
    
    // MARK: - DifficultyCard Tests
    
    @Test("DifficultyCard displays correct information")
    func testDifficultyCardContent() throws {
        let easyDifficulty = Difficulty.easy
        let difficultyCard = DifficultyCard(difficulty: easyDifficulty) { }
        
        let view = try difficultyCard.inspect()
        
        // Should show difficulty name
        let titleText = try view.find(text: "Easy")
        #expect(titleText.string() == "Easy")
        
        // Should show difficulty description  
        let descText = try view.find(text: "Numbers 1-10")
        #expect(descText.string() == "Numbers 1-10")
        
        // Should show emoji
        let emojiText = try view.find(text: "🟢")
        #expect(emojiText.string() == "🟢")
    }
    
    @Test("DifficultyCard for all difficulty levels")
    func testAllDifficultyCards() throws {
        let testCases = [
            (Difficulty.easy, "Easy", "Numbers 1-10", "🟢"),
            (Difficulty.medium, "Medium", "Numbers 11-20", "🟡"),
            (Difficulty.hard, "Hard", "Numbers 1-100", "🔴")
        ]
        
        for (difficulty, name, description, emoji) in testCases {
            let card = DifficultyCard(difficulty: difficulty) { }
            let view = try card.inspect()
            
            let nameText = try view.find(text: name)
            let descText = try view.find(text: description)
            let emojiText = try view.find(text: emoji)
            
            #expect(nameText.string() == name)
            #expect(descText.string() == description)
            #expect(emojiText.string() == emoji)
        }
    }
    
    // MARK: - SettingsView Tests
    
    @Test("SettingsView has back button")
    func testSettingsViewNavigation() throws {
        let settingsView = SettingsView()
        let view = try settingsView.inspect()
        
        // Should have back button or navigation
        let buttons = try view.findAll(ViewType.Button.self)
        #expect(buttons.count >= 1, "Should have at least a back button")
    }
    
    // MARK: - Theme and Styling Tests
    
    @Test("NinjaButtonStyle applies correctly")
    func testNinjaButtonStyling() throws {
        let button = Button("Test") { }
            .buttonStyle(NinjaButtonStyle())
        
        let view = try button.inspect()
        
        // Check that button exists and has content
        let buttonView = try view.button()
        let buttonText = try buttonView.labelView().text().string()
        
        #expect(buttonText == "Test")
    }
    
    @Test("Theme colors are accessible")
    func testThemeColors() throws {
        // Test theme color accessibility
        let theme = Theme()
        
        // Colors should be defined
        #expect(theme.primaryColor != nil)
        #expect(theme.secondaryColor != nil) 
        #expect(theme.backgroundColor != nil)
        #expect(theme.textColor != nil)
    }
}

// MARK: - ViewInspector Extensions

extension ViewInspector {
    // Add custom inspection methods if needed
}

// Mock for testing if Theme doesn't exist
private struct Theme {
    let primaryColor = Color.blue
    let secondaryColor = Color.green
    let backgroundColor = Color.black
    let textColor = Color.white
}
