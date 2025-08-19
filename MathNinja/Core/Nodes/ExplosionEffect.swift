//
//  ExplosionEffect.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/18/25.
//


import SpriteKit
import SwiftUI

class ExplosionEffect: SKNode {
    
    static func createExplosion(at position: CGPoint, in scene: SKScene) {
        let explosion = ExplosionEffect()
        explosion.position = position
        scene.addChild(explosion)
        explosion.explode()
    }
    
    private func explode() {
        // Use your blast_3 sequence
        let explosionFrames = loadBlastFrames(count: 14) // Adjust count based on how many you have
        
        if !explosionFrames.isEmpty {
            let explosionSprite = SKSpriteNode(texture: explosionFrames.first)
            explosionSprite.setScale(0.8) // Nice size for explosion
            addChild(explosionSprite)
            
            let explodeAnimation = SKAction.animate(
                with: explosionFrames,
                timePerFrame: 0.05 // Fast explosion
            )
            
            let sequence = SKAction.sequence([
                explodeAnimation,
                SKAction.run { [weak self] in
                    self?.removeFromParent()
                }
            ])
            
            explosionSprite.run(sequence)
        } else {
            // Fallback: particle explosion
            createParticleExplosion()
        }
    }
    
    private func loadBlastFrames(count: Int) -> [SKTexture] {
        var textures: [SKTexture] = []
        
        for i in 0..<count {
            let frameName = String(format: "blast_3_%05d", i) // blast_3_00000, blast_3_00001, etc.
            let texture = SKTexture(imageNamed: frameName)
            
            if texture.size() != CGSize.zero {
                textures.append(texture)
                print("✅ Loaded explosion texture: \(frameName)")
            } else {
                print("❌ Failed to load explosion texture: \(frameName)")
            }
        }
        
        print("💥 Loaded \(textures.count) explosion textures")
        return textures
    }
    
    private func createParticleExplosion() {
        let emitter = SKEmitterNode()
        emitter.particleTexture = SKTexture(imageNamed: "spark")
        emitter.particleBirthRate = 100
        emitter.numParticlesToEmit = 50
        emitter.particleLifetime = 0.8
        emitter.particleSpeed = 120
        emitter.particleSpeedRange = 60
        emitter.emissionAngle = 0
        emitter.emissionAngleRange = .pi * 2
        emitter.particleScale = 0.4
        emitter.particleScaleSpeed = -0.5
        emitter.particleColor = UIColor.systemOrange
        emitter.particleAlpha = 0.9
        emitter.particleAlphaSpeed = -1.2
        emitter.particleBlendMode = .add
        
        addChild(emitter)
        
        // Remove after explosion
        let removeAction = SKAction.sequence([
            SKAction.wait(forDuration: 1.2),
            SKAction.removeFromParent()
        ])
        run(removeAction)
    }
}
