//
//  FallMotion.swift
//  puzzlesuit
//
//  Created by Raphaël Calabro on 25/01/2016.
//  Copyright © 2016 Raphaël Calabro. All rights reserved.
//

import GLKit

class FallMotion : Motion {
    
    let speed : GLfloat = 96
    let board : Board
    
    /// Ensemble des sprites situés au dessus de celui-ci et qui vont chuter en même temps.
    let tail : [Sprite]
    
    init(board: Board, tail: [Sprite] = []) {
        self.board = board
        self.tail = tail
    }
    
    func load(sprite: Sprite) {
        // Pas de chargement.
    }
    
    func updateWithTimeSinceLastUpdate(timeSinceLastUpdate: NSTimeInterval, sprite: Sprite) {
        let step = GLfloat(timeSinceLastUpdate) * speed
        sprite.y += step
        
        for other in tail {
            other.y += step
            sprite.factory.updateLocationOfSprite(other)
        }
        
        if board.isAboveSomething(sprite) {
            do {
                sprite.motion = NoMotion()
                try board.attachSprite(sprite, tail: tail)
            } catch {
                // TODO: FAIRE DIFFEREMMENT !
            }
        }
        
        sprite.factory.updateLocationOfSprite(sprite)
    }
    
}
