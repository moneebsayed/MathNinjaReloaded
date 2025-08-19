//
//  StarAnswerNode.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/17/25.
//


import SpriteKit
import SwiftUI

class ShurikenAnswerNode: SKNode {
    let answer: Int
    let isCorrect: Bool
    var onSelection: ((Int) -> Void)?
    
    private let shurikenShape: SKShapeNode
    private let answerLabel: SKLabelNode
    private var isSelected = false
    
    init(answer: Int, isCorrect: Bool) {
        self.answer = answer
        self.isCorrect = isCorrect
        
        // Create shuriken shape
        shurikenShape = SKShapeNode(path: Self.createShurikenPath())
        shurikenShape.fillColor = UIColor.systemGray.withAlphaComponent(0.9)
        shurikenShape.strokeColor = UIColor.systemGray
        shurikenShape.lineWidth = 2
        
        // Create answer label with strong contrast
        answerLabel = SKLabelNode(text: "\(answer)")
        answerLabel.fontName = "AvenirNext-Bold"
        answerLabel.fontSize = 16
        answerLabel.fontColor = UIColor.white
        answerLabel.verticalAlignmentMode = .center
        
        super.init()
        
        setupShuriken()
        
        print("🌟 Created shuriken answer: \(answer)")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupShuriken() {
        addChild(shurikenShape)
        
        // Add black outline to text for readability
        let outlineLabel = SKLabelNode(text: "\(answer)")
        outlineLabel.fontName = "AvenirNext-Bold"
        outlineLabel.fontSize = 16
        outlineLabel.fontColor = UIColor.black
        outlineLabel.verticalAlignmentMode = .center
        outlineLabel.position = CGPoint(x: 1, y: -1)
        outlineLabel.zPosition = -1
        addChild(outlineLabel)
        
        addChild(answerLabel)
        
        // Gentle rotation animation
        let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 4.0)
        let rotateForever = SKAction.repeatForever(rotate)
        shurikenShape.run(rotateForever, withKey: "rotate")
        
        // Enable physics for swipe detection
        let physicsBody = SKPhysicsBody(polygonFrom: Self.createShurikenPath())
        physicsBody.isDynamic = false
        physicsBody.categoryBitMask = 2
        physicsBody.contactTestBitMask = 0
        physicsBody.collisionBitMask = 0
        self.physicsBody = physicsBody
    }
    
    func handleSlice() {
        guard !isSelected else { return }
        isSelected = true
        
        print("🌟 Shuriken sliced: \(answer)")
        
        // Stop rotation
        shurikenShape.removeAction(forKey: "rotate")
        
        // Selection animation - flash and grow
        shurikenShape.fillColor = UIColor.systemOrange
        shurikenShape.strokeColor = UIColor.systemRed
        
        let flash = SKAction.sequence([
            SKAction.colorize(with: UIColor.systemYellow, colorBlendFactor: 0.8, duration: 0.1),
            SKAction.colorize(with: UIColor.systemOrange, colorBlendFactor: 0.0, duration: 0.1)
        ])
        
        let grow = SKAction.scale(to: 1.3, duration: 0.2)
        let shrink = SKAction.scale(to: 1.0, duration: 0.1)
        let pulse = SKAction.sequence([grow, shrink])
        
        let selection = SKAction.group([flash, pulse])
        
        run(selection) {
            self.onSelection?(self.answer)
        }
    }
    
    static func createShurikenPath() -> CGPath {
        let path = CGMutablePath()
        
        // Create 4-pointed shuriken shape
        let outerRadius: CGFloat = 25
        let innerRadius: CGFloat = 8
        let points = 8 // 4 main points + 4 inner points
        
        for i in 0..<points {
            let angle = CGFloat(i) * .pi / 4 // 8 points around circle
            let radius = i % 2 == 0 ? outerRadius : innerRadius
            let x = cos(angle - .pi/2) * radius
            let y = sin(angle - .pi/2) * radius
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        path.closeSubpath()
        return path
    }
}
