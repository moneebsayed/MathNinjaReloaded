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
        // ✅ Tell the app we’re in UI tests so it skips GC auth
        app.launchEnvironment["UITests"] = "1"

        // ✅ Dismiss any first-run alerts/sheets (notifications, Game Center, etc.)
        addUIInterruptionMonitor(withDescription: "System Alerts") { alert in
            if alert.buttons["Allow"].exists { alert.buttons["Allow"].tap(); return true }
            if alert.buttons["OK"].exists { alert.buttons["OK"].tap(); return true }
            if alert.buttons["Continue"].exists { alert.buttons["Continue"].tap(); return true }
            if alert.buttons["Don’t Allow"].exists { alert.buttons["Don’t Allow"].tap(); return true }
            return false
        }

        app.launch()
        app.tap() // trigger interruption monitor if an alert is up
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

        let menu = app.otherElements["MenuView"]
        XCTAssertTrue(menu.waitForExistence(timeout: 10))

        XCTAssertTrue(menu.buttons["StartGame"].exists)
        XCTAssertTrue(menu.buttons["Settings"].exists)
        XCTAssertTrue(menu.buttons["About"].exists)

        // Either of these is fine:
//        // let versionInfo = menu.staticTexts["VersionInfo"]
//        let versionInfo = menu.descendants(matching: .any)["VersionInfo"]
//
//        XCTAssertTrue(versionInfo.waitForExistence(timeout: 5),
//                      "Version info should be visible")
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
        
        // The checkmark is inside a Button, so it may not be exposed as an image node.
        // Query by identifier across ANY element type and wait for it to materialize.
        let selectedIndicator = app.descendants(matching: .any)["EasySelected"]
        XCTAssertTrue(selectedIndicator.waitForExistence(timeout: 3), "Easy difficulty should show selected indicator")
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

        // Ensure the screen is actually shown before asserting children.
        let settingsView = app.descendants(matching: .any)["SettingsView"]
        XCTAssertTrue(settingsView.waitForExistence(timeout: 5), "Settings view should appear")

        // Rows are HStacks surfaced as .otherElement; use type-agnostic lookup + waits.
        let soundEffectsRow = app.descendants(matching: .any)["SoundEffectsRow"]
        let vibrationRow    = app.descendants(matching: .any)["VibrationRow"]
        let showHintsRow    = app.descendants(matching: .any)["ShowHintsRow"]
        let backButton      = app.descendants(matching: .any)["BackButton"]

        XCTAssertTrue(soundEffectsRow.waitForExistence(timeout: 3), "Sound effects setting should be visible")
        XCTAssertTrue(vibrationRow.waitForExistence(timeout: 3), "Vibration setting should be visible")
        XCTAssertTrue(showHintsRow.waitForExistence(timeout: 3), "Show hints setting should be visible")
        XCTAssertTrue(backButton.waitForExistence(timeout: 3), "Back button should be visible")
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

        let gameHUD       = app.otherElements["GameHUD"]
        let scoreDisplay  = app.descendants(matching: .any)["ScoreDisplay"]
        let livesIndicator = app.descendants(matching: .any)["LivesIndicator"]
        let timerDisplay  = app.descendants(matching: .any)["TimerDisplay"]
        let pauseButton   = app.descendants(matching: .any)["PauseButton"]

        // Ensure the HUD fully appears first before asserting anything else.
        XCTAssertTrue(gameHUD.waitForExistence(timeout: 15), "Game HUD should be visible")

        // Nested items can register slightly later; wait explicitly.
        XCTAssertTrue(scoreDisplay.waitForExistence(timeout: 5), "Score display should be visible")
        XCTAssertTrue(livesIndicator.waitForExistence(timeout: 5), "Lives indicator should be visible")
        XCTAssertTrue(timerDisplay.waitForExistence(timeout: 5), "Timer should be visible")

        // For layered buttons, always confirm they are hittable, not just existing.
        XCTAssertTrue(pauseButton.waitForExistence(timeout: 5), "Pause button should be visible")
        XCTAssertTrue(pauseButton.isHittable, "Pause button should be tappable")
    }

    func testPauseButtonFunctionality() throws {
        startEasyGame()

        let gameHUD     = app.otherElements["GameHUD"]
        let pauseButton = app.descendants(matching: .any)["PauseButton"]

        XCTAssertTrue(gameHUD.waitForExistence(timeout: 15), "Game HUD should be visible before interacting")
        XCTAssertTrue(pauseButton.waitForExistence(timeout: 8), "Pause button should be visible")
        XCTAssertTrue(pauseButton.isHittable, "Pause button should be tappable")

        pauseButton.tap()

        // Primary target: modal container with our explicit id
        let pauseMenu = app.descendants(matching: .any)["PauseMenuView"]

        // Fallback target: a stable child inside the modal (in case the wrapper wins focus on some OSes)
        let resumeButton = app.buttons["ResumeButton"]

        let appeared =
            pauseMenu.waitForExistence(timeout: 8) ||
            resumeButton.waitForExistence(timeout: 8)

        XCTAssertTrue(appeared, "Pause menu should appear")
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
