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
    private var problemNodes: [UUID: FruitProblemNode] = [:]
    
    // Slice tracking
    private var slicePath: CGMutablePath?
    private var slicePathNode: SKShapeNode?
    
    // Game state
    private var isGamePaused: Bool = false
    
    override func didMove(to view: SKView) {
        setupScene()
        setupBackground()
        setupNinja()
    }
    
    private func setupScene() {
        backgroundColor = UIColor(red: 0.1, green: 0.2, blue: 0.4, alpha: 1.0) // Night sky
        scaleMode = .aspectFill
    }
    
    private func setupBackground() {
        // Add dojo background elements
        addFloatingElements()
    }
    
    private func setupNinja() {
        ninjaCharacter = NinjaCharacter()
        
        // Position ninja in bottom left corner
        let screenBounds = UIScreen.main.bounds
        ninjaCharacter?.position = CGPoint(x: 80, y: 120) // Closer to edge
        ninjaCharacter?.zPosition = 100
        
        if let ninja = ninjaCharacter {
            addChild(ninja)
        }
        
        // Add bad guy in top right corner
        let badGuy = BadGuyCharacter()
        badGuy.position = CGPoint(x: screenBounds.width - 80, y: screenBounds.height - 150)
        badGuy.zPosition = 100
        badGuy.name = "badGuy"
        addChild(badGuy)
        
        print("🥷 Ninja and 😈 Bad guy added to scene")
    }

    private func sliceFruitNode(_ fruitNode: FruitProblemNode) {
        fruitNode.slice { [weak self] selectedAnswer in
            if let problem = fruitNode.problem {
                let isCorrect = problem.isCorrectAnswer(selectedAnswer)
                
                // Both characters react
                if isCorrect {
                    self?.ninjaCharacter?.celebrate()
                    // Bad guy gets angry when ninja succeeds
                    if let badGuy = self?.childNode(withName: "badGuy") as? BadGuyCharacter {
                        badGuy.reactToCorrectAnswer()
                    }
                } else {
                    self?.ninjaCharacter?.showDisappointment()
                    // Bad guy laughs when ninja fails
                    if let badGuy = self?.childNode(withName: "badGuy") as? BadGuyCharacter {
                        badGuy.reactToWrongAnswer()
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
        // Add some cherry blossoms or stars floating in background
        for _ in 0..<10 {
            let element = SKShapeNode(circleOfRadius: 3)
            element.fillColor = UIColor.systemPink.withAlphaComponent(0.6)
            element.strokeColor = .clear
            
            element.position = CGPoint(
                x: CGFloat.random(in: 0...frame.width),
                y: CGFloat.random(in: 0...frame.height)
            )
            
            element.zPosition = -1
            addChild(element)
            
            // Gentle floating animation
            let float = SKAction.sequence([
                SKAction.moveBy(x: CGFloat.random(in: -50...50), y: 100, duration: 8.0),
                SKAction.moveBy(x: 0, y: -frame.height - 200, duration: 0.1)
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
        slicePathNode?.lineWidth = 6
        slicePathNode?.lineCap = .round
        slicePathNode?.glowWidth = 4
        slicePathNode?.zPosition = 50
        
        addChild(slicePathNode!)
    }
    
    private func continueSlice(to location: CGPoint) {
        slicePath?.addLine(to: location)
        slicePathNode?.path = slicePath
    }
    
    private func checkSliceIntersection(at location: CGPoint) {
        let slicedNodes = nodes(at: location).compactMap { $0.parent as? FruitProblemNode }
        
        for fruitNode in slicedNodes {
            if !fruitNode.isSliced {
                sliceFruitNode(fruitNode)
            }
        }
    }
    
    private func endSlice() {
        // Fade out slice path
        slicePathNode?.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.3),
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
}

// MARK: - Physics Contact Delegate
extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        // Handle any collision logic here if needed
    }
}
