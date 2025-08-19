//
//  BadGuyCharacter.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/17/25.
//


import SpriteKit
import SwiftUI

class BadGuyCharacter: SKNode {
    
    private var badGuySprite: SKSpriteNode
    private var currentState: BadGuyState = .idle
    
    enum BadGuyState {
        case idle, laughing, angry, defeated
    }
    
    override init() {
        // Try to load first bad guy frame - adjust names based on what you have
        let initialTexture = SKTexture(imageNamed: "bad_guy_idle") // Or whatever your first frame is
        badGuySprite = SKSpriteNode(texture: initialTexture)
        
        // Fix proportions for bad guy too
        let originalSize = initialTexture.size()
        let targetHeight: CGFloat = 100
        let aspectRatio = originalSize.width / originalSize.height
        let targetWidth = targetHeight * aspectRatio
        
        badGuySprite.size = CGSize(width: targetWidth, height: targetHeight)
        
        super.init()
        
        setupBadGuy()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBadGuy() {
        addChild(badGuySprite)
        startIdleAnimation()
    }
    
    func reactToWrongAnswer() {
        currentState = .laughing
        removeAllActions()
        
        // Try to find bad guy animation frames - you'll need to check exact names
        let laughFrames = loadFramesWithPattern("bad_guy_laugh_", count: 8, padWidth: 3)
        
        if !laughFrames.isEmpty {
            let laughAnimation = SKAction.animate(
                with: laughFrames,
                timePerFrame: 0.1
            )
            
            // Add evil effects
            let grow = SKAction.scale(to: 1.1, duration: 0.3)
            let shrink = SKAction.scale(to: 1.0, duration: 0.3)
            let pulse = SKAction.sequence([grow, shrink])
            
            let redTint = SKAction.colorize(with: UIColor.systemRed, colorBlendFactor: 0.3, duration: 0.3)
            let normalTint = SKAction.colorize(with: UIColor.white, colorBlendFactor: 0.0, duration: 0.5)
            let evilGlow = SKAction.sequence([redTint, normalTint])
            
            let evilLaugh = SKAction.group([laughAnimation, pulse, evilGlow])
            
            badGuySprite.run(evilLaugh) { [weak self] in
                self?.startIdleAnimation()
            }
        } else {
            // Fallback evil laugh
            let grow = SKAction.scale(to: 1.15, duration: 0.2)
            let shrink = SKAction.scale(to: 1.0, duration: 0.2)
            let laugh = SKAction.sequence([grow, shrink, grow, shrink])
            
            let redTint = SKAction.colorize(with: UIColor.systemRed, colorBlendFactor: 0.3, duration: 0.4)
            let normalTint = SKAction.colorize(with: UIColor.white, colorBlendFactor: 0.0, duration: 0.4)
            let colorChange = SKAction.sequence([redTint, normalTint])
            
            let evilLaugh = SKAction.group([laugh, colorChange])
            badGuySprite.run(evilLaugh) { [weak self] in
                self?.startIdleAnimation()
            }
        }
        
        print("😈 Bad guy laughs evilly!")
    }
    
    func reactToCorrectAnswer() {
        currentState = .angry
        removeAllActions()
        
        // Angry shake with scale change
        let shakeLeft = SKAction.moveBy(x: -4, y: 0, duration: 0.08)
        let shakeRight = SKAction.moveBy(x: 8, y: 0, duration: 0.08)
        let shakeBack = SKAction.moveBy(x: -4, y: 0, duration: 0.08)
        let shake = SKAction.sequence([shakeLeft, shakeRight, shakeBack])
        
        let shrink = SKAction.scale(to: 0.92, duration: 0.12)
        let grow = SKAction.scale(to: 1.0, duration: 0.12)
        let shrinkGrow = SKAction.sequence([shrink, grow])
        
        let angerReaction = SKAction.group([shake, shrinkGrow])
        
        badGuySprite.run(angerReaction) { [weak self] in
            self?.startIdleAnimation()
        }
        
        print("😡 Bad guy is angry!")
    }
    
    private func startIdleAnimation() {
        currentState = .idle
        
        // Simple menacing hover
        let hoverUp = SKAction.moveBy(x: 0, y: 3, duration: 2.5)
        let hoverDown = SKAction.moveBy(x: 0, y: -3, duration: 2.5)
        let hover = SKAction.sequence([hoverUp, hoverDown])
        
        let breathe = SKAction.sequence([
            SKAction.scale(to: 1.01, duration: 2.0),
            SKAction.scale(to: 1.0, duration: 2.0)
        ])
        
        let idleAnimation = SKAction.group([hover, breathe])
        badGuySprite.run(SKAction.repeatForever(idleAnimation), withKey: "idle")
    }
    
    private func loadFramesWithPattern(_ prefix: String, count: Int, padWidth: Int) -> [SKTexture] {
        var textures: [SKTexture] = []
        
        for i in 0..<count {
            let frameName: String
            if padWidth == 3 {
                frameName = String(format: "%@%03d", prefix, i)
            } else {
                frameName = "\(prefix)\(i)"
            }
            
            let texture = SKTexture(imageNamed: frameName)
            
            if texture.size() != CGSize.zero {
                textures.append(texture)
                print("✅ Loaded bad guy texture: \(frameName)")
            } else {
                print("❌ Failed to load bad guy texture: \(frameName)")
            }
        }
        
        print("📦 Loaded \(textures.count) bad guy textures for pattern: \(prefix)")
        return textures
    }
}
