//
//  AnswerNode.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/16/25.
//

import SpriteKit
import SwiftUI

class AnswerNode: SKNode {
    let answer: Int
    let isCorrect: Bool
    var onSelection: ((Int) -> Void)?
    
    private let background: SKShapeNode
    private let shadowBackground: SKShapeNode
    private let label: SKLabelNode
    
    init(answer: Int, isCorrect: Bool) {
        self.answer = answer
        self.isCorrect = isCorrect
        
        // Optimized button size
        let buttonSize = CGSize(width: 70, height: 50)
        
        // Create shadow
        shadowBackground = SKShapeNode(rectOf: buttonSize, cornerRadius: 12)
        shadowBackground.fillColor = UIColor.black.withAlphaComponent(0.4)
        shadowBackground.position = CGPoint(x: 2, y: -2)
        shadowBackground.zPosition = -1
        
        // Create main background
        background = SKShapeNode(rectOf: buttonSize, cornerRadius: 12)
        background.fillColor = UIColor(red: 0.7, green: 0.4, blue: 0.9, alpha: 0.95)
        background.strokeColor = UIColor(red: 0.5, green: 0.2, blue: 0.7, alpha: 1.0)
        background.lineWidth = 2
        
        // Create label
        label = SKLabelNode(text: "\(answer)")
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 24
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        
        super.init()
        
        addChild(shadowBackground)
        addChild(background)
        addChild(label)
        
        isUserInteractionEnabled = true
        
        print("🔢 Created answer node: \(answer)")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("👆 Answer selected: \(answer)")
        
        // Enhanced selection feedback
        background.fillColor = UIColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 0.95)
        background.strokeColor = UIColor(red: 0.8, green: 0.4, blue: 0.0, alpha: 1.0)
        
        // Selection animation
        let selectAnimation = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.1),
            SKAction.scale(to: 1.05, duration: 0.05)
        ])
        
        run(selectAnimation) {
            self.onSelection?(self.answer)
        }
    }
}
