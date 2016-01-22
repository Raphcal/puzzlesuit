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
        for texture in ["atlas", "Base-32", "Cupcake-32", "Nord-32", "Ville-32", "Mine-32", "Iles-32"] {
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
    
    func reloadTextureNamed(name: String, fromFilename filename: String) {
        do {
            let previousTexture = self.textures[name]
            self.textures[name] = try GLKTextureLoader.textureWithContentsOfURL(NSURL(fileURLWithPath: filename), options: [GLKTextureLoaderOriginBottomLeft: false, GLKTextureLoaderApplyPremultiplication: true])
    
            if previousTexture != nil {
                NSLog("Texture \(name) mise à jour, libération de la texture précédente.")
                Draws.freeTexture(previousTexture!)
            }
        } catch {
            NSLog("Erreur de rechargement de la texture '\(name)' à partir du fichier '\(filename)' : \(error)")
        }
    }
    
    func reloadSpriteTextureAndAtlasFromMML(mml: String) {
        if let inputStream = NSInputStream(fileAtPath: mml + "/atlas.sprites") {
            inputStream.open()
            self.definitions = SpriteDefinition.definitionsFromInputStream(inputStream)
            inputStream.close()
        }
        do {
            self.textureAtlas = try GLKTextureLoader.textureWithContentsOfURL(NSURL(fileURLWithPath: mml + "/atlas.png"), options: [GLKTextureLoaderOriginBottomLeft: false, GLKTextureLoaderApplyPremultiplication: true])
        } catch {
            NSLog("Erreur de rechargement de l'atlas des sprites à partir du MML '\(mml)' : \(error)")
        }
    }
    
}