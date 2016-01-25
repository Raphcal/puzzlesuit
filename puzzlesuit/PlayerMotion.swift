//
//  PlayerMotion.swift
//  PuzzleSuit
//
//  Created by Raphaël Calabro on 24/01/2016.
//  Copyright © 2016 Raphaël Calabro. All rights reserved.
//

import GLKit

protocol PlayerMotion : Motion {
    
    var linkedSprite : Sprite { get }
    
}

class MainCardMotion : PlayerMotion {
    
    let linkedSprite : Sprite
    
    var speed : GLfloat = 32
    var downSpeed : GLfloat = 64
    var lateral = false
    
    init(extra: Sprite) {
        self.linkedSprite = extra
    }
    
    func load(sprite: Sprite) {
        // Pas de chargement.
    }
    
    func updateWithTimeSinceLastUpdate(timeSinceLastUpdate: NSTimeInterval, sprite: Sprite) {
        let delta = GLfloat(timeSinceLastUpdate)
        let speed = Input.instance.pressing(.Down) ? self.downSpeed : self.speed
        
        sprite.y += delta * speed
        linkedSprite.y += delta * speed
        
        if !lateral && Input.instance.pressed(.Left) {
            // TODO: Déplacement à gauche
        } else if !lateral && Input.instance.pressed(.Right) {
            // TODO: Déplacement à droite
        }
        
        sprite.factory.updateLocationOfSprite(sprite)
    }
    
}

class ExtraCardMotion : Motion {
    
    let linkedSprite : Sprite
    var rotating = false
    
    init(main: Sprite) {
        self.linkedSprite = main
    }
    
    func load(sprite: Sprite) {
        // Pas de chargement.
    }
    
    func updateWithTimeSinceLastUpdate(timeSinceLastUpdate: NSTimeInterval, sprite: Sprite) {
        if !rotating && Input.instance.pressed(.RotateLeft) {
            // TODO: Rotation à gauche
        } else if !rotating && Input.instance.pressed(.RotateRight) {
            // TODO: Rotation à droite
        }
        
        sprite.factory.updateLocationOfSprite(sprite)
    }
    
}
