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
    
    let controller : Controller
    let board : Board
    let linkedSprite : Sprite
    
    let duration : NSTimeInterval = 0.5
    var time : NSTimeInterval = 0
    
    var lateralMove : LateralMove?
    
    init(board: Board, extra: Sprite, controller: Controller) {
        self.board = board
        self.linkedSprite = extra
        self.controller = controller
    }
    
    func load(sprite: Sprite) {
        // Pas de chargement.
    }
    
    func updateWithTimeSinceLastUpdate(timeSinceLastUpdate: NSTimeInterval, sprite: Sprite) {
        time += timeSinceLastUpdate
        
        let currentDuration = controller.pressing(.Down) ? duration / 10 : duration
        let height = sprite.height / 2
        
        if time >= currentDuration {
            sprite.y += height
            linkedSprite.y += height
            time = 0
        }
        
        if let lateralMove = self.lateralMove {
            // Application du déplacement.
            lateralMove.updateWithTimeSinceLastUpdate(timeSinceLastUpdate)
            if lateralMove.ended {
                self.lateralMove = nil
            }
        } else if controller.pressed(.Left) {
            // Déplacement à gauche
            self.lateralMove = LateralMove(main: sprite, extra: linkedSprite, direction: .Left, board: board)
        } else if controller.pressed(.Right) {
            // Déplacement à droite
            self.lateralMove = LateralMove(main: sprite, extra: linkedSprite, direction: .Right, board: board)
        }
        
        sprite.factory.updateLocationOfSprite(sprite)
    }
    
}

class ExtraCardMotion : Motion, Linked, CanRotate {
    
    let controller : Controller
    let board : Board
    let linkedSprite : Sprite
    
    var direction = Direction.Up
    
    var rotation : Rotation?
    var rotating : Bool {
        get {
            return rotation != nil
        }
    }
    
    init(board: Board, main: Sprite, controller: Controller) {
        self.board = board
        self.linkedSprite = main
        self.controller = controller
    }
    
    func load(sprite: Sprite) {
        // Pas de chargement.
    }
    
    func updateWithTimeSinceLastUpdate(timeSinceLastUpdate: NSTimeInterval, sprite: Sprite) {
        if let rotation = self.rotation {
            // Application de la rotation.
            rotation.updateWithTimeSinceLastUpdate(timeSinceLastUpdate)
            if rotation.ended, let index = Direction.circle.indexOf(self.direction) {
                self.direction = Direction.circle[(index + rotation.count + Direction.circle.count) % Direction.circle.count]
                self.rotation = nil
            }
        } else if controller.pressed(.RotateLeft) {
            self.rotation = Rotation(main: linkedSprite, extra: sprite, direction: .Left, board: board)
        } else if controller.pressed(.RotateRight) {
            self.rotation = Rotation(main: linkedSprite, extra: sprite, direction: .Right, board: board)
        }
        
        sprite.factory.updateLocationOfSprite(sprite)
    }
    
}

