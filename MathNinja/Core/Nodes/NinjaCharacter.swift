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
    private var originalPosition: CGPoint = CGPoint.zero
    
    enum NinjaState {
        case idle, celebrating, disappointed, slicing, running, slashing
    }
    
    override init() {
        // Use the correct ninja idle asset path
        let initialTexture = SKTexture(imageNamed: "Front - Idle_000")
        ninjaSprite = SKSpriteNode(texture: initialTexture)
        
        // INCREASED SIZE - Make ninja bigger
        let originalSize = initialTexture.size()
        if originalSize != CGSize.zero {
            let targetHeight: CGFloat = 140 // Increased from 100
            let aspectRatio = originalSize.width / originalSize.height
            let targetWidth = targetHeight * aspectRatio
            ninjaSprite.size = CGSize(width: targetWidth, height: targetHeight)
            print("✅ Enhanced Ninja sprite loaded with size: \(ninjaSprite.size)")
        } else {
            // Fallback size - also bigger
            ninjaSprite.size = CGSize(width: 80, height: 140)
            ninjaSprite.color = UIColor.systemBlue
            print("⚠️ Ninja texture didn't load, using enhanced fallback")
        }
        
        super.init()
        setupNinja()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupNinja() {
        originalPosition = position
        addChild(ninjaSprite)
        startIdleAnimation()
    }
    
    // PROTECTED: Move → Strike with Slash Sprites → Hurt Sprites → Move Back
    func performVictoryStrike(badGuyPosition: CGPoint, completion: @escaping () -> Void) {
        // PROTECTION: Reset position and clear any ongoing actions first
        removeAllActions()
        position = originalPosition
        currentState = .running
        
        print("🏃‍♂️ Protected ninja victory sequence starting...")
        
        // Calculate strike position (close to bad guy)
        let strikePosition = CGPoint(x: badGuyPosition.x - 70, y: badGuyPosition.y)
        
        // STEP 1: MOVE to target (simple move, no complex animations)
        let moveToTarget = SKAction.move(to: strikePosition, duration: 0.8)
        
        // STEP 2: STRIKE with proper slashing sprites
        let strikeAndHurt = SKAction.run { [weak self] in
            guard let self = self else { return }
            self.currentState = .slashing
            
            // Use ninja slashing sprites
            let slashFrames = TextureCache.shared.getTextures(for: "Front - Slashing_", count: 12, padWidth: 3)
            let ninjaSlashAnimation: SKAction
            
            if !slashFrames.isEmpty {
                ninjaSlashAnimation = SKAction.animate(with: slashFrames, timePerFrame: 0.05)
            } else {
                ninjaSlashAnimation = SKAction.sequence([
                    SKAction.rotate(byAngle: .pi/4, duration: 0.1),
                    SKAction.rotate(byAngle: -.pi/4, duration: 0.2),
                    SKAction.rotate(byAngle: 0, duration: 0.1)
                ])
            }
            
            // Simple strike motion
            let strikeMotion = SKAction.sequence([
                SKAction.moveBy(x: 15, y: 0, duration: 0.1),
                SKAction.moveBy(x: -15, y: 0, duration: 0.2)
            ])
            
            let ninjaAttack = SKAction.group([ninjaSlashAnimation, strikeMotion])
            self.run(ninjaAttack)
            
            print("⚔️ Ninja strikes with slash sprites!")
        }
        
        // STEP 3: MOVE BACK to original position
        let moveBack = SKAction.move(to: originalPosition, duration: 0.8)
        
        // STEP 4: Final celebration
        let finalCelebration = SKAction.run { [weak self] in
            self?.celebrate()
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
        
        run(fullSequence, withKey: "victorySequence") // Named key for protection
    }

    // PROTECTED hurt reaction with proper hurt sprites - FIXED
    func getSlashedByBadGuy(completion: @escaping () -> Void) {
        // PROTECTION: Don't interrupt if already in middle of victory sequence
        if action(forKey: "victorySequence") != nil {
            print("⚠️ Ninja victory in progress, skipping hurt")
            completion()
            return
        }
        
        removeAllActions()
        currentState = .disappointed
        
        print("😵 Protected ninja hurt sequence with sprites!")
        
        // Use ninja hurt sprites
        let hurtFrames = TextureCache.shared.getTextures(for: "Front - Hurt_", count: 12, padWidth: 3)
        let hurtAnimation: SKAction
        
        if !hurtFrames.isEmpty {
            hurtAnimation = SKAction.animate(with: hurtFrames, timePerFrame: 0.08)
        } else {
            hurtAnimation = SKAction.sequence([
                SKAction.rotate(byAngle: -.pi/8, duration: 0.1),
                SKAction.rotate(byAngle: .pi/4, duration: 0.2),
                SKAction.rotate(byAngle: 0, duration: 0.1)
            ])
        }
        
        let knockback = SKAction.sequence([
            SKAction.moveBy(x: -25, y: 0, duration: 0.2),
            SKAction.moveBy(x: 25, y: 0, duration: 0.3)
        ])
        
        let colorFlash = SKAction.sequence([
            SKAction.colorize(with: .red, colorBlendFactor: 0.5, duration: 0.1),
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
    
    func celebrate() {
        currentState = .celebrating
        removeAllActions()
        
        // Enhanced celebration
        let celebrationFrames = TextureCache.shared.getTextures(for: "Front - Idle Blinking_", count: 12, padWidth: 3)
        
        if !celebrationFrames.isEmpty {
            let celebrationAnimation = SKAction.animate(
                with: celebrationFrames,
                timePerFrame: 0.08
            )
            
            // BIGGER celebration effects
            let jumpUp = SKAction.moveBy(x: 0, y: 30, duration: 0.3)
            let jumpDown = SKAction.moveBy(x: 0, y: -30, duration: 0.3)
            let jump = SKAction.sequence([jumpUp, jumpDown])
            
            let scaleUp = SKAction.scale(to: 1.2, duration: 0.3)
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.3)
            let pulse = SKAction.sequence([scaleUp, scaleDown])
            
            let celebrate = SKAction.group([celebrationAnimation, jump, pulse])
            
            ninjaSprite.run(celebrate) { [weak self] in
                self?.startIdleAnimation()
            }
        } else {
            // Enhanced fallback celebration
            let scaleUp = SKAction.scale(to: 1.3, duration: 0.2)
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.2)
            let jump = SKAction.moveBy(x: 0, y: 25, duration: 0.2)
            let fall = SKAction.moveBy(x: 0, y: -25, duration: 0.2)
            
            let celebrate = SKAction.group([
                SKAction.sequence([scaleUp, scaleDown]),
                SKAction.sequence([jump, fall])
            ])
            
            ninjaSprite.run(celebrate) { [weak self] in
                self?.startIdleAnimation()
            }
        }
        
        print("🎉 Enhanced ninja celebration!")
    }
    
    func showDisappointment() {
        currentState = .disappointed
        removeAllActions()
        
        let sadFrames = TextureCache.shared.getTextures(for: "Front - Hurt_", count: 12, padWidth: 3)
        
        if !sadFrames.isEmpty {
            let sadAnimation = SKAction.animate(
                with: sadFrames,
                timePerFrame: 0.12
            )
            
            let shrink = SKAction.scale(to: 0.9, duration: 0.3)
            let grow = SKAction.scale(to: 1.0, duration: 0.4)
            let shrinkGrow = SKAction.sequence([shrink, grow])
            
            let shake = SKAction.sequence([
                SKAction.rotate(byAngle: -0.05, duration: 0.1),
                SKAction.rotate(byAngle: 0.1, duration: 0.2),
                SKAction.rotate(byAngle: -0.05, duration: 0.1)
            ])
            
            let disappointment = SKAction.group([sadAnimation, shrinkGrow, shake])
            
            ninjaSprite.run(disappointment) { [weak self] in
                self?.startIdleAnimation()
            }
        }
        
        print("😔 Ninja shows disappointment!")
    }
    
    func performSliceAnimation() {
        currentState = .slicing
        removeAllActions()
        
        let sliceFrames = TextureCache.shared.getTextures(for: "Front - Slashing_", count: 12, padWidth: 3)
        
        if !sliceFrames.isEmpty {
            let sliceAnimation = SKAction.animate(
                with: sliceFrames,
                timePerFrame: 0.04
            )
            
            let sliceForward = SKAction.moveBy(x: 15, y: 0, duration: 0.08)
            let sliceBack = SKAction.moveBy(x: -15, y: 0, duration: 0.12)
            let sliceMotion = SKAction.sequence([sliceForward, sliceBack])
            
            let sliceAction = SKAction.group([sliceAnimation, sliceMotion])
            
            ninjaSprite.run(sliceAction) { [weak self] in
                self?.startIdleAnimation()
            }
        }
        
        print("⚔️ Ninja performs slice!")
    }
    
    private func startIdleAnimation() {
        currentState = .idle
        
        let idleFrames = TextureCache.shared.getTextures(for: "Front - Idle_", count: 12, padWidth: 3)
        
        if !idleFrames.isEmpty {
            let idleAnimation = SKAction.animate(
                with: idleFrames,
                timePerFrame: 0.25
            )
            
            let repeatIdle = SKAction.repeatForever(idleAnimation)
            ninjaSprite.run(repeatIdle, withKey: "idle")
        } else {
            let breathe = SKAction.sequence([
                SKAction.scale(to: 1.02, duration: 2.0),
                SKAction.scale(to: 1.0, duration: 2.0)
            ])
            ninjaSprite.run(SKAction.repeatForever(breathe), withKey: "idle")
        }
    }
    
    // Store original position for returning
    func setOriginalPosition(_ pos: CGPoint) {
        originalPosition = pos
    }
}
