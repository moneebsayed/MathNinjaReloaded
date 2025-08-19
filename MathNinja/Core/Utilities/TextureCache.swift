//
//  TextureCache.swift
//  MathNinja
//
//  Created by Moneeb Sayed on 8/19/25.
//


import SpriteKit

class TextureCache {
    static let shared = TextureCache()
    
    private var cache: [String: [SKTexture]] = [:]
    
    private init() {}
    
    func getTextures(for pattern: String, count: Int, padWidth: Int) -> [SKTexture] {
        let cacheKey = "\(pattern)_\(count)_\(padWidth)"
        
        if let cachedTextures = cache[cacheKey] {
            return cachedTextures
        }
        
        var textures: [SKTexture] = []
        
        for i in 0..<count {
            let frameName: String
            if padWidth == 3 {
                frameName = String(format: "%@%03d", pattern, i)
            } else {
                frameName = "\(pattern)\(i)"
            }
            
            let texture = SKTexture(imageNamed: frameName)
            
            if texture.size() != CGSize.zero {
                textures.append(texture)
            }
        }
        
        // Cache the textures
        cache[cacheKey] = textures
        
        if !textures.isEmpty {
            print("💾 Cached \(textures.count) textures for: \(pattern)")
        } else {
            print("❌ No textures found for pattern: \(pattern)")
        }
        
        return textures
    }
}
