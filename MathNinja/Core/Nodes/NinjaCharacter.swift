//
//  NinjaCharacter.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/17/25.
//


import SpriteKit
import SwiftUI

class NinjaCharacter: SKNode {
    
    private var ninjaSprite: SKSpriteNode
    private var currentState: NinjaState = .idle
    
    enum NinjaState {
        case idle, celebrating, disappointed, slicing
    }
    
    override init() {
        // Try to load the first idle frame
        let initialTexture = SKTexture(imageNamed: "Front - Idle_000")
        ninjaSprite = SKSpriteNode(texture: initialTexture)
        
        // Fix proportions - make it smaller and preserve aspect ratio
        let originalSize = initialTexture.size()
        let targetHeight: CGFloat = 120
        let aspectRatio = originalSize.width / originalSize.height
        let targetWidth = targetHeight * aspectRatio
        
        ninjaSprite.size = CGSize(width: targetWidth, height: targetHeight)
        
        super.init()
        
        setupNinja()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupNinja() {
        addChild(ninjaSprite)
        startIdleAnimation()
    }
    
    func celebrate() {
        currentState = .celebrating
        removeAllActions()
        
        // Use front idle blinking for celebration
        let celebrationFrames = loadFramesWithPattern("Front - Idle_Blinking_", count: 12, padWidth: 3)
        
        if !celebrationFrames.isEmpty {
            let celebrationAnimation = SKAction.animate(
                with: celebrationFrames,
                timePerFrame: 0.1
            )
            
            // Add jump motion
            let jumpUp = SKAction.moveBy(x: 0, y: 20, duration: 0.3)
            let jumpDown = SKAction.moveBy(x: 0, y: -20, duration: 0.3)
            let jump = SKAction.sequence([jumpUp, jumpDown])
            
            let celebrate = SKAction.group([celebrationAnimation, jump])
            
            ninjaSprite.run(celebrate) { [weak self] in
                self?.startIdleAnimation()
            }
        } else {
            // Fallback celebration
            let scaleUp = SKAction.scale(to: 1.15, duration: 0.2)
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.2)
            let jump = SKAction.moveBy(x: 0, y: 15, duration: 0.2)
            let fall = SKAction.moveBy(x: 0, y: -15, duration: 0.2)
            
            let celebrate = SKAction.group([
                SKAction.sequence([scaleUp, scaleDown]),
                SKAction.sequence([jump, fall])
            ])
            
            ninjaSprite.run(celebrate) { [weak self] in
                self?.startIdleAnimation()
            }
        }
        
        print("🎉 Ninja celebrates!")
    }
    
    func showDisappointment() {
        currentState = .disappointed
        removeAllActions()
        
        // Use hurt animation for disappointment - try both left and front
        var sadFrames = loadFramesWithPattern("Left - Hurt_", count: 12, padWidth: 3)
        if sadFrames.isEmpty {
            sadFrames = loadFramesWithPattern("Front - Hurt_", count: 12, padWidth: 3)
        }
        
        if !sadFrames.isEmpty {
            let sadAnimation = SKAction.animate(
                with: sadFrames,
                timePerFrame: 0.15
            )
            
            let disappointment = sadAnimation
            
            ninjaSprite.run(disappointment) { [weak self] in
                self?.startIdleAnimation()
            }
        } else {
            // Fallback disappointment
            let shake = SKAction.sequence([
                SKAction.rotate(byAngle: -0.1, duration: 0.1),
                SKAction.rotate(byAngle: 0.2, duration: 0.2),
                SKAction.rotate(byAngle: -0.1, duration: 0.1)
            ])
            
            let shrink = SKAction.sequence([
                SKAction.scale(to: 0.9, duration: 0.2),
                SKAction.scale(to: 1.0, duration: 0.2)
            ])
            
            let disappointment = SKAction.group([shake, shrink])
            ninjaSprite.run(disappointment) { [weak self] in
                self?.startIdleAnimation()
            }
        }
        
        print("😔 Ninja shows disappointment!")
    }
    
    func performSliceAnimation() {
        currentState = .slicing
        removeAllActions()
        
        // Use slashing animation - try left first, then front
        var sliceFrames = loadFramesWithPattern("Left - Slashing_", count: 12, padWidth: 3)
        if sliceFrames.isEmpty {
            sliceFrames = loadFramesWithPattern("Right - Slashing_", count: 12, padWidth: 3)
        }
        
        if !sliceFrames.isEmpty {
            let sliceAnimation = SKAction.animate(
                with: sliceFrames,
                timePerFrame: 0.05 // Very fast for slicing
            )
            
            // Add forward motion
            let sliceForward = SKAction.moveBy(x: 10, y: 0, duration: 0.1)
            let sliceBack = SKAction.moveBy(x: -10, y: 0, duration: 0.1)
            let sliceMotion = SKAction.sequence([sliceForward, sliceBack])
            
            let sliceAction = SKAction.group([sliceAnimation, sliceMotion])
            
            ninjaSprite.run(sliceAction) { [weak self] in
                self?.startIdleAnimation()
            }
        } else {
            // Fallback slice
            let slice = SKAction.sequence([
                SKAction.moveBy(x: 15, y: 0, duration: 0.06),
                SKAction.moveBy(x: -15, y: 0, duration: 0.1)
            ])
            
            let tilt = SKAction.sequence([
                SKAction.rotate(byAngle: 0.2, duration: 0.06),
                SKAction.rotate(byAngle: -0.2, duration: 0.1)
            ])
            
            let sliceAction = SKAction.group([slice, tilt])
            ninjaSprite.run(sliceAction) { [weak self] in
                self?.startIdleAnimation()
            }
        }
        
        print("⚔️ Ninja performs slice!")
    }
    
    private func startIdleAnimation() {
        currentState = .idle
        
        // Use regular idle animation
        let idleFrames = loadFramesWithPattern("Front - Idle_", count: 12, padWidth: 3)
        
        if !idleFrames.isEmpty {
            let idleAnimation = SKAction.animate(
                with: idleFrames,
                timePerFrame: 0.3 // Slow and peaceful
            )
            
            let repeatIdle = SKAction.repeatForever(idleAnimation)
            ninjaSprite.run(repeatIdle, withKey: "idle")
        } else {
            // Fallback breathing - very subtle
            let breathe = SKAction.sequence([
                SKAction.scale(to: 1.01, duration: 2.5),
                SKAction.scale(to: 1.0, duration: 2.5)
            ])
            ninjaSprite.run(SKAction.repeatForever(breathe), withKey: "idle")
        }
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
            
            // Check if texture loaded successfully
            if texture.size() != CGSize.zero {
                textures.append(texture)
                print("✅ Loaded ninja texture: \(frameName)")
            } else {
                print("❌ Failed to load ninja texture: \(frameName)")
            }
        }
        
        print("📦 Loaded \(textures.count) ninja textures for pattern: \(prefix)")
        return textures
    }
}
