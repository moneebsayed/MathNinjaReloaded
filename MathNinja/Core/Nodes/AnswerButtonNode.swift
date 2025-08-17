//
//  AnswerButtonNode.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/16/25.
//


import SpriteKit
import SwiftUI

class AnswerButtonNode: SKNode {
    let answer: Int
    var isSelected: Bool = false
    var isSelectable: Bool = false
    var onSelection: ((Int) -> Void)?
    
    private let buttonBackground: SKShapeNode
    private let answerLabel: SKLabelNode
    
    init(answer: Int) {
        self.answer = answer
        
        // Create button background
        buttonBackground = SKShapeNode(rectOf: CGSize(width: 35, height: 25), cornerRadius: 6)
        buttonBackground.fillColor = UIColor(white: 0.2, alpha: 1.0)
        buttonBackground.strokeColor = UIColor(white: 0.4, alpha: 1.0)
        buttonBackground.lineWidth = 1
        
        // Create answer label
        answerLabel = SKLabelNode(text: "\(answer)")
        answerLabel.fontName = "AvenirNext-Medium"
        answerLabel.fontSize = 14
        answerLabel.fontColor = .white
        answerLabel.verticalAlignmentMode = .center
        
        super.init()
        
        addChild(buttonBackground)
        addChild(answerLabel)
        
        isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSelectableState(_ selectable: Bool) {
        isSelectable = selectable
        
        if selectable {
            buttonBackground.fillColor = UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 0.8)
            let pulse = SKAction.sequence([
                SKAction.scale(to: 1.1, duration: 0.3),
                SKAction.scale(to: 1.0, duration: 0.3)
            ])
            run(SKAction.repeatForever(pulse))
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isSelectable, !isSelected else { return }
        selectButton()
    }
    
    func simulateSelection() {
        guard isSelectable, !isSelected else { return }
        selectButton()
    }
    
    private func selectButton() {
        isSelected = true
        removeAllActions()
        
        // Visual feedback
        buttonBackground.fillColor = UIColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0)
        let scaleAction = SKAction.scale(to: 1.2, duration: 0.1)
        run(scaleAction)
        
        // Notify selection
        onSelection?(answer)
    }
}
