//
//  StarAnswerNode.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/17/25.
//


import SpriteKit
import SwiftUI

class StarAnswerNode: SKNode {
    let answer: Int
    let isCorrect: Bool
    var onSelection: ((Int) -> Void)?
    
    private let starShape: SKShapeNode
    private let answerLabel: SKLabelNode
    
    init(answer: Int, isCorrect: Bool) {
        self.answer = answer
        self.isCorrect = isCorrect
        
        // Create star shape manually
        let starPath = CGMutablePath()
        let center = CGPoint.zero
        let outerRadius: CGFloat = 30
        let innerRadius: CGFloat = 15
        let angleStep = CGFloat.pi / 5
        
        for i in 0..<10 {
            let angle = CGFloat(i) * angleStep - CGFloat.pi / 2
            let radius = i % 2 == 0 ? outerRadius : innerRadius
            let x = center.x + cos(angle) * radius
            let y = center.y + sin(angle) * radius
            
            if i == 0 {
                starPath.move(to: CGPoint(x: x, y: y))
            } else {
                starPath.addLine(to: CGPoint(x: x, y: y))
            }
        }
        starPath.closeSubpath()
        
        starShape = SKShapeNode(path: starPath)
        starShape.fillColor = UIColor.systemYellow
        starShape.strokeColor = UIColor.systemOrange
        starShape.lineWidth = 2
        
        // Create answer label
        answerLabel = SKLabelNode(text: "\(answer)")
        answerLabel.fontName = "AvenirNext-Bold"
        answerLabel.fontSize = 18
        answerLabel.fontColor = UIColor.brown
        answerLabel.verticalAlignmentMode = .center
        
        super.init()
        
        addChild(starShape)
        addChild(answerLabel)
        
        // Add glow effect
        addGlowEffect()
        
        isUserInteractionEnabled = true
        
        print("⭐ Created star answer: \(answer)")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addGlowEffect() {
        // Gentle pulsing glow
        let glowUp = SKAction.scale(to: 1.1, duration: 1.0)
        let glowDown = SKAction.scale(to: 1.0, duration: 1.0)
        let glow = SKAction.sequence([glowUp, glowDown])
        
        run(SKAction.repeatForever(glow), withKey: "glow")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("⭐ Star tapped: \(answer)")
        
        removeAction(forKey: "glow")
        
        // Selection animation
        starShape.fillColor = UIColor.systemOrange
        
        let selectAnimation = SKAction.sequence([
            SKAction.scale(to: 1.3, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ])
        
        run(selectAnimation) {
            self.onSelection?(self.answer)
        }
    }
}
