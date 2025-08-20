//
//  ChaseSlashScene.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/19/25.
//

import SpriteKit
import SwiftUI

class ChaseSlashScene: SKScene {
    
    // Character nodes
    private var badGuy: SKSpriteNode!
    private var ninja: SKSpriteNode!
    
    // Animation atlases
    private var badGuyChaseLeftAtlas: SKTextureAtlas?
    private var badGuyChaseRightAtlas: SKTextureAtlas?
    private var badGuyChaseHurtLeftAtlas: SKTextureAtlas?
    private var badGuyChaseHurtRightAtlas: SKTextureAtlas?
    private var ninjaChaseLeftAtlas: SKTextureAtlas?
    private var ninjaChaseRightAtlas: SKTextureAtlas?
    private var ninjaSliceLeftAtlas: SKTextureAtlas?
    private var ninjaSliceRightAtlas: SKTextureAtlas?
    
    // Animation arrays
    private var badGuyChaseLeftTextures: [SKTexture] = []
    private var badGuyChaseRightTextures: [SKTexture] = []
    private var badGuyHurtLeftTextures: [SKTexture] = []
    private var badGuyHurtRightTextures: [SKTexture] = []
    private var ninjaChaseLeftTextures: [SKTexture] = []
    private var ninjaChaseRightTextures: [SKTexture] = []
    private var ninjaSliceLeftTextures: [SKTexture] = []
    private var ninjaSliceRightTextures: [SKTexture] = []
    
    // Game state
    private var isSlashing = false
    private var slashCooldown: TimeInterval = 0
    private let slashRange: CGFloat = 100 // Slightly reduced since they're smaller
    private let slashCooldownTime: TimeInterval = 2.5
    private var currentDirection: CGFloat = 1 // 1 for right, -1 for left
    
    private let chaseDistance: CGFloat = 250 // Increased spacing between characters
    private let badGuySpeed: CGFloat = 3.5 // Increased speed
    private let ninjaSpeed: CGFloat = 8 // Ninja slightly faster to catch up
    
    override func didMove(to view: SKView) {
        setupScene()
        loadTextureAtlases()
        setupCharacters()
        startChaseAnimation()
    }
    
    private func setupScene() {
        size = CGSize(width: UIScreen.main.bounds.width, height: 150)
        self.backgroundColor = .clear
        // Ensure the scene is truly transparent
        scaleMode = .aspectFit
    }
    
    private func loadTextureAtlases() {
        print("🔍 Loading texture atlases...")
        
        // Try to load atlases with error handling
        do {
            badGuyChaseLeftAtlas = try loadAtlasSafely(named: "bad_guy_chase_left")
            badGuyChaseRightAtlas = try loadAtlasSafely(named: "bad_guy_chase_right")
            badGuyChaseHurtLeftAtlas = try loadAtlasSafely(named: "bad_guy_chase_hurt_left")
            badGuyChaseHurtRightAtlas = try loadAtlasSafely(named: "bad_guy_chase_hurt_right")
            
            // Correct ninja atlas names based on your screenshots:
            ninjaChaseLeftAtlas = try loadAtlasSafely(named: "ninja_chase_left")
            ninjaChaseRightAtlas = try loadAtlasSafely(named: "ninja_chase_right")
            ninjaSliceLeftAtlas = try loadAtlasSafely(named: "ninja_chase_slice_left")
            ninjaSliceRightAtlas = try loadAtlasSafely(named: "ninja_chase_slice_right")

        } catch {
            print("❌ Error loading atlases: \(error)")
            // Use fallback single textures
            setupFallbackTextures()
            return
        }
        
        // Load textures from atlases
        if let atlas = badGuyChaseLeftAtlas {
            badGuyChaseLeftTextures = loadTexturesFromAtlas(atlas, prefix: "Left - Walking_")
            print("✅ Loaded \(badGuyChaseLeftTextures.count) bad guy left textures")
        }
        
        if let atlas = badGuyChaseRightAtlas {
            badGuyChaseRightTextures = loadTexturesFromAtlas(atlas, prefix: "Right - Walking_")
            print("✅ Loaded \(badGuyChaseRightTextures.count) bad guy right textures")
        }
        
        if let atlas = badGuyChaseHurtLeftAtlas {
            badGuyHurtLeftTextures = loadTexturesFromAtlas(atlas, prefix: "Left - Hurt_")
            print("✅ Loaded \(badGuyHurtLeftTextures.count) bad guy hurt left textures")
        }
        
        if let atlas = badGuyChaseHurtRightAtlas {
            badGuyHurtRightTextures = loadTexturesFromAtlas(atlas, prefix: "Right - Hurt_")
            print("✅ Loaded \(badGuyHurtRightTextures.count) bad guy hurt right textures")
        }
        
        if let atlas = ninjaChaseLeftAtlas {
            ninjaChaseLeftTextures = loadTexturesFromAtlas(atlas, prefix: "Left - Walking_")
            print("✅ Loaded \(ninjaChaseLeftTextures.count) ninja left textures")
        }
        
        if let atlas = ninjaChaseRightAtlas {
            ninjaChaseRightTextures = loadTexturesFromAtlas(atlas, prefix: "Right - Walking_")
            print("✅ Loaded \(ninjaChaseRightTextures.count) ninja right textures")
        }
        
        if let atlas = ninjaSliceLeftAtlas {
            ninjaSliceLeftTextures = loadTexturesFromAtlas(atlas, prefix: "Left - Slashing_")
            print("✅ Loaded \(ninjaSliceLeftTextures.count) ninja slice left textures")
        }
        
        if let atlas = ninjaSliceRightAtlas {
            ninjaSliceRightTextures = loadTexturesFromAtlas(atlas, prefix: "Right - Slashing_")
            print("✅ Loaded \(ninjaSliceRightTextures.count) ninja slice right textures")
        }
        
        // Validate that we have minimum required textures
        validateTextures()
    }
    
    private func loadAtlasSafely(named name: String) throws -> SKTextureAtlas {
        print("🔍 Attempting to load atlas: '\(name)'")
        
        // First, let's see what atlases are actually available
        if let bundlePath = Bundle.main.resourcePath {
            print("📁 Bundle path: \(bundlePath)")
            
            // List all atlas files in the bundle
            do {
                let contents = try FileManager.default.contentsOfDirectory(atPath: bundlePath)
                let atlasFiles = contents.filter { $0.hasSuffix(".atlasc") || $0.contains("atlas") }
                print("📚 Available atlas files: \(atlasFiles)")
            } catch {
                print("❌ Could not list bundle contents: \(error)")
            }
        }
        
        // Try to load the atlas
        let atlas = SKTextureAtlas(named: name)
        
        // Check if atlas loaded successfully by trying to access texture names
        let textureNames = atlas.textureNames
        
        if textureNames.isEmpty {
            print("❌ Atlas '\(name)' loaded but contains no textures")
            throw TextureError.atlasNotFound(name)
        }
        
        print("📦 Found atlas '\(name)' with \(textureNames.count) textures")
        print("   Textures: \(textureNames.sorted())")
        
        return atlas
    }
    
    private func debugSpecificAtlas() {
        let workingAtlas = SKTextureAtlas(named: "ninja_chase_slice_right")
        let workingTextures = workingAtlas.textureNames.sorted()
        print("✅ Working atlas textures: \(workingTextures)")
        
        let brokenAtlas = SKTextureAtlas(named: "ninja_chase_left")
        let brokenTextures = brokenAtlas.textureNames.sorted()
        print("❌ Broken atlas textures: \(brokenTextures)")
    }
    
    private func debugNinjaAtlases() {
        let ninjaAtlasNames = [
            "ninja_chase_left",
            "ninja_chase_right",
            "ninja_chase_slice_left",
            "ninja_chase_slice_right"
        ]
        
        for atlasName in ninjaAtlasNames {
            let atlas = SKTextureAtlas(named: atlasName)
            let textureNames = atlas.textureNames
            
            if textureNames.isEmpty {
                print("❌ '\(atlasName)' - NO TEXTURES FOUND")
            } else {
                print("✅ '\(atlasName)' - \(textureNames.count) textures found")
            }
        }
    }
    
    private enum TextureError: Error {
        case atlasNotFound(String)
    }
    
    private func setupFallbackTextures() {
        print("🔄 Setting up fallback textures...")
        
        // Create simple colored rectangles as fallback
        let badGuyTexture = createColorTexture(color: .red, size: CGSize(width: 60, height: 80))
        let ninjaTexture = createColorTexture(color: .blue, size: CGSize(width: 60, height: 80))
        
        // Use single texture for all animations as fallback
        badGuyChaseLeftTextures = [badGuyTexture]
        badGuyChaseRightTextures = [badGuyTexture]
        badGuyHurtLeftTextures = [badGuyTexture]
        badGuyHurtRightTextures = [badGuyTexture]
        ninjaChaseLeftTextures = [ninjaTexture]
        ninjaChaseRightTextures = [ninjaTexture]
        ninjaSliceLeftTextures = [ninjaTexture]
        ninjaSliceRightTextures = [ninjaTexture]
    }
    
    private func createColorTexture(color: UIColor, size: CGSize) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
        return SKTexture(image: image)
    }
    
    private func validateTextures() {
        let textureArrays = [
            ("badGuyChaseLeft", badGuyChaseLeftTextures),
            ("badGuyChaseRight", badGuyChaseRightTextures),
            ("ninjaChaseLeft", ninjaChaseLeftTextures),
            ("ninjaChaseRight", ninjaChaseRightTextures)
        ]
        
        for (name, textures) in textureArrays {
            if textures.isEmpty {
                print("⚠️ Empty texture array for \(name) - using fallback")
                setupFallbackTextures()
                break
            }
        }
    }
    
    private func loadTexturesFromAtlas(_ atlas: SKTextureAtlas, prefix: String) -> [SKTexture] {
        print("🔍 Looking for textures with prefix '\(prefix)' in atlas with \(atlas.textureNames.count) textures")
        
        let allNames = atlas.textureNames
        print("   All texture names: \(allNames.sorted())")
        
        let filteredNames = allNames.filter { $0.hasPrefix(prefix) }
        print("   Filtered names: \(filteredNames)")
        
        if filteredNames.isEmpty {
            // Try alternative prefixes
            let alternativePrefixes = [
                "Left - Walking_",
                "Right - Walking_",
                "Left - Hurt_",
                "Right - Hurt_",
                "Left - Slashing_",
                "Right - Slashing_"
            ]
            
            for altPrefix in alternativePrefixes {
                let altFiltered = allNames.filter { $0.hasPrefix(altPrefix) }
                if !altFiltered.isEmpty {
                    print("   Found textures with alternative prefix '\(altPrefix)': \(altFiltered)")
                    let sorted = altFiltered.sorted { extractNumber(from: $0) < extractNumber(from: $1) }
                    return sorted.map { atlas.textureNamed($0) }
                }
            }
            
            // If no prefix matches, use all textures
            if !allNames.isEmpty {
                print("   No prefix match, using all textures")
                let sorted = allNames.sorted { extractNumber(from: $0) < extractNumber(from: $1) }
                return sorted.map { atlas.textureNamed($0) }
            }
            
            return []
        }
        
        let sortedNames = filteredNames.sorted { (name1, name2) -> Bool in
            let num1 = extractNumber(from: name1)
            let num2 = extractNumber(from: name2)
            return num1 < num2
        }
        
        return sortedNames.map { atlas.textureNamed($0) }
    }
    
    private func extractNumber(from filename: String) -> Int {
        // Try to extract number from various patterns
        let patterns = [
            "_([0-9]+)$",  // Ending with _123
            "([0-9]+)$",   // Ending with 123
            "_([0-9]+)\\.", // _123.
            "([0-9]+)\\."   // 123.
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: filename, range: NSRange(filename.startIndex..., in: filename)),
               let range = Range(match.range(at: 1), in: filename) {
                if let number = Int(String(filename[range])) {
                    return number
                }
            }
        }
        
        return 0
    }
    
    private func setupCharacters() {
        // Ensure we have textures before creating characters
        guard !badGuyChaseRightTextures.isEmpty && !ninjaChaseRightTextures.isEmpty else {
            print("❌ Cannot setup characters - no textures available")
            return
        }
        
        // SWAPPED: Bad guy now starts in front (being chased)
        badGuy = SKSpriteNode(texture: badGuyChaseRightTextures.first)
        badGuy.position = CGPoint(x: size.width * 0.6, y: size.height / 2) // Start further ahead
        badGuy.setScale(0.4)
        badGuy.zPosition = 2 // Bad guy in front (being chased)
        addChild(badGuy)
        
        // SWAPPED: Ninja now starts behind (chasing)
        ninja = SKSpriteNode(texture: ninjaChaseRightTextures.first)
        ninja.position = CGPoint(x: size.width * 0.3, y: size.height / 2) // Start behind bad guy
        ninja.setScale(0.4)
        ninja.zPosition = 1 // Ninja behind (chasing)
        addChild(ninja)
        
        // Start with running animations
        animateBadGuyRun()
        animateNinjaRun()
    }

    private func moveNinja() {
        // CHANGED: Ninja now chases the bad guy (gets closer to catch up)
        let targetX = badGuy.position.x - (60 * currentDirection) // Stay close behind for slashing
        
        if abs(ninja.position.x - targetX) > 8 {
            let moveDirection = targetX > ninja.position.x ? 1 : -1
            ninja.position.x += ninjaSpeed * CGFloat(moveDirection)
        }
    }

    private func moveBadGuy() {
        // Bad guy continues moving as before (being chased)
        var newX = badGuy.position.x + (badGuySpeed * currentDirection)
        
        // Check for direction change at screen edges
        if newX > size.width - 30 || newX < 30 {
            currentDirection *= -1
            newX = badGuy.position.x + (badGuySpeed * currentDirection)
            
            // Update animations for new direction
            badGuy.removeAction(forKey: "run")
            ninja.removeAction(forKey: "run")
            animateBadGuyRun()
            animateNinjaRun()
        }
        
        badGuy.position.x = newX
    }

    private func performSlash() {
        isSlashing = true
        slashCooldown = slashCooldownTime
        
        // Temporarily bring ninja to front for dramatic slash effect
        ninja.zPosition = 3
        
        // Stop ninja run animation and play slash animation
        ninja.removeAction(forKey: "run")
        
        let slashTextures = currentDirection > 0 ? ninjaSliceRightTextures : ninjaSliceLeftTextures
        guard !slashTextures.isEmpty else {
            print("⚠️ No slash textures available")
            completeSlash()
            return
        }
        
        let slashAnimation = SKAction.animate(with: slashTextures, timePerFrame: 0.04)
        let slashComplete = SKAction.run { [weak self] in
            self?.completeSlash()
        }
        let slashSequence = SKAction.sequence([slashAnimation, slashComplete])
        
        ninja.run(slashSequence, withKey: "slash")
        
        // Make bad guy react to being hit from behind
        badGuyHitReaction()
    }

    private func completeSlash() {
        isSlashing = false
        
        // Return ninja to behind bad guy
        ninja.zPosition = 1
        
        // Resume ninja run animation
        animateNinjaRun()
    }

    private func badGuyHitReaction() {
        // Stop bad guy run animation and play hurt animation
        badGuy.removeAction(forKey: "run")
        
        let hurtTextures = currentDirection > 0 ? badGuyHurtRightTextures : badGuyHurtLeftTextures
        guard !hurtTextures.isEmpty else {
            print("⚠️ No hurt textures available")
            resumeBadGuyRun()
            return
        }
        
        let hurtAnimation = SKAction.animate(with: hurtTextures, timePerFrame: 0.06)
        let hurtComplete = SKAction.run { [weak self] in
            self?.resumeBadGuyRun()
        }
        let hurtSequence = SKAction.sequence([hurtAnimation, hurtComplete])
        
        badGuy.run(hurtSequence, withKey: "hurt")
        
        // Knockback pushes bad guy forward (away from ninja)
        let knockbackDistance: CGFloat = 25
        let knockback = SKAction.moveBy(x: knockbackDistance * currentDirection, y: 0, duration: 0.12)
        badGuy.run(knockback)
    }

    private func animateBadGuyRun() {
        let textures = currentDirection > 0 ? badGuyChaseRightTextures : badGuyChaseLeftTextures
        guard !textures.isEmpty else {
            print("⚠️ No bad guy textures available for animation")
            return
        }
        
        let runAction = SKAction.animate(with: textures, timePerFrame: 0.05) // Faster animation (was 0.08)
        let repeatAction = SKAction.repeatForever(runAction)
        badGuy.run(repeatAction, withKey: "run")
    }
    
    private func animateNinjaRun() {
        let textures = currentDirection > 0 ? ninjaChaseRightTextures : ninjaChaseLeftTextures
        guard !textures.isEmpty else {
            print("⚠️ No ninja textures available for animation")
            return
        }
        
        let runAction = SKAction.animate(with: textures, timePerFrame: 0.05) // Faster animation (was 0.08)
        let repeatAction = SKAction.repeatForever(runAction)
        ninja.run(repeatAction, withKey: "run")
    }
        
    private func startChaseAnimation() {
        let chaseAction = SKAction.run { [weak self] in
            self?.updateChase()
        }
        let waitAction = SKAction.wait(forDuration: 0.012) // Increased to ~83fps for smoother movement
        let sequence = SKAction.sequence([chaseAction, waitAction])
        let repeatAction = SKAction.repeatForever(sequence)
        
        run(repeatAction, withKey: "chaseLoop")
    }
        
    private func updateChase() {
        guard !isSlashing, badGuy != nil, ninja != nil else { return }
        
        // Calculate distance between characters
        let distance = abs(ninja.position.x - badGuy.position.x)
        
        // Move bad guy (being chased)
        moveBadGuy()
        
        // Move ninja (chaser) towards bad guy
        moveNinja()
        
        // Check if ninja is close enough to slash
        if distance <= slashRange && slashCooldown <= 0 {
            performSlash()
        }
        
        // Update cooldown
        if slashCooldown > 0 {
            slashCooldown -= 0.016
        }
    }
        
    private func resumeBadGuyRun() {
        // Resume bad guy run animation
        animateBadGuyRun()
    }
}
