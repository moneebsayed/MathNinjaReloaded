//
//  FruitProblemNode.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/17/25.
//

import SpriteKit
import SwiftUI

class FruitProblemNode: SKNode {
    
    let problem: MathProblem?
    var isSliced: Bool = false
    
    private var fruitShape: SKShapeNode
    private var problemLabel: SKLabelNode
    private var textBackground: SKShapeNode
    private var fruitType: FruitType
    private var answerNodes: [ShurikenAnswerNode] = []
    private var isShowingAnswers = false
    
    enum FruitType: CaseIterable {
        case apple, banana, orange, watermelon
        
        var color: UIColor {
            switch self {
            case .apple: return UIColor.systemRed
            case .banana: return UIColor.systemYellow
            case .orange: return UIColor.systemOrange
            case .watermelon: return UIColor.systemGreen
            }
        }
        
        var size: CGSize {
            switch self {
            case .apple: return CGSize(width: 100, height: 100)
            case .banana: return CGSize(width: 120, height: 60)
            case .orange: return CGSize(width: 95, height: 95)
            case .watermelon: return CGSize(width: 140, height: 100)
            }
        }
        
        var juiceColor: UIColor {
            return color.withAlphaComponent(0.7)
        }
    }
    
    init(problem: MathProblem) {
        self.problem = problem
        
        // Randomly select fruit type
        fruitType = FruitType.allCases.randomElement() ?? .apple
        
        // Create fruit shape based on type
        switch fruitType {
        case .apple, .orange:
            fruitShape = SKShapeNode(circleOfRadius: fruitType.size.width / 2)
        case .banana:
            fruitShape = SKShapeNode(rectOf: fruitType.size, cornerRadius: 20)
        case .watermelon:
            fruitShape = SKShapeNode(rectOf: fruitType.size, cornerRadius: 15)
        }
        
        fruitShape.fillColor = fruitType.color
        fruitShape.strokeColor = fruitType.color.withAlphaComponent(0.7)
        fruitShape.lineWidth = 3
        
        // Create text background first
        textBackground = SKShapeNode(rectOf: CGSize(width: 90, height: 35), cornerRadius: 8)
        textBackground.fillColor = UIColor.white.withAlphaComponent(0.95)
        textBackground.strokeColor = UIColor.black
        textBackground.lineWidth = 2
        textBackground.zPosition = 1
        
        // Create main label with proper contrast
        problemLabel = SKLabelNode(text: problem.problemText)
        problemLabel.fontName = "AvenirNext-Bold"
        problemLabel.fontSize = 24
        problemLabel.fontColor = .black  // Black text on white background
        problemLabel.verticalAlignmentMode = .center
        problemLabel.zPosition = 2  // Above background
        
        super.init()
        
        setupFruit()
        
        print("🍎 Created \(fruitType) fruit with problem: \(problem.problemText)")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupFruit() {
        // Add shadow
        let shadow: SKShapeNode
        switch fruitType {
        case .apple, .orange:
            shadow = SKShapeNode(circleOfRadius: fruitType.size.width / 2)
        case .banana:
            shadow = SKShapeNode(rectOf: fruitType.size, cornerRadius: 20)
        case .watermelon:
            shadow = SKShapeNode(rectOf: fruitType.size, cornerRadius: 15)
        }
        
        shadow.fillColor = UIColor.black.withAlphaComponent(0.3)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 3, y: -3)
        shadow.zPosition = -1
        addChild(shadow)
        
        // Add fruit shape
        fruitShape.zPosition = 0
        addChild(fruitShape)
        
        // Add text background and label
        addChild(textBackground)
        addChild(problemLabel)
        
        // Add sparkle effect
        addSparkleEffect()
        
        // Gentle floating animation
        let float = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 10, duration: 2.0),
            SKAction.moveBy(x: 0, y: -10, duration: 2.0)
        ])
        run(SKAction.repeatForever(float), withKey: "float")
        
        // Gentle rotation
        let rotate = SKAction.rotate(byAngle: .pi/6, duration: 4.0)
        let rotateBack = SKAction.rotate(byAngle: -.pi/6, duration: 4.0)
        let rotation = SKAction.sequence([rotate, rotateBack])
        run(SKAction.repeatForever(rotation), withKey: "rotate")
        
        // Setup physics
        let physicsBody = SKPhysicsBody(rectangleOf: fruitType.size)
        physicsBody.categoryBitMask = 1
        physicsBody.contactTestBitMask = 0
        physicsBody.collisionBitMask = 0
        physicsBody.affectedByGravity = false
        physicsBody.isDynamic = false
        
        self.physicsBody = physicsBody
    }
    
    private func addSparkleEffect() {
        let sparkle = SKEmitterNode()
        sparkle.particleTexture = SKTexture(imageNamed: "spark")
        sparkle.particleBirthRate = 3
        sparkle.numParticlesToEmit = 0
        sparkle.particleLifetime = 2.0
        sparkle.particleLifetimeRange = 1.0
        sparkle.particleSpeed = 20
        sparkle.particleSpeedRange = 10
        sparkle.emissionAngle = 0
        sparkle.emissionAngleRange = .pi * 2
        sparkle.particleScale = 0.3
        sparkle.particleScaleRange = 0.2
        sparkle.particleAlpha = 0.8
        sparkle.particleAlphaRange = 0.4
        sparkle.particleAlphaSpeed = -0.5
        sparkle.particleColorSequence = nil
        sparkle.particleColor = UIColor.yellow
        sparkle.particleBlendMode = .add
        sparkle.zPosition = 3
        
        addChild(sparkle)
    }
    
    func slice(completion: @escaping (Int) -> Void) {
        guard !isSliced, let problem = problem else { return }
        isSliced = true
        
        print("✂️ Sliced \(fruitType) fruit: \(problem.problemText)")
        
        // Stop animations
        removeAction(forKey: "float")
        removeAction(forKey: "rotate")
        
        // Create slice effect
        createSliceEffect()
        
        // Split the fruit BUT keep the problem visible
        createFruitPieces()
        
        // Hide only the original fruit shape, KEEP the text visible
        fruitShape.alpha = 0
        // textBackground and problemLabel stay visible!
        
        // Enhance the text visibility for the sliced state
        enhanceTextForSlicedState()
        
        // Show answer selection after slice animation
        let waitAction = SKAction.wait(forDuration: 0.5)
        let showAnswersAction = SKAction.run { [weak self] in
            self?.showAnswerSelection(completion: completion)
        }
        run(SKAction.sequence([waitAction, showAnswersAction]))
    }

    private func enhanceTextForSlicedState() {
        // Make the text even more visible after slicing
        textBackground.fillColor = UIColor.white.withAlphaComponent(0.98) // More opaque
        textBackground.strokeColor = UIColor.black
        textBackground.lineWidth = 3 // Thicker border
        textBackground.zPosition = 15 // Much higher z-position
        
        problemLabel.fontColor = .black
        problemLabel.fontSize = 26 // Slightly bigger
        problemLabel.zPosition = 16 // Above background
        
        // Add a subtle glow to make it stand out more
        let glowUp = SKAction.scale(to: 1.05, duration: 1.0)
        let glowDown = SKAction.scale(to: 1.0, duration: 1.0)
        let glow = SKAction.sequence([glowUp, glowDown])
        
        textBackground.run(SKAction.repeatForever(glow))
    }

    private func createFruitPieces() {
        // Create fruit pieces that fly apart but don't interfere with text
        for i in 0..<2 {
            let piece: SKShapeNode
            let pieceSize = CGSize(
                width: fruitType.size.width * 0.4,
                height: fruitType.size.height * 0.6
            )
            
            switch fruitType {
            case .apple, .orange:
                piece = SKShapeNode(circleOfRadius: pieceSize.width / 2)
            case .banana, .watermelon:
                piece = SKShapeNode(rectOf: pieceSize, cornerRadius: 8)
            }
            
            piece.fillColor = fruitType.color.withAlphaComponent(0.7)
            piece.strokeColor = fruitType.color.withAlphaComponent(0.5)
            piece.lineWidth = 2
            piece.zPosition = -1 // Behind the text
            
            let direction: CGFloat = i == 0 ? -1 : 1
            // Position pieces away from center to avoid covering text
            piece.position = CGPoint(x: direction * 25, y: CGFloat.random(in: -10...10))
            
            addChild(piece)
            
            // Animate pieces flying apart
            let moveAction = SKAction.moveBy(
                x: direction * 180,
                y: CGFloat.random(in: -60...60),
                duration: 1.2
            )
            let rotateAction = SKAction.rotate(byAngle: direction * .pi * 1.5, duration: 1.2)
            let fadeAction = SKAction.fadeOut(withDuration: 1.0)
            let shrinkAction = SKAction.scale(to: 0.2, duration: 1.2)
            
            let pieceAnimation = SKAction.group([moveAction, rotateAction, fadeAction, shrinkAction])
            
            piece.run(pieceAnimation) {
                piece.removeFromParent()
            }
        }
    }

    private func showAnswerSelection(completion: @escaping (Int) -> Void) {
        guard let problem = problem, !isShowingAnswers else { return }
        isShowingAnswers = true
        
        print("🌟 Showing shuriken answers for: \(problem.problemText)")
        
        let answers = problem.allAnswers
        
        // Position shurikens around the visible equation, not covering it
        let positions = [
            CGPoint(x: -120, y: 100),    // Top left - further out
            CGPoint(x: 120, y: 100),     // Top right - further out
            CGPoint(x: -120, y: -100),   // Bottom left - further out
            CGPoint(x: 120, y: -100)     // Bottom right - further out
        ]
        
        for (index, answer) in answers.enumerated() {
            let shurikenNode = ShurikenAnswerNode(
                answer: answer,
                isCorrect: answer == problem.correctAnswer
            )
            
            shurikenNode.position = positions[index]
            shurikenNode.name = "shuriken_\(answer)"
            shurikenNode.zPosition = 12  // Above fruit pieces but below text
            
            shurikenNode.onSelection = { [weak self] selectedAnswer in
                self?.handleAnswerSelection(selectedAnswer: selectedAnswer, completion: completion)
            }
            
            addChild(shurikenNode)
            answerNodes.append(shurikenNode)
            
            // Magical appearance animation
            shurikenNode.alpha = 0
            shurikenNode.setScale(0.1)
            
            let delay = Double(index) * 0.1
            let waitAction = SKAction.wait(forDuration: delay)
            let magicalAppear = SKAction.group([
                SKAction.fadeIn(withDuration: 0.3),
                SKAction.sequence([
                    SKAction.scale(to: 1.2, duration: 0.15),
                    SKAction.scale(to: 1.0, duration: 0.15)
                ])
            ])
            
            shurikenNode.run(SKAction.sequence([waitAction, magicalAppear]))
        }
        
        // Auto-select after 10 seconds (longer time since they need to reference the problem)
        let waitAction = SKAction.wait(forDuration: 10.0)
        let autoSelectAction = SKAction.run { [weak self] in
            if let randomAnswer = answers.randomElement() {
                self?.handleAnswerSelection(selectedAnswer: randomAnswer, completion: completion)
            }
        }
        
        run(SKAction.sequence([waitAction, autoSelectAction]), withKey: "autoSelect")
    }

    private func handleAnswerSelection(selectedAnswer: Int, completion: @escaping (Int) -> Void) {
        guard let problem = problem else { return }
        
        removeAction(forKey: "autoSelect")
        
        let isCorrect = selectedAnswer == problem.correctAnswer
        print("🎯 Selected: \(selectedAnswer), Correct: \(problem.correctAnswer)")
        
        // Remove answer stars with animation
        for starNode in answerNodes {
            let disappear = SKAction.group([
                SKAction.fadeOut(withDuration: 0.3),
                SKAction.scale(to: 0.1, duration: 0.3)
            ])
            starNode.run(disappear) {
                starNode.removeFromParent()
            }
        }
        answerNodes.removeAll()
        
        // Call completion
        completion(selectedAnswer)
        
        // Remove the entire fruit node (including the visible equation) after a brief moment
        let finalDisappear = SKAction.group([
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.scale(to: 1.3, duration: 0.5)
        ])
        
        let waitAndDisappear = SKAction.sequence([
            SKAction.wait(forDuration: 1.0), // Give time to see the result
            finalDisappear,
            SKAction.removeFromParent()
        ])
        
        run(waitAndDisappear)
    }
    
    private func createSliceEffect() {
        // More controlled juice splash effect
        let juiceSplash = SKEmitterNode()
        juiceSplash.particleTexture = SKTexture(imageNamed: "spark")
        juiceSplash.particleBirthRate = 100 // Reduced
        juiceSplash.numParticlesToEmit = 20 // Much less particles
        juiceSplash.particleLifetime = 0.6 // Shorter
        juiceSplash.particleSpeed = 80
        juiceSplash.particleSpeedRange = 30
        juiceSplash.emissionAngle = 0
        juiceSplash.emissionAngleRange = .pi * 2
        juiceSplash.particleScale = 0.3 // Smaller
        juiceSplash.particleScaleSpeed = -0.4
        juiceSplash.particleColor = fruitType.juiceColor
        juiceSplash.particleAlpha = 0.6
        juiceSplash.particleAlphaSpeed = -1.0
        juiceSplash.particleBlendMode = .alpha
        juiceSplash.zPosition = -2 // Behind everything
        
        addChild(juiceSplash)
        
        // Remove splash quickly
        let removeAction = SKAction.sequence([
            SKAction.wait(forDuration: 0.8),
            SKAction.removeFromParent()
        ])
        juiceSplash.run(removeAction)
    }
}
