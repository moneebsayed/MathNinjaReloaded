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
    private var fruitType: FruitType
    private var answerNodes: [StarAnswerNode] = []
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
        
        problemLabel = SKLabelNode(text: problem.problemText)
        problemLabel.fontName = "AvenirNext-Bold"
        problemLabel.fontSize = 26 // Bigger text
        problemLabel.fontColor = .white
        problemLabel.verticalAlignmentMode = .center

        super.init()
        
        setupFruit()
        
        print("🍎 Created \(fruitType) fruit with problem: \(problem.problemText)")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupFruit() {
        // Add shadow - FIXED: Use SKShapeNode instead of SKSpriteNode
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
        addChild(fruitShape)
        
        // Add problem text with better visibility
        addTextOutline()
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
        
        // Split the fruit
        createFruitPieces()
        
        // Hide original fruit
        fruitShape.alpha = 0
        problemLabel.alpha = 0
        
        // Show answer selection after slice animation
        let waitAction = SKAction.wait(forDuration: 0.5)
        let showAnswersAction = SKAction.run { [weak self] in
            self?.showAnswerSelection(completion: completion)
        }
        run(SKAction.sequence([waitAction, showAnswersAction]))
    }
    
    private func createSliceEffect() {
        // Juice splash effect
        let juiceSplash = SKEmitterNode()
        juiceSplash.particleTexture = SKTexture(imageNamed: "spark")
        juiceSplash.particleBirthRate = 200
        juiceSplash.numParticlesToEmit = 50
        juiceSplash.particleLifetime = 1.0
        juiceSplash.particleSpeed = 100
        juiceSplash.particleSpeedRange = 50
        juiceSplash.emissionAngle = 0
        juiceSplash.emissionAngleRange = .pi * 2
        juiceSplash.particleScale = 0.5
        juiceSplash.particleScaleSpeed = -0.3
        juiceSplash.particleColor = fruitType.juiceColor
        juiceSplash.particleAlpha = 0.8
        juiceSplash.particleAlphaSpeed = -0.8
        juiceSplash.particleBlendMode = .alpha
        
        addChild(juiceSplash)
        
        // Remove splash after effect
        let removeAction = SKAction.sequence([
            SKAction.wait(forDuration: 2.0),
            SKAction.removeFromParent()
        ])
        juiceSplash.run(removeAction)
    }
    
    private func createFruitPieces() {
        // Create two fruit pieces that fly apart
        for i in 0..<2 {
            let piece: SKShapeNode
            let pieceSize = CGSize(
                width: fruitType.size.width * 0.6,
                height: fruitType.size.height * 0.8
            )
            
            // Create piece shape matching original fruit
            switch fruitType {
            case .apple, .orange:
                piece = SKShapeNode(circleOfRadius: pieceSize.width / 2)
            case .banana, .watermelon:
                piece = SKShapeNode(rectOf: pieceSize, cornerRadius: 10)
            }
            
            piece.fillColor = fruitType.color
            piece.strokeColor = fruitType.color.withAlphaComponent(0.7)
            piece.lineWidth = 2
            
            let direction: CGFloat = i == 0 ? -1 : 1
            piece.position = CGPoint(x: direction * 10, y: 0)
            
            addChild(piece)
            
            // Animate pieces flying apart
            let moveAction = SKAction.moveBy(
                x: direction * 150,
                y: CGFloat.random(in: -50...50),
                duration: 1.0
            )
            let rotateAction = SKAction.rotate(byAngle: direction * .pi, duration: 1.0)
            let fadeAction = SKAction.fadeOut(withDuration: 1.0)
            
            let pieceAnimation = SKAction.group([moveAction, rotateAction, fadeAction])
            
            piece.run(pieceAnimation) {
                piece.removeFromParent()
            }
        }
    }
    
    private func showAnswerSelection(completion: @escaping (Int) -> Void) {
        guard let problem = problem, !isShowingAnswers else { return }
        isShowingAnswers = true
        
        print("🌟 Showing star answers for: \(problem.problemText)")
        
        let answers = problem.allAnswers
        
        // Position stars in a nice pattern around the sliced fruit
        let positions = [
            CGPoint(x: -80, y: 60),    // Top left
            CGPoint(x: 80, y: 60),     // Top right
            CGPoint(x: -80, y: -60),   // Bottom left
            CGPoint(x: 80, y: -60)     // Bottom right
        ]
        
        for (index, answer) in answers.enumerated() {
            let starNode = StarAnswerNode(
                answer: answer,
                isCorrect: answer == problem.correctAnswer
            )
            
            starNode.position = positions[index]
            
            starNode.onSelection = { [weak self] selectedAnswer in
                self?.handleAnswerSelection(selectedAnswer: selectedAnswer, completion: completion)
            }
            
            addChild(starNode)
            answerNodes.append(starNode)
            
            // Magical appearance animation
            starNode.alpha = 0
            starNode.setScale(0.1)
            
            let delay = Double(index) * 0.15
            let waitAction = SKAction.wait(forDuration: delay)
            let magicalAppear = SKAction.group([
                SKAction.fadeIn(withDuration: 0.4),
                SKAction.sequence([
                    SKAction.scale(to: 1.3, duration: 0.2),
                    SKAction.scale(to: 1.0, duration: 0.2)
                ])
            ])
            
            starNode.run(SKAction.sequence([waitAction, magicalAppear]))
        }
        
        // Auto-select after 10 seconds
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
        
        // Remove fruit node
        let finalDisappear = SKAction.group([
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.scale(to: 1.5, duration: 0.5)
        ])
        
        let waitAndDisappear = SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            finalDisappear,
            SKAction.removeFromParent()
        ])
        
        run(waitAndDisappear)
    }
    
    private func addTextOutline() {
        // Create a semi-transparent background behind text for better readability
        let textBg = SKShapeNode(rectOf: CGSize(width: 100, height: 35), cornerRadius: 8)
        textBg.fillColor = UIColor.black.withAlphaComponent(0.7)
        textBg.strokeColor = UIColor.white.withAlphaComponent(0.8)
        textBg.lineWidth = 2
        textBg.zPosition = -0.5
        addChild(textBg)
        
        // Create stronger text outline effect
        let outlineOffsets = [
            CGPoint(x: -2, y: -2), CGPoint(x: 0, y: -2), CGPoint(x: 2, y: -2),
            CGPoint(x: -2, y: 0),                        CGPoint(x: 2, y: 0),
            CGPoint(x: -2, y: 2),  CGPoint(x: 0, y: 2),  CGPoint(x: 2, y: 2)
        ]
        
        for offset in outlineOffsets {
            let outlineLabel = SKLabelNode(text: problem?.problemText ?? "")
            outlineLabel.fontName = "AvenirNext-Bold"
            outlineLabel.fontSize = 26 // Slightly bigger
            outlineLabel.fontColor = .black
            outlineLabel.verticalAlignmentMode = .center
            outlineLabel.position = offset
            outlineLabel.zPosition = -1
            addChild(outlineLabel)
        }
    }
}
