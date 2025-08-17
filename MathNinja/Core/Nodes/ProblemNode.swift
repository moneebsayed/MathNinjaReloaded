//
//  ProblemNode.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/16/25.
//


import SpriteKit
import SwiftUI

class ProblemNode: SKNode {
    
    let problem: MathProblem?
    var isSliced: Bool = false
    
    private let cardBackground: SKShapeNode
    private let problemLabel: SKLabelNode
    private var answerNodes: [AnswerNode] = []
    private var isShowingAnswers = false
    private var instructionLabel: SKLabelNode?
    
    init(problem: MathProblem) {
        self.problem = problem
        
        print("🏗️ Creating ProblemNode for: \(problem.problemText)")
        
        // Create main problem card - optimized size
        let cardSize = CGSize(width: 280, height: 120)
        cardBackground = SKShapeNode(rectOf: cardSize, cornerRadius: 16)
        cardBackground.fillColor = UIColor(red: 0.2, green: 0.7, blue: 1.0, alpha: 0.95)
        cardBackground.strokeColor = UIColor(red: 0.0, green: 0.5, blue: 0.8, alpha: 1.0)
        cardBackground.lineWidth = 3
        
        // Add subtle shadow effect
        let shadowCard = SKShapeNode(rectOf: cardSize, cornerRadius: 16)
        shadowCard.fillColor = UIColor.black.withAlphaComponent(0.3)
        shadowCard.position = CGPoint(x: 3, y: -3)
        shadowCard.zPosition = -1
        
        // Create problem label - positioned higher
        problemLabel = SKLabelNode(text: problem.problemText)
        problemLabel.fontName = "AvenirNext-Bold"
        problemLabel.fontSize = 36
        problemLabel.fontColor = .white
        problemLabel.position = CGPoint(x: 0, y: 10) // Moved up slightly
        problemLabel.verticalAlignmentMode = .center
        
        super.init()
        
        // Add shadow first, then main card
        addChild(shadowCard)
        setupNode()
        
        print("✅ ProblemNode created successfully")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupNode() {
        addChild(cardBackground)
        addChild(problemLabel)
        
        // Subtle breathing animation
        let breathe = SKAction.sequence([
            SKAction.scale(to: 1.02, duration: 1.5),
            SKAction.scale(to: 1.0, duration: 1.5)
        ])
        run(SKAction.repeatForever(breathe), withKey: "breathe")
        
        // Setup physics
        let physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 280, height: 120))
        physicsBody.categoryBitMask = 1
        physicsBody.contactTestBitMask = 0
        physicsBody.collisionBitMask = 0
        physicsBody.affectedByGravity = false
        physicsBody.isDynamic = false
        
        self.physicsBody = physicsBody
    }
    
    func slice(completion: @escaping (Int) -> Void) {
        guard !isSliced, let problem = problem else { return }
        isSliced = true
        
        print("✂️ ProblemNode sliced: \(problem.problemText)")
        
        // Stop breathing animation
        removeAction(forKey: "breathe")
        
        // Change to sliced appearance
        cardBackground.fillColor = UIColor(red: 0.6, green: 0.3, blue: 0.9, alpha: 0.95)
        cardBackground.strokeColor = UIColor(red: 0.8, green: 0.4, blue: 1.0, alpha: 1.0)
        
        // Add instruction text - positioned below problem text with proper spacing
        instructionLabel = SKLabelNode(text: "Choose the answer:")
        instructionLabel!.fontName = "AvenirNext-Medium"
        instructionLabel!.fontSize = 16
        instructionLabel!.fontColor = UIColor.white.withAlphaComponent(0.9)
        instructionLabel!.position = CGPoint(x: 0, y: -30) // Better positioned
        instructionLabel!.verticalAlignmentMode = .center
        addChild(instructionLabel!)
        
        // Show answer selection with delay
        let waitAction = SKAction.wait(forDuration: 0.3)
        let showAnswersAction = SKAction.run { [weak self] in
            self?.showAnswerSelection(completion: completion)
        }
        run(SKAction.sequence([waitAction, showAnswersAction]))
    }
    
    private func showAnswerSelection(completion: @escaping (Int) -> Void) {
        guard let problem = problem, !isShowingAnswers else { return }
        isShowingAnswers = true
        
        print("🎯 Showing answer selection for: \(problem.problemText)")
        
        let answers = problem.allAnswers
        
        // Improved 2x2 grid layout with better spacing
        let positions = [
            CGPoint(x: -75, y: -100),   // Top left - more space from card
            CGPoint(x: 75, y: -100),    // Top right
            CGPoint(x: -75, y: -160),   // Bottom left - more vertical space
            CGPoint(x: 75, y: -160)     // Bottom right
        ]
        
        for (index, answer) in answers.enumerated() {
            let answerNode = AnswerNode(
                answer: answer,
                isCorrect: answer == problem.correctAnswer
            )
            
            answerNode.position = positions[index]
            
            answerNode.onSelection = { [weak self] selectedAnswer in
                self?.handleAnswerSelection(selectedAnswer: selectedAnswer, completion: completion)
            }
            
            addChild(answerNode)
            answerNodes.append(answerNode)
            
            // Staggered animation entrance
            answerNode.alpha = 0
            answerNode.setScale(0.1)
            
            let delay = Double(index) * 0.12
            let waitAction = SKAction.wait(forDuration: delay)
            let bounceIn = SKAction.sequence([
                SKAction.scale(to: 1.15, duration: 0.2),
                SKAction.scale(to: 1.0, duration: 0.1)
            ])
            let fadeIn = SKAction.fadeIn(withDuration: 0.3)
            let appearAction = SKAction.group([bounceIn, fadeIn])
            
            answerNode.run(SKAction.sequence([waitAction, appearAction]))
        }
        
        // Auto-select after 8 seconds
        let waitAction = SKAction.wait(forDuration: 8.0)
        let autoSelectAction = SKAction.run { [weak self] in
            if let randomAnswer = answers.randomElement() {
                print("⏰ Auto-selecting answer: \(randomAnswer)")
                self?.handleAnswerSelection(selectedAnswer: randomAnswer, completion: completion)
            }
        }
        
        run(SKAction.sequence([waitAction, autoSelectAction]), withKey: "autoSelect")
    }
    
    private func handleAnswerSelection(selectedAnswer: Int, completion: @escaping (Int) -> Void) {
        guard let problem = problem else { return }
        
        removeAction(forKey: "autoSelect")
        
        print("🎯 Answer selected: \(selectedAnswer) for \(problem.problemText)")
        
        let isCorrect = selectedAnswer == problem.correctAnswer
        
        // Remove instruction text first
        instructionLabel?.removeFromParent()
        
        // Move problem text up to make room for feedback
        problemLabel.position = CGPoint(x: 0, y: 25)
        
        // Enhanced visual feedback with proper spacing
        if isCorrect {
            cardBackground.fillColor = UIColor(red: 0.2, green: 0.8, blue: 0.3, alpha: 0.95)
            cardBackground.strokeColor = UIColor(red: 0.0, green: 0.6, blue: 0.2, alpha: 1.0)
            
            // Add "CORRECT!" text - positioned below problem text
            let correctLabel = SKLabelNode(text: "CORRECT! ✓")
            correctLabel.fontName = "AvenirNext-Bold"
            correctLabel.fontSize = 22
            correctLabel.fontColor = .white
            correctLabel.position = CGPoint(x: 0, y: -15) // Below problem text
            correctLabel.verticalAlignmentMode = .center
            correctLabel.setScale(0)
            addChild(correctLabel)
            
            let popIn = SKAction.scale(to: 1.0, duration: 0.3)
            correctLabel.run(popIn)
            
            print("🎉 CORRECT!")
        } else {
            cardBackground.fillColor = UIColor(red: 0.9, green: 0.3, blue: 0.3, alpha: 0.95)
            cardBackground.strokeColor = UIColor(red: 0.7, green: 0.1, blue: 0.1, alpha: 1.0)
            
            // Add "WRONG!" text with correct answer - properly spaced
            let wrongLabel = SKLabelNode(text: "WRONG!")
            wrongLabel.fontName = "AvenirNext-Bold"
            wrongLabel.fontSize = 20
            wrongLabel.fontColor = .white
            wrongLabel.position = CGPoint(x: 0, y: -10)
            wrongLabel.verticalAlignmentMode = .center
            wrongLabel.setScale(0)
            addChild(wrongLabel)
            
            // Add correct answer below
            let answerLabel = SKLabelNode(text: "Answer: \(problem.correctAnswer)")
            answerLabel.fontName = "AvenirNext-Medium"
            answerLabel.fontSize = 16
            answerLabel.fontColor = UIColor.white.withAlphaComponent(0.9)
            answerLabel.position = CGPoint(x: 0, y: -35)
            answerLabel.verticalAlignmentMode = .center
            answerLabel.setScale(0)
            addChild(answerLabel)
            
            let popIn = SKAction.scale(to: 1.0, duration: 0.3)
            wrongLabel.run(popIn)
            
            // Delayed appearance for answer
            let delayedPopIn = SKAction.sequence([
                SKAction.wait(forDuration: 0.2),
                SKAction.scale(to: 1.0, duration: 0.3)
            ])
            answerLabel.run(delayedPopIn)
            
            print("❌ WRONG! Correct was: \(problem.correctAnswer)")
        }
        
        // Animate answer nodes away
        for answerNode in answerNodes {
            let fadeOut = SKAction.group([
                SKAction.fadeOut(withDuration: 0.3),
                SKAction.scale(to: 0.8, duration: 0.3)
            ])
            answerNode.run(fadeOut) {
                answerNode.removeFromParent()
            }
        }
        answerNodes.removeAll()
        
        // Call completion after showing feedback
        let delayAction = SKAction.wait(forDuration: 1.2) // Slightly longer to read feedback
        let completeAction = SKAction.run {
            completion(selectedAnswer)
        }
        run(SKAction.sequence([delayAction, completeAction]))
        
        // Remove this node with style
        let waitAction = SKAction.wait(forDuration: 1.8)
        let exitAnimation = SKAction.group([
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.scale(to: 1.2, duration: 0.5),
            SKAction.rotate(byAngle: .pi/8, duration: 0.5)
        ])
        let removeAction = SKAction.removeFromParent()
        
        run(SKAction.sequence([waitAction, exitAnimation, removeAction]))
    }
}

