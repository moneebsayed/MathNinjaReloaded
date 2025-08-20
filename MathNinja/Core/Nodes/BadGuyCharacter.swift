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
    private var originalPosition: CGPoint = CGPoint.zero
    
    enum BadGuyState {
        case idle, laughing, angry, defeated, running, slashing
    }
    
    override init() {
        // Use the correct bad guy idle asset path
        let initialTexture = SKTexture(imageNamed: "Left - Idle_000")
        badGuySprite = SKSpriteNode(texture: initialTexture)
        
        // INCREASED SIZE - Make bad guy bigger and more menacing
        let originalSize = initialTexture.size()
        if originalSize != CGSize.zero {
            let targetHeight: CGFloat = 140 // Increased from 100
            let aspectRatio = originalSize.width / originalSize.height
            let targetWidth = targetHeight * aspectRatio
            badGuySprite.size = CGSize(width: targetWidth, height: targetHeight)
            print("✅ Enhanced Bad guy sprite loaded with size: \(badGuySprite.size)")
        } else {
            // Fallback size - also bigger
            badGuySprite.size = CGSize(width: 80, height: 140)
            badGuySprite.color = UIColor.systemRed
            print("⚠️ Bad guy texture didn't load, using enhanced fallback")
        }
        
        super.init()
        setupBadGuy()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBadGuy() {
        originalPosition = position
        addChild(badGuySprite)
        startIdleAnimation()
    }
    
    private func setupEvilFeatures() {
        // Enhanced glowing red eyes (bigger)
        let leftEye = SKShapeNode(circleOfRadius: 4) // Increased size
        leftEye.fillColor = .systemRed
        leftEye.strokeColor = .clear
        leftEye.position = CGPoint(x: -12, y: 20) // Adjusted for bigger sprite
        leftEye.alpha = 0.9
        
        let rightEye = SKShapeNode(circleOfRadius: 4)
        rightEye.fillColor = .systemRed
        rightEye.strokeColor = .clear
        rightEye.position = CGPoint(x: 12, y: 20)
        rightEye.alpha = 0.9
        
        // Enhanced evil aura (bigger)
        let aura = SKShapeNode(circleOfRadius: 75) // Increased radius
        aura.fillColor = UIColor.systemRed.withAlphaComponent(0.06)
        aura.strokeColor = UIColor.systemRed.withAlphaComponent(0.18)
        aura.lineWidth = 2
        aura.zPosition = -1
        
        addChild(aura)
        addChild(leftEye)
        addChild(rightEye)
        
        // Enhanced eye glow
        let glowUp = SKAction.scale(to: 1.4, duration: 1.5)
        let glowDown = SKAction.scale(to: 1.0, duration: 1.5)
        let eyeGlow = SKAction.sequence([glowUp, glowDown])
        
        leftEye.run(SKAction.repeatForever(eyeGlow))
        rightEye.run(SKAction.repeatForever(eyeGlow))
    }
    
    // PROTECTED: Move → Strike with Slash Sprites → Hurt Sprites → Move Back
    func performEvilStrike(ninjaPosition: CGPoint, completion: @escaping () -> Void) {
        // PROTECTION: Reset position and clear any ongoing actions first
        removeAllActions()
        position = originalPosition
        currentState = .running
        
        print("👹 Protected bad guy evil sequence starting...")
        
        // Calculate strike position (close to ninja)
        let strikePosition = CGPoint(x: ninjaPosition.x + 70, y: ninjaPosition.y)
        
        // STEP 1: MOVE to target (simple move, no complex animations)
        let moveToTarget = SKAction.move(to: strikePosition, duration: 0.8)
        
        // STEP 2: STRIKE with proper slashing sprites
        let strikeAndHurt = SKAction.run { [weak self] in
            guard let self = self else { return }
            self.currentState = .slashing
            
            // Use bad guy slashing sprites
            let slashFrames = TextureCache.shared.getTextures(for: "Left - Slashing_", count: 12, padWidth: 3)
            let badGuySlashAnimation: SKAction
            
            if !slashFrames.isEmpty {
                badGuySlashAnimation = SKAction.animate(with: slashFrames, timePerFrame: 0.05)
            } else {
                badGuySlashAnimation = SKAction.sequence([
                    SKAction.rotate(byAngle: -.pi/4, duration: 0.1),
                    SKAction.rotate(byAngle: .pi/4, duration: 0.2),
                    SKAction.rotate(byAngle: 0, duration: 0.1)
                ])
            }
            
            // Simple strike motion
            let strikeMotion = SKAction.sequence([
                SKAction.moveBy(x: -15, y: 0, duration: 0.1),
                SKAction.moveBy(x: 15, y: 0, duration: 0.2)
            ])
            
            let badGuyAttack = SKAction.group([badGuySlashAnimation, strikeMotion])
            self.run(badGuyAttack)
            
            print("⚔️ Bad guy strikes with slash sprites!")
        }
        
        // STEP 3: MOVE BACK to original position
        let moveBack = SKAction.move(to: originalPosition, duration: 0.8)
        
        // STEP 4: Final evil celebration
        let finalCelebration = SKAction.run { [weak self] in
            self?.reactToWrongAnswer()
            completion()
        }
        
        // Execute in correct sequence: MOVE → STRIKE → MOVE BACK → CELEBRATE
        let fullSequence = SKAction.sequence([
            moveToTarget,
            SKAction.wait(forDuration: 0.1),
            strikeAndHurt,
            SKAction.wait(forDuration: 0.6),
            moveBack,
            finalCelebration
        ])
        
        run(fullSequence, withKey: "evilSequence") // Named key for protection
    }

    // PROTECTED hurt reaction with proper hurt sprites - FIXED
    func getSlashedByNinja(completion: @escaping () -> Void) {
        // PROTECTION: Don't interrupt if already in middle of evil sequence
        if action(forKey: "evilSequence") != nil {
            print("⚠️ Bad guy evil sequence in progress, skipping hurt")
            completion()
            return
        }
        
        removeAllActions()
        currentState = .angry
        
        print("😡💥 Protected bad guy hurt sequence with sprites!")
        
        // Use bad guy hurt sprites
        let hurtFrames = TextureCache.shared.getTextures(for: "Left - Hurt_", count: 12, padWidth: 3)
        let hurtAnimation: SKAction
        
        if !hurtFrames.isEmpty {
            hurtAnimation = SKAction.animate(with: hurtFrames, timePerFrame: 0.08)
        } else {
            hurtAnimation = SKAction.sequence([
                SKAction.rotate(byAngle: .pi/8, duration: 0.1),
                SKAction.rotate(byAngle: -.pi/4, duration: 0.2),
                SKAction.rotate(byAngle: 0, duration: 0.1)
            ])
        }
        
        let knockback = SKAction.sequence([
            SKAction.moveBy(x: 25, y: 0, duration: 0.2),
            SKAction.moveBy(x: -25, y: 0, duration: 0.3)
        ])
        
        let colorFlash = SKAction.sequence([
            SKAction.colorize(with: .purple, colorBlendFactor: 0.5, duration: 0.1),
            SKAction.colorize(with: .white, colorBlendFactor: 0.0, duration: 0.3)
        ])
        
        let hurtReaction = SKAction.group([hurtAnimation, knockback, colorFlash])
        
        // FIXED: Use sequence with completion action instead of withKey + completion
        let hurtSequence = SKAction.sequence([
            hurtReaction,
            SKAction.run {
                self.startIdleAnimation()
                completion()
            }
        ])
        
        run(hurtSequence, withKey: "hurtSequence")
    }

    func reactToWrongAnswer() {
        currentState = .laughing
        removeAllActions()
        
        // ENHANCED evil laughing
        let laughFrames = TextureCache.shared.getTextures(for: "Left - Idle Blinking_", count: 12, padWidth: 3)
        
        if !laughFrames.isEmpty {
            let laughAnimation = SKAction.animate(
                with: laughFrames,
                timePerFrame: 0.08
            )
            
            // BIGGER evil celebration
            let scaleUp = SKAction.scale(to: 1.25, duration: 0.25)
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.25)
            let evilScale = SKAction.sequence([scaleUp, scaleDown])
            
            let evilBounce = SKAction.sequence([
                SKAction.moveBy(x: 0, y: 15, duration: 0.2),
                SKAction.moveBy(x: 0, y: -15, duration: 0.2)
            ])
            
            let darkGlow = SKAction.sequence([
                SKAction.colorize(with: .systemRed, colorBlendFactor: 0.4, duration: 0.3),
                SKAction.colorize(with: .white, colorBlendFactor: 0.0, duration: 0.5)
            ])
            
            let evilLaugh = SKAction.group([laughAnimation, evilScale, evilBounce, darkGlow])
            
            badGuySprite.run(evilLaugh) { [weak self] in
                self?.startIdleAnimation()
            }
        }
        
        print("😈 Enhanced bad guy evil laughter!")
    }
    
    func reactToCorrectAnswer() {
        currentState = .angry
        removeAllActions()
        
        let angryFrames = TextureCache.shared.getTextures(for: "Left - Hurt_", count: 12, padWidth: 3)
        
        if !angryFrames.isEmpty {
            let angryAnimation = SKAction.animate(
                with: angryFrames,
                timePerFrame: 0.1
            )
            
            let shakeLeft = SKAction.moveBy(x: -8, y: 0, duration: 0.1)
            let shakeRight = SKAction.moveBy(x: 16, y: 0, duration: 0.1)
            let shakeBack = SKAction.moveBy(x: -8, y: 0, duration: 0.1)
            let shake = SKAction.sequence([shakeLeft, shakeRight, shakeBack])
            
            let shrink = SKAction.scale(to: 0.85, duration: 0.2)
            let grow = SKAction.scale(to: 1.0, duration: 0.3)
            let shrinkGrow = SKAction.sequence([shrink, grow])
            
            let angerReaction = SKAction.group([angryAnimation, shake, shrinkGrow])
            
            badGuySprite.run(angerReaction) { [weak self] in
                self?.startIdleAnimation()
            }
        }
        
        print("😡 Bad guy is angry at correct answer!")
    }
    
    private func startIdleAnimation() {
        currentState = .idle
        
        let idleFrames = TextureCache.shared.getTextures(for: "Left - Idle_", count: 12, padWidth: 3)
        
        if !idleFrames.isEmpty {
            let idleAnimation = SKAction.animate(
                with: idleFrames,
                timePerFrame: 0.3
            )
            
            let repeatIdle = SKAction.repeatForever(idleAnimation)
            badGuySprite.run(repeatIdle, withKey: "idle")
        } else {
            let hoverUp = SKAction.moveBy(x: 0, y: 4, duration: 2.0)
            let hoverDown = SKAction.moveBy(x: 0, y: -4, duration: 2.0)
            let hover = SKAction.sequence([hoverUp, hoverDown])
            
            badGuySprite.run(SKAction.repeatForever(hover), withKey: "idle")
        }
    }
    
    // Store original position for returning
    func setOriginalPosition(_ pos: CGPoint) {
        originalPosition = pos
    }
    
    // 🔄 NEW: Return to original position method
    func returnToOriginalPosition() {
        print("😈 Bad guy returning to original position: \(originalPosition)")
        
        // Stop any current actions
        removeAllActions()
        
        // Animate back to original position
        let moveAction = SKAction.move(to: originalPosition, duration: 0.5)
        moveAction.timingMode = .easeOut
        
        // Also reset to idle animation
        let resetAction = SKAction.run { [weak self] in
            self?.startIdleAnimation()
        }
        
        let sequence = SKAction.sequence([moveAction, resetAction])
        run(sequence)
    }
}
