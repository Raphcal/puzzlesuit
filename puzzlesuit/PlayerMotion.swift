//
//  PlayerMotion.swift
//  PuzzleSuit
//
//  Created by Raphaël Calabro on 24/01/2016.
//  Copyright © 2016 Raphaël Calabro. All rights reserved.
//

import GLKit

protocol Linked {
    
    var linkedSprite : Sprite { get }
    
}

protocol CanRotate {
    
    var rotating : Bool { get }
    
}

class MainCardMotion : Motion, Linked {
    
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

class ExtraCardMotion : Motion, Linked, CanRotate {
    
    let board : Board
    let linkedSprite : Sprite
    
    var rotation : Rotation?
    var rotating : Bool {
        get {
            return rotation != nil
        }
    }
    
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
        } else if Input.instance.pressed(.RotateLeft) {
            self.rotation = Rotation(main: linkedSprite, extra: sprite, direction: .Left, board: board)
        } else if Input.instance.pressed(.RotateRight) {
            self.rotation = Rotation(main: linkedSprite, extra: sprite, direction: .Right, board: board)
        }
        
        sprite.factory.updateLocationOfSprite(sprite)
    }
    
}

class LateralMove {
    
    let duration : NSTimeInterval = 0.1
    var time : NSTimeInterval = 0
    
    let main: Sprite
    let extra: Sprite
    
    let distance : GLfloat
    
    var ended = false
    
    init(main: Sprite, extra: Sprite, direction: Direction) {
        self.main = main
        self.extra = extra
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
    
    let duration : NSTimeInterval = 0.1
    var time : NSTimeInterval = 0
    
    let center : Spot
    let sprite : Sprite
    
    let from : GLfloat
    let rotation : GLfloat
    let length : GLfloat
    
    var ended = false
    
    init?(main: Sprite, extra: Sprite, direction: Direction, board: Board) {
        self.center = main
        self.sprite = extra
        self.from = atan2(extra.y - main.y, extra.x - main.x)
        self.length = distance(float2(main.x, main.y), float2(extra.x, extra.y))
        
        for i in 1..<4 {
            let rotation = GLfloat(M_PI_2) * direction.value() * GLfloat(i)
            let targetAngle = from + rotation
            let targetPoint = Spot(x: main.x + cos(targetAngle) * length, y: main.y + sin(targetAngle) * length)
            
            if board.canMoveToPoint(targetPoint) {
                self.rotation = rotation
                return
            }
        }
        
        self.rotation = 0
        return nil
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
