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
    
    let board : Board
    let linkedSprite : Sprite
    
    let speed : GLfloat = 32
    let downSpeed : GLfloat = 96
    
    var lateralMove : LateralMove?
    
    init(board: Board, extra: Sprite) {
        self.board = board
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
        
        if let lateralMove = self.lateralMove {
            // Application du déplacement.
            lateralMove.updateWithTimeSinceLastUpdate(timeSinceLastUpdate)
            if lateralMove.ended {
                self.lateralMove = nil
            }
        } else if Input.instance.pressed(.Left) && board.areSprites([sprite, linkedSprite], ableToMoveToDirection: .Left) {
            // Déplacement à gauche
            self.lateralMove = LateralMove(main: sprite, extra: linkedSprite, direction: .Left)
        } else if Input.instance.pressed(.Right) && board.areSprites([sprite, linkedSprite], ableToMoveToDirection: .Right) {
            // Déplacement à droite
            self.lateralMove = LateralMove(main: sprite, extra: linkedSprite, direction: .Right)
        }
        
        sprite.factory.updateLocationOfSprite(sprite)
    }
    
}

class ExtraCardMotion : PlayerMotion {
    
    let board : Board
    let linkedSprite : Sprite
    
    var rotation : Rotation?
    
    init(board: Board, main: Sprite) {
        self.board = board
        self.linkedSprite = main
    }
    
    func load(sprite: Sprite) {
        // Pas de chargement.
    }
    
    func updateWithTimeSinceLastUpdate(timeSinceLastUpdate: NSTimeInterval, sprite: Sprite) {
        if let rotation = self.rotation {
            // Application de la rotation.
            rotation.updateWithTimeSinceLastUpdate(timeSinceLastUpdate)
            if rotation.ended {
                self.rotation = nil
            }
        } else if Input.instance.pressed(.RotateLeft) && board.areSprites([sprite, linkedSprite], ableToMoveToDirection: .Left) {
            self.rotation = Rotation(main: linkedSprite, extra: sprite, direction: .Left)
        } else if Input.instance.pressed(.RotateRight) && board.areSprites([sprite, linkedSprite], ableToMoveToDirection: .Right) {
            self.rotation = Rotation(main: linkedSprite, extra: sprite, direction: .Right)
        }
        
        sprite.factory.updateLocationOfSprite(sprite)
    }
    
}

class LateralMove {
    
    let duration : NSTimeInterval
    var time : NSTimeInterval = 0
    
    let main: Sprite
    let extra: Sprite
    
    let distance : GLfloat
    
    var ended = false
    
    init(main: Sprite, extra: Sprite, direction: Direction, duration: NSTimeInterval = 0.1) {
        self.main = main
        self.extra = extra
        self.duration = duration
        self.distance = main.width * direction.value()
    }
    
    func updateWithTimeSinceLastUpdate(timeSinceLastUpdate: NSTimeInterval) {
        let oldProgression = GLfloat(time / duration)
        
        self.time += timeSinceLastUpdate
        let progression = min(GLfloat(time / duration), 1)
        
        let x = (progression - oldProgression) * distance
        main.x += x
        extra.x += x
        
        self.ended = progression == 1
    }
    
}

class Rotation {
    
    let duration : NSTimeInterval
    var time : NSTimeInterval = 0
    
    let center : Spot
    let sprite : Sprite
    
    let from : GLfloat
    let rotation : GLfloat
    let length : GLfloat
    
    var ended = false
    
    init(main: Sprite, extra: Sprite, direction: Direction, duration: NSTimeInterval = 0.1) {
        self.center = main
        self.sprite = extra
        self.duration = duration
        self.from = atan2(extra.y - main.y, extra.x - main.x)
        self.rotation = GLfloat(M_PI_2) * direction.value()
        self.length = distance(float2(main.x, main.y), float2(extra.x, extra.y))
    }
    
    func updateWithTimeSinceLastUpdate(timeSinceLastUpdate: NSTimeInterval) {
        self.time += timeSinceLastUpdate
        let progression = min(GLfloat(time / duration), 1)
        
        let angle = from + rotation * progression
        sprite.x = center.x + cos(angle) * length
        sprite.y = center.y + sin(angle) * length
        
        self.ended = progression == 1
    }
    
}
