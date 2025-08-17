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
    
    // Node management
    private var problemNodes: [UUID: ProblemNode] = [:]
    private var slicePath: CGMutablePath?
    private var slicePathNode: SKShapeNode?
    
    // Physics and effects
    private var gravity: CGFloat = 300
    
    // Use a different name for our pause state to avoid conflict with SKScene.isPaused
    private var isGamePaused: Bool = false
    
    override func didMove(to view: SKView) {
        setupScene()
        setupPhysics()
        setupBackground()
    }
    
    private func setupScene() {
        backgroundColor = .clear
        scaleMode = .aspectFill
    }
    
    private func setupPhysics() {
        physicsWorld.gravity = CGVector(dx: 0, dy: 0) // NO GRAVITY AT ALL
        physicsWorld.contactDelegate = self
    }

    // Also comment out the cleanup for now
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        // Don't update anything if paused
        guard !isGamePaused else { return }
        
        // DISABLE cleanup for debugging - let problems stay visible
        /*
        let screenHeight = UIScreen.main.bounds.height
        
        for (problemID, node) in problemNodes {
            if node.position.y < -200 {
                print("🗑️ Removing off-screen problem at Y: \(node.position.y)")
                gameEngine?.removeProblem(gameEngine?.currentProblems.first { $0.id == problemID } ?? MathProblem(difficulty: .medium))
                removeProblemNode(for: problemID)
            }
        }
        */
    }
    private func setupBackground() {
        // Add subtle particle effects for ambiance
        if let sparkleEmitter = SKEmitterNode(fileNamed: "SparkleEffect") {
            sparkleEmitter.position = CGPoint(x: frame.midX, y: frame.maxY)
            sparkleEmitter.advanceSimulationTime(10)
            addChild(sparkleEmitter)
        }
    }
    
    // MARK: - Problem Node Management
    
    func removeProblemNode(for problemID: UUID) {
        if let node = problemNodes[problemID] {
            node.removeFromParent()
            problemNodes.removeValue(forKey: problemID)
        }
    }
    
    func updateProblemNodes(with problems: [MathProblem]) {
        print("🎮 GameScene updating with \(problems.count) problems")
        
        // Remove nodes for problems that no longer exist
        let currentProblemIDs = Set(problems.map { $0.id })
        let nodeKeys = Set(problemNodes.keys)
        
        for problemID in nodeKeys.subtracting(currentProblemIDs) {
            print("🗑️ Removing problem node: \(problemID)")
            removeProblemNode(for: problemID)
        }
        
        // Add nodes for new problems
        for problem in problems {
            if problemNodes[problem.id] == nil {
                print("➕ Adding new problem node: \(problem.problemText) at \(problem.position)")
                addProblemNode(for: problem)
            }
        }
        
        print("📊 Total nodes in scene: \(problemNodes.count)")
    }
    
    func addProblemNode(for problem: MathProblem) {
        print("🎯 Creating problem node for: \(problem.problemText)")
        
        let problemNode = ProblemNode(problem: problem)
        problemNode.position = problem.position
        problemNode.name = "problem_\(problem.id)"
        
        addChild(problemNode)
        problemNodes[problem.id] = problemNode
        
        print("✅ Added problem node at position: \(problemNode.position)")
        print("🌳 Scene children count: \(children.count)")
        
        // Apply initial physics
        problemNode.physicsBody?.velocity = problem.velocity
        problemNode.physicsBody?.angularVelocity = problem.rotationSpeed
    }
    
    // MARK: - Pause Management
    
    func setGamePaused(_ paused: Bool) {
        isGamePaused = paused
        
        // Pause/unpause the entire scene
        if paused {
            self.isPaused = true
        } else {
            self.isPaused = false
        }
    }
    
    // MARK: - Touch Handling (Slicing)
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isGamePaused else { return }
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        print("👆 Touch began at: \(location)")
        startSlice(at: location)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isGamePaused else { return }
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        print("✋ Touch moved to: \(location)")
        continueSlice(to: location)
        checkSliceIntersection(at: location)
    }

    private func checkSliceIntersection(at location: CGPoint) {
        let slicedNodes = nodes(at: location).compactMap { $0 as? ProblemNode }
        
        print("🔍 Checking intersection at \(location), found \(slicedNodes.count) problem nodes")
        
        for problemNode in slicedNodes {
            if !problemNode.isSliced {
                print("✂️ Slicing problem node: \(problemNode.problem?.problemText ?? "unknown")")
                sliceProblemNode(problemNode)
            }
        }
    }
        
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isGamePaused else { return }
        endSlice()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isGamePaused else { return }
        endSlice()
    }
    
    // MARK: - Slice Mechanics
    
    private func startSlice(at location: CGPoint) {
        slicePath = CGMutablePath()
        slicePath?.move(to: location)
        
        slicePathNode?.removeFromParent()
        slicePathNode = SKShapeNode()
        slicePathNode?.strokeColor = .systemYellow
        slicePathNode?.lineWidth = 4
        slicePathNode?.lineCap = .round
        slicePathNode?.glowWidth = 2
        
        addChild(slicePathNode!)
    }
    
    private func continueSlice(to location: CGPoint) {
        slicePath?.addLine(to: location)
        slicePathNode?.path = slicePath
    }
        
    private func endSlice() {
        slicePathNode?.removeFromParent()
        slicePathNode = nil
        slicePath = nil
    }
    
    private func sliceProblemNode(_ problemNode: ProblemNode) {
        problemNode.slice { [weak self] selectedAnswer in
            // Handle answer selection
            if let problem = problemNode.problem {
                self?.gameEngine?.handleAnswerSelection(
                    problem: problem,
                    selectedAnswer: selectedAnswer
                )
            }
            
            // Remove node after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                problemNode.removeFromParent()
            }
        }
    }
}

// MARK: - Physics Contact Delegate
extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        // Handle any collision logic here if needed
    }
}
