//
//  FallMotion.swift
//  puzzlesuit
//
//  Created by Raphaël Calabro on 25/01/2016.
//  Copyright © 2016 Raphaël Calabro. All rights reserved.
//

import GLKit

class FallMotion : Motion {
    
    var speed : GLfloat
    let acceleration : GLfloat = 300
    let board : Board
    
    /// Ensemble des sprites situés au dessus de celui-ci et qui vont chuter en même temps.
    let tail : [Sprite]
    
    init(board: Board, tail: [Sprite] = [], initialSpeed: GLfloat = 96) {
        self.board = board
        self.tail = tail
        self.speed = initialSpeed
    }
    
    func load(sprite: Sprite) {
        // Pas de chargement.
    }
    
    func updateWithTimeSinceLastUpdate(timeSinceLastUpdate: NSTimeInterval, sprite: Sprite) {
        let step = GLfloat(timeSinceLastUpdate) * speed
        self.speed += acceleration * GLfloat(timeSinceLastUpdate)
        
        let sprites : [Sprite]
        
        if tail.isEmpty {
            sprites = [sprite]
        } else {
            sprites = tail
        }
        
        for other in sprites {
            other.y += step
            sprite.factory.updateLocationOfSprite(other)
        }
        
        if board.isSpriteAboveSomething(sprite) {
            sprite.motion = NoMotion()
            board.attachSprite(sprite, tail: tail)
        }
    }
    
}
