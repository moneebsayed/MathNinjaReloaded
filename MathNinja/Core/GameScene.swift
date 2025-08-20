//
//  GameScene.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/16/25.
//

import SpriteKit
import SwiftUI
import GameplayKit

class GameScene: SKScene {
    
    // Game engine reference
    weak var gameEngine: GameEngine?
    
    // Characters and nodes
    private var ninjaCharacter: NinjaCharacter?
    private var badGuyCharacter: BadGuyCharacter?
    private var problemNodes: [UUID: FruitProblemNode] = [:]
    
    // Slice tracking
    private var slicePath: CGMutablePath?
    private var slicePathNode: SKShapeNode?
    
    // Game state
    private var isGamePaused: Bool = false
    
    override func didMove(to view: SKView) {
        setupScene()
        setupBackground()
        setupCharacters()
        
        // 🔄 Listen for character reset notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCharacterReset),
            name: .resetCharacters,
            object: nil
        )
    }
    
    private func setupScene() {
        backgroundColor = UIColor(red: 0.1, green: 0.2, blue: 0.4, alpha: 1.0)
        scaleMode = .aspectFill
    }
    
    private func setupBackground() {
        addFloatingElements()
    }
    
    private func setupCharacters() {
        let screenBounds = UIScreen.main.bounds
        
        // Setup Ninja (bottom left) - BIGGER and more separated
        ninjaCharacter = NinjaCharacter()
        let ninjaPos = CGPoint(x: 120, y: 160) // More space from edge
        ninjaCharacter?.position = ninjaPos
        ninjaCharacter?.setOriginalPosition(ninjaPos)
        ninjaCharacter?.zPosition = 100
        
        if let ninja = ninjaCharacter {
            addChild(ninja)
        }
        
        // Setup Bad Guy (bottom right) - BIGGER and more separated
        badGuyCharacter = BadGuyCharacter()
        let badGuyPos = CGPoint(x: screenBounds.width - 120, y: 160) // More space, same Y as ninja
        badGuyCharacter?.position = badGuyPos
        badGuyCharacter?.setOriginalPosition(badGuyPos)
        badGuyCharacter?.zPosition = 150
        badGuyCharacter?.name = "badGuy"
        
        if let badGuy = badGuyCharacter {
            addChild(badGuy)
        }
        
        print("🥷 Ninja at: \(ninjaPos) and 😈 Bad guy at: \(badGuyPos)")
    }
    
    // 🔄 NEW: Reset characters to original positions
    @objc private func handleCharacterReset() {
        resetCharactersToOriginalPositions()
    }
    
    func resetCharactersToOriginalPositions() {
        print("🔄 Resetting characters to original positions")
        
        // Reset ninja to original position
        ninjaCharacter?.returnToOriginalPosition()
        
        // Reset bad guy to original position
        badGuyCharacter?.returnToOriginalPosition()
    }
    
    private func sliceFruitNode(_ fruitNode: FruitProblemNode) {
        fruitNode.slice { [weak self] selectedAnswer in
            if let problem = fruitNode.problem {
                let isCorrect = problem.isCorrectAnswer(selectedAnswer)
                
                if isCorrect {
                    // CORRECT: Ninja attacks bad guy
                    if let badGuyPos = self?.badGuyCharacter?.position {
                        // Step 1: Ninja moves and strikes
                        self?.ninjaCharacter?.performVictoryStrike(badGuyPosition: badGuyPos) {
                            print("🎉 Ninja victory sequence complete!")
                        }
                        
                        // Step 2: Bad guy gets hurt (starts slightly after ninja begins striking)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                            self?.badGuyCharacter?.getSlashedByNinja {
                                print("💥 Bad guy hurt sequence complete!")
                            }
                        }
                    }
                } else {
                    // WRONG: Bad guy attacks ninja
                    if let ninjaPos = self?.ninjaCharacter?.position {
                        // Step 1: Bad guy moves and strikes
                        self?.badGuyCharacter?.performEvilStrike(ninjaPosition: ninjaPos) {
                            print("👹 Bad guy victory sequence complete!")
                        }
                        
                        // Step 2: Ninja gets hurt (starts slightly after bad guy begins striking)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                            self?.ninjaCharacter?.getSlashedByBadGuy {
                                print("💥 Ninja hurt sequence complete!")
                            }
                        }
                    }
                }
                
                // Handle answer in game engine
                self?.gameEngine?.handleAnswerSelection(
                    problem: problem,
                    selectedAnswer: selectedAnswer
                )
            }
        }
    }
    
    private func addFloatingElements() {
        // Add some cherry blossoms floating in background
        for _ in 0..<8 {
            let element = SKShapeNode(circleOfRadius: 2)
            element.fillColor = UIColor.systemPink.withAlphaComponent(0.4)
            element.strokeColor = .clear
            
            element.position = CGPoint(
                x: CGFloat.random(in: 0...frame.width),
                y: CGFloat.random(in: 0...frame.height)
            )
            
            element.zPosition = -1
            addChild(element)
            
            // Gentle floating animation
            let float = SKAction.sequence([
                SKAction.moveBy(x: CGFloat.random(in: -30...30), y: 80, duration: 6.0),
                SKAction.moveBy(x: 0, y: -frame.height - 100, duration: 0.1)
            ])
            
            element.run(SKAction.repeatForever(float))
        }
    }
    
    // MARK: - Problem Management
    
    func addProblemNode(for problem: MathProblem) {
        let fruitNode = FruitProblemNode(problem: problem)
        fruitNode.position = problem.position
        fruitNode.name = "problem_\(problem.id)"
        fruitNode.zPosition = 10
        
        addChild(fruitNode)
        problemNodes[problem.id] = fruitNode
        
        print("🍎 Added fruit problem: \(problem.problemText)")
    }
    
    func removeProblemNode(for problemID: UUID) {
        if let node = problemNodes[problemID] {
            node.removeFromParent()
            problemNodes.removeValue(forKey: problemID)
        }
    }
    
    func updateProblemNodes(with problems: [MathProblem]) {
        let currentProblemIDs = Set(problems.map { $0.id })
        let nodeKeys = Set(problemNodes.keys)
        
        // Remove old nodes
        for problemID in nodeKeys.subtracting(currentProblemIDs) {
            removeProblemNode(for: problemID)
        }
        
        // Add new nodes
        for problem in problems {
            if problemNodes[problem.id] == nil {
                addProblemNode(for: problem)
            }
        }
    }
    
    // MARK: - Touch Handling (Slicing)
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isGamePaused else { return }
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        startSlice(at: location)
        ninjaCharacter?.performSliceAnimation()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isGamePaused else { return }
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        continueSlice(to: location)
        checkSliceIntersection(at: location)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isGamePaused else { return }
        endSlice()
    }
    
    // MARK: - Slice Mechanics
    
    private func startSlice(at location: CGPoint) {
        slicePath = CGMutablePath()
        slicePath?.move(to: location)
        
        slicePathNode?.removeFromParent()
        slicePathNode = SKShapeNode()
        slicePathNode?.strokeColor = UIColor.systemYellow.withAlphaComponent(0.8)
        slicePathNode?.lineWidth = 4
        slicePathNode?.lineCap = .round
        slicePathNode?.glowWidth = 2
        slicePathNode?.zPosition = 50
        
        addChild(slicePathNode!)
    }
    
    private func continueSlice(to location: CGPoint) {
        slicePath?.addLine(to: location)
        slicePathNode?.path = slicePath
    }
    
    private func checkSliceIntersection(at location: CGPoint) {
        // Check for fruit slicing first
        let slicedFruits = nodes(at: location).compactMap { $0.parent as? FruitProblemNode }
        
        for fruitNode in slicedFruits {
            if !fruitNode.isSliced {
                sliceFruitNode(fruitNode)
                return
            }
        }
        
        // Check for shuriken slicing
        let slicedShurikens = nodes(at: location).compactMap { node -> ShurikenAnswerNode? in
            if let shuriken = node.parent as? ShurikenAnswerNode {
                return shuriken
            }
            return nil
        }
        
        for shurikenNode in slicedShurikens {
            shurikenNode.handleSlice()
            return
        }
    }
    
    private func endSlice() {
        slicePathNode?.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.25),
            SKAction.removeFromParent()
        ]))
        slicePathNode = nil
        slicePath = nil
    }
        
    // MARK: - Pause Management
    
    func setGamePaused(_ paused: Bool) {
        isGamePaused = paused
        self.isPaused = paused
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        // Game update logic here
    }
    
    // Don't forget to remove observer
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Physics Contact Delegate
extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        // Handle any collision logic here if needed
    }
}
