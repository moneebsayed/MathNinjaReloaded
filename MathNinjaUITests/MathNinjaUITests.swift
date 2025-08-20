//
//  MathNinjaUITests.swift
//  MathNinjaUITests
//
//  Created by Moneeb Sayed on 8/15/25.
//

import XCTest

final class MathNinjaUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        handleGameCenterDialog()
    }
    
    override func tearDown() {
        app.terminate()
        super.tearDown()
    }
    
    // MARK: - Game Center Handling
    
    private func handleGameCenterDialog() {
        let gameCenterAlert = app.alerts.firstMatch
        if gameCenterAlert.waitForExistence(timeout: 2) {
            if app.buttons["Not Now"].exists {
                app.buttons["Not Now"].tap()
            } else if app.buttons["Cancel"].exists {
                app.buttons["Cancel"].tap()
            } else if app.buttons["OK"].exists {
                app.buttons["OK"].tap()
            }
        }
        
        let gameCenterSheet = app.sheets.firstMatch
        if gameCenterSheet.waitForExistence(timeout: 2) {
            if app.buttons["Cancel"].exists {
                app.buttons["Cancel"].tap()
            }
        }
    }
    
    // MARK: - App Launch Tests
    
    func testAppLaunchesSuccessfully() throws {
        XCTAssertTrue(app.state == .runningForeground, "App should launch successfully")
        handleGameCenterDialog()
        let menuView = app.otherElements["MenuView"]
        XCTAssertTrue(menuView.waitForExistence(timeout: 20), "Main menu should be visible after launch")
    }
    
    // MARK: - Main Menu Tests
    
    func testMainMenuDisplaysAllElements() throws {
        waitForMainMenu()
        
        let startGameButton = app.buttons["StartGame"]
        let settingsButton = app.buttons["Settings"]
        let aboutButton = app.buttons["About"]
        let versionInfo = app.staticTexts["VersionInfo"]
        
        XCTAssertTrue(startGameButton.exists, "Start Game button should be visible")
        XCTAssertTrue(settingsButton.exists, "Settings button should be visible")
        XCTAssertTrue(aboutButton.exists, "About button should be visible")
        XCTAssertTrue(versionInfo.exists, "Version info should be visible")
    }
    
    func testStartGameNavigatesToDifficultySelection() throws {
        waitForMainMenu()
        
        let startGameButton = app.buttons["StartGame"]
        startGameButton.tap()
        
        let difficultyView = app.otherElements["DifficultySelectionView"]
        XCTAssertTrue(difficultyView.waitForExistence(timeout: 5), "Difficulty selection should appear")
    }
    
    func testDifficultySelectionDisplaysAllOptions() throws {
        navigateToDifficultySelection()
        
        // Use firstMatch to handle potential nested elements
        let easyCard = app.buttons.matching(identifier: "Easy").firstMatch
        let mediumCard = app.buttons.matching(identifier: "Medium").firstMatch
        let hardCard = app.buttons.matching(identifier: "Hard").firstMatch
        let backButton = app.buttons["BackButton"]
        
        XCTAssertTrue(easyCard.exists, "Easy difficulty card should be visible")
        XCTAssertTrue(mediumCard.exists, "Medium difficulty card should be visible")
        XCTAssertTrue(hardCard.exists, "Hard difficulty card should be visible")
        XCTAssertTrue(backButton.exists, "Back button should be visible")
    }
    
    func testDifficultyCardSelection() throws {
        navigateToDifficultySelection()
        
        // Use firstMatch to avoid multiple matching elements
        let easyCard = app.buttons.matching(identifier: "Easy").firstMatch
        easyCard.tap()
        
        let startSelectedButton = app.buttons["StartSelectedGame"]
        XCTAssertTrue(startSelectedButton.waitForExistence(timeout: 3), "Start selected game button should appear")
        
        let selectedIndicator = app.images["EasySelected"]
        XCTAssertTrue(selectedIndicator.exists, "Easy difficulty should show selected indicator")
    }
    
    func testGameLaunchFromDifficultySelection() throws {
        navigateToDifficultySelection()
        
        // Use firstMatch for the Easy button
        let easyCard = app.buttons.matching(identifier: "Easy").firstMatch
        easyCard.tap()
        
        let startSelectedButton = app.buttons["StartSelectedGame"]
        startSelectedButton.waitForExistence(timeout: 3)
        startSelectedButton.tap()
        
        let gameView = app.otherElements["GameView"]
        XCTAssertTrue(gameView.waitForExistence(timeout: 20), "Game view should appear after starting game")
    }
    
    func testBackButtonFromDifficultySelection() throws {
        navigateToDifficultySelection()
        
        let backButton = app.buttons["BackButton"]
        backButton.tap()
        
        waitForMainMenu()
        let menuView = app.otherElements["MenuView"]
        XCTAssertTrue(menuView.exists, "Should return to main menu")
    }
    
    // MARK: - Settings Tests
    
    func testSettingsNavigation() throws {
        waitForMainMenu()
        
        let settingsButton = app.buttons["Settings"]
        settingsButton.tap()
        
        let settingsView = app.otherElements["SettingsView"]
        XCTAssertTrue(settingsView.waitForExistence(timeout: 5), "Settings view should appear")
    }
    
    func testSettingsViewElements() throws {
        navigateToSettings()
        
        let soundEffectsRow = app.otherElements["SoundEffectsRow"]
        let vibrationRow = app.otherElements["VibrationRow"]
        let showHintsRow = app.otherElements["ShowHintsRow"]
        let backButton = app.buttons["BackButton"]
        
        XCTAssertTrue(soundEffectsRow.exists, "Sound effects setting should be visible")
        XCTAssertTrue(vibrationRow.exists, "Vibration setting should be visible")
        XCTAssertTrue(showHintsRow.exists, "Show hints setting should be visible")
        XCTAssertTrue(backButton.exists, "Back button should be visible")
    }
    
    func testSettingsBackNavigation() throws {
        navigateToSettings()
        
        let backButton = app.buttons["BackButton"]
        backButton.tap()
        
        waitForMainMenu()
        let menuView = app.otherElements["MenuView"]
        XCTAssertTrue(menuView.exists, "Should return to main menu")
    }
    
    // MARK: - About Tests
    
    func testAboutNavigation() throws {
        waitForMainMenu()
        
        let aboutButton = app.buttons["About"]
        aboutButton.tap()
        
        let aboutView = app.otherElements["AboutView"]
        XCTAssertTrue(aboutView.waitForExistence(timeout: 5), "About view should appear")
    }
    
    func testAboutViewContent() throws {
        waitForMainMenu()
        
        let aboutButton = app.buttons["About"]
        aboutButton.tap()
        
        let aboutView = app.otherElements["AboutView"]
        aboutView.waitForExistence(timeout: 5)
        
        let doneButton = app.buttons["DoneButton"]
        XCTAssertTrue(doneButton.exists, "Done button should be visible")
    }
    
    func testAboutDismissal() throws {
        waitForMainMenu()
        
        let aboutButton = app.buttons["About"]
        aboutButton.tap()
        
        let doneButton = app.buttons["DoneButton"]
        doneButton.waitForExistence(timeout: 5)
        doneButton.tap()
        
        waitForMainMenu()
        let menuView = app.otherElements["MenuView"]
        XCTAssertTrue(menuView.exists, "Should return to main menu")
    }
    
    // MARK: - Game View Tests
    
    func testGameViewLaunchesWithHUD() throws {
        startEasyGame()
        
        let gameHUD = app.otherElements["GameHUD"]
        let scoreDisplay = app.otherElements["ScoreDisplay"]
        let livesIndicator = app.otherElements["LivesIndicator"]
        let timerDisplay = app.otherElements["TimerDisplay"]
        let pauseButton = app.buttons["PauseButton"]
        
        XCTAssertTrue(gameHUD.waitForExistence(timeout: 15), "Game HUD should be visible")
        XCTAssertTrue(scoreDisplay.exists, "Score display should be visible")
        XCTAssertTrue(livesIndicator.exists, "Lives indicator should be visible")
        XCTAssertTrue(timerDisplay.exists, "Timer should be visible")
        XCTAssertTrue(pauseButton.exists, "Pause button should be visible")
    }
    
    func testPauseButtonFunctionality() throws {
        startEasyGame()
        
        let gameHUD = app.otherElements["GameHUD"]
        gameHUD.waitForExistence(timeout: 15)
        
        let pauseButton = app.buttons["PauseButton"]
        XCTAssertTrue(pauseButton.exists, "Pause button should be visible")
        
        pauseButton.tap()
        
        let pauseMenu = app.otherElements["PauseMenuView"]
        XCTAssertTrue(pauseMenu.waitForExistence(timeout: 5), "Pause menu should appear")
    }
    
    // MARK: - Helper Methods
    
    private func waitForMainMenu() {
        handleGameCenterDialog()
        let menuView = app.otherElements["MenuView"]
        _ = menuView.waitForExistence(timeout: 15)
    }
    
    private func navigateToDifficultySelection() {
        waitForMainMenu()
        let startGameButton = app.buttons["StartGame"]
        startGameButton.tap()
        
        let difficultyView = app.otherElements["DifficultySelectionView"]
        _ = difficultyView.waitForExistence(timeout: 5)
    }
    
    private func navigateToSettings() {
        waitForMainMenu()
        let settingsButton = app.buttons["Settings"]
        settingsButton.tap()
        
        let settingsView = app.otherElements["SettingsView"]
        _ = settingsView.waitForExistence(timeout: 5)
    }
    
    private func startEasyGame() {
        navigateToDifficultySelection()
        
        // Use firstMatch to handle nested button issue
        let easyCard = app.buttons.matching(identifier: "Easy").firstMatch
        easyCard.tap()
        
        let startSelectedButton = app.buttons["StartSelectedGame"]
        startSelectedButton.waitForExistence(timeout: 3)
        startSelectedButton.tap()
        
        let gameView = app.otherElements["GameView"]
        _ = gameView.waitForExistence(timeout: 25)
    }
}
