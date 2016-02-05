//
//  Resources.swift
//  MeltedIce
//
//  Created by Raphaël Calabro on 01/10/2015.
//  Copyright © 2015 Raphaël Calabro. All rights reserved.
//

import GLKit

enum ResourceLoadError : ErrorType {
    case TextureNotFound
}

class Resources {
    
    static let instance = Resources()
    
    var textureAtlas : GLKTextureInfo
    var definitions : [SpriteDefinition]
    var textures = [String:GLKTextureInfo]()
    
    var grid = Grid()
    
    init() {
        for texture in ["atlas", "Basique-32"] {
            do {
                if let url = NSBundle.mainBundle().URLForResource(texture, withExtension: "png") {
                    self.textures[texture] = try GLKTextureLoader.textureWithContentsOfURL(url, options: [GLKTextureLoaderOriginBottomLeft: false, GLKTextureLoaderApplyPremultiplication: true])
                }
            } catch {
                NSLog("Erreur de chargement de la texture '\(texture)' : \(error)")
            }
        }
        
        self.textureAtlas = textures["atlas"]!
        
        if let url = NSBundle.mainBundle().URLForResource("atlas", withExtension: "sprites"), let inputStream = NSInputStream(URL: url) {
            inputStream.open()
            self.definitions = SpriteDefinition.definitionsFromInputStream(inputStream)
            inputStream.close()
        } else {
            NSLog("Erreur de chargement des définitions.")
            self.definitions = []
        }
    }
    
    static func textureForResource(name: String, withExtension ext: String) throws -> GLKTextureInfo {
        if let texture = Resources.instance.textures[name] {
            return texture
        } else {
            throw ResourceLoadError.TextureNotFound
        }
    }
    
    static func releaseTexture(texture: GLKTextureInfo) {
        // Pas de libération des textures.
    }
    
}