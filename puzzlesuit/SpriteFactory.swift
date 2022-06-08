//
//  SpriteFactory.swift
//  MeltedIce
//
//  Created by Raphaël Calabro on 09/12/2015.
//  Copyright © 2015 Raphaël Calabro. All rights reserved.
//

import GLKit

enum Distance : Int {
    case Behind, Middle, Front
}

/// Gère la création, l'affichage et la mise à jour d'un ensemble de sprites.
class SpriteFactory {
    
    // static let operationQueue = OperationQueue()
    
    let capacity : Int
    
    let textureAtlas : GLKTextureInfo
    
    let pools : [ReferencePool]
    var sprites = [Sprite]()
    var removalPending = [Sprite]()
    
    let definitions : [SpriteDefinition]
    
    let vertexPointer : SurfaceArray
    let texCoordPointer : SurfaceArray
    
    var collisions = [Sprite]()
    
    var types = [SpriteType:[Sprite]]()
    
    init() {
        self.capacity = 0
        self.textureAtlas = GLKTextureInfo()
        self.pools = []
        self.definitions = []
        self.vertexPointer = SurfaceArray()
        self.texCoordPointer = SurfaceArray()
    }
    
    init(capacity: Int, textureAtlas: GLKTextureInfo, definitions: [SpriteDefinition], useMultiplePools: Bool) {
        self.capacity = capacity
        self.definitions = definitions
        self.textureAtlas = textureAtlas
        
        if useMultiplePools {
            let middle = (capacity * 3) / 4
            self.pools = [
                ReferencePool(from: 0, to: middle),
                ReferencePool(from: middle, to: middle + 2),
                ReferencePool(from: middle + 2, to: capacity)
            ]
        } else {
            self.pools = [ReferencePool(capacity: capacity)]
        }
        
        let vertices = capacity * Surfaces.vertexesByQuad
        self.vertexPointer = SurfaceArray(capacity: vertices, coordinates: Surfaces.coordinatesByVertice)
        self.texCoordPointer = SurfaceArray(capacity: vertices, coordinates: Surfaces.coordinatesByTexture)
        
        // Mise à 0 des pointeurs
        vertexPointer.clear()
        texCoordPointer.clear()
    }
    
    convenience init(capacity: Int, useMultiplePools: Bool = false) {
        self.init(capacity: capacity, textureAtlas: Resources.instance.textureAtlas, definitions: Resources.instance.definitions, useMultiplePools: useMultiplePools)
    }
    
    // MARK: Gestion des mises à jour
    
    func update(timeSinceLastUpdate: TimeInterval) {
        for sprite in sprites {
            sprite.update(timeSinceLastUpdate: timeSinceLastUpdate)
        }
        
        for sprite in removalPending {
            if let index = sprites.firstIndex(of: sprite) {
                sprites.remove(at: index)
                let reference = sprite.reference
                pools[sprite.definition.distance.rawValue].releaseReference(reference: reference)
                vertexPointer.clearQuad(at: reference)
                texCoordPointer.clearQuad(at: reference)
            } else {
                NSLog("removalPending: Sprite \(sprite.reference) non trouvé.")
            }
        }
        removalPending.removeAll(keepingCapacity: true)
    }
    
    func updateCollisionsForSprite(player: Sprite) {
        self.collisions.removeAll(keepingCapacity: true)
        
        for sprite in types[.Collidable]! {
            if sprite.definition != player.definition && sprite.hitbox.collidesWith(other: player.hitbox) {
                self.collisions.append(sprite)
            }
        }
    }
    
    // MARK: Gestion de l'affichage
    
    /// Dessine les sprites de cette factory.
    func draw() {
        let camera = Camera.instance.topLeft
        
        Draws.bindTexture(textureAtlas)
        Draws.translateForPoint(camera)
        Draws.drawWithVertexPointer(vertexPointer.memory, texCoordPointer: texCoordPointer.memory, count: GLsizei(capacity * Surfaces.vertexesByQuad))
        Draws.cancelTranslationForPoint(camera)
    }
    
    /// Dessine les sprites de cette factory sans prendre en compte la camera.
    func drawUntranslated() {
        Draws.bindTexture(textureAtlas)
        Draws.drawWithVertexPointer(vertexPointer.memory, texCoordPointer: texCoordPointer.memory, count: GLsizei(capacity * Surfaces.vertexesByQuad))
    }
    
    // MARK: Création de sprites
    
    func sprite(definition: Int) -> Sprite {
        return sprite(definition: definitions[definition])
    }
    
    func sprite(definition: Int, x: GLfloat, y: GLfloat) -> Sprite {
        let sprite = self.sprite(definition: definitions[definition])
        sprite.topLeft = Spot(x: x, y: y)
        return sprite
    }
    
    func sprite(parent: Sprite, animation: AnimationName, frame: Int) -> Sprite {
        let sprite = self.sprite(definition: parent.definition, after: parent)
        
        sprite.animation = SingleFrameAnimation(definition: parent.definition.animations[animation.rawValue])
        sprite.animation.frameIndex = frame
        
        let frame = sprite.animation.frame
        sprite.width = GLfloat(frame.width)
        sprite.height = GLfloat(frame.height)
        
        return sprite
    }
    
    func sprite(definition: SpriteDefinition, after: Sprite? = nil) -> Sprite {
        let reference = pools[definition.distance.rawValue].next(other: after?.reference)
        let sprite = Sprite(reference: reference, definition: definition, parent: self)
        self.sprites.append(sprite)
        
        if definition.type == .Player {
            appendSprite(sprite: sprite, toType: .Player)
        } else if definition.type.hasCollisions() {
            appendSprite(sprite: sprite, toType: .Collidable)
        }
        
        return sprite
    }
    
    // MARK: Suppression de sprites
    
    func removeSprite(sprite: Sprite) {
        sprite.removed = true
        removalPending.append(sprite)
        
        let definition = sprite.definition
        if definition.type == .Player {
            removeSprite(sprite: sprite, fromType: .Player)
        } else if definition.type.hasCollisions() {
            removeSprite(sprite: sprite, fromType: .Collidable)
        }
    }
    
    func clear() {
        for sprite in sprites {
            removeSprite(sprite: sprite)
        }
    }
    
    // MARK: Gestion du tri des sprites par type
    
    private func appendSprite(sprite: Sprite, toType type: SpriteType) {
        var sprites = self.types[type]
        
        if sprites == nil {
            sprites = []
        }
        
        sprites!.append(sprite)
        self.types[type] = sprites
    }
    
    private func removeSprite(sprite: Sprite, fromType type: SpriteType) {
        var sprites = self.types[type]!
        
        if let index = sprites.firstIndex(of: sprite) {
            sprites.remove(at: index)
        }
        
        self.types[type] = sprites
    }
    
    // MARK: Gestion des surfaces OpenGL
    
    func updateLocationOfSprite(sprite: Sprite) {
        Surfaces.setQuad(buffer: vertexPointer.memory, sprite: sprite)
    }
    
    func setTextureOfReference(reference: Int, x: Int, y: Int, width: Int, height: Int, mirror: Bool) {
        let widthInTexture = GLfloat(width) / GLfloat(textureAtlas.width)
        let heightInTexture = GLfloat(height) / GLfloat(textureAtlas.height)
        let xInTexture = GLfloat(x) / GLfloat(textureAtlas.width)
        let yInTexture = GLfloat(y) / GLfloat(textureAtlas.width)
        
        Surfaces.setTile(buffer: texCoordPointer.memory, index: reference, width: widthInTexture, height: heightInTexture, x: xInTexture, y: yInTexture, mirror: mirror)
    }
    
    func clearTextureOfSprite(sprite: Sprite) {
        texCoordPointer.clearQuad(at: sprite.reference)
    }
    
}
