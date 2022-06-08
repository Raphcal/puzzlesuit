//
//  Resources.swift
//  MeltedIce
//
//  Created by Raphaël Calabro on 01/10/2015.
//  Copyright © 2015 Raphaël Calabro. All rights reserved.
//

import GLKit

enum ResourceLoadError : Error {
    case URLNotFound
}

class Resources {
    
    static let instance = Resources()
    
    var textureAtlas : GLKTextureInfo
    var definitions : [SpriteDefinition]
    
    var grid = Grid()
    
    init() {
        do {
            self.textureAtlas = try Resources.textureForResource(name: "atlas", withExtension: "png")
        } catch {
            NSLog("Erreur de chargement de la texture des sprites \(error)")
            self.textureAtlas = GLKTextureInfo()
        }
        
        if let url = Bundle.main.url(forResource: "atlas", withExtension: "sprites"), let inputStream = InputStream(url: url) {
            inputStream.open()
            self.definitions = SpriteDefinition.definitionsFromInputStream(inputStream: inputStream)
            inputStream.close()
        } else {
            NSLog("Erreur de chargement des définitions.")
            self.definitions = []
        }
    }
    
    static func textureForResource(name: String, withExtension ext: String) throws -> GLKTextureInfo {
        let error = glGetError()
        if error != 0 {
            NSLog("Erreur OpenGL : \(error)")
        }
        
        if let url = Bundle.main.url(forResource: name, withExtension: ext) {
            #if os(iOS)
                let premultiplication = false
            #else
                let premultiplication = true
            #endif
            return try GLKTextureLoader.texture(withContentsOf: url, options: [GLKTextureLoaderOriginBottomLeft: false, GLKTextureLoaderApplyPremultiplication: NSNumber(booleanLiteral: premultiplication)])
        } else {
            throw ResourceLoadError.URLNotFound
        }
    }
    
    static func release(texture: GLKTextureInfo) {
        Draws.freeTexture(texture)
    }
    
}
