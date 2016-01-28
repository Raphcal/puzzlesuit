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
        } else if Input.instance.pressed(.Left) {
            // Déplacement à gauche
            self.lateralMove = LateralMove(main: sprite, extra: linkedSprite, direction: .Left, board: board)
        } else if Input.instance.pressed(.Right) {
            // Déplacement à droite
            self.lateralMove = LateralMove(main: sprite, extra: linkedSprite, direction: .Right, board: board)
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

