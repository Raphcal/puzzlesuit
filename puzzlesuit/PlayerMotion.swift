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
    
    let duration : TimeInterval = 0.5
    var time : TimeInterval = 0
    
    var lateralMove : LateralMove?
    
    init(board: Board, extra: Sprite, controller: Controller) {
        self.board = board
        self.linkedSprite = extra
        self.controller = controller
    }
    
    func load(sprite: Sprite) {
        // Pas de chargement.
    }
    
    func update(timeSinceLastUpdate: TimeInterval, sprite: Sprite) {
        time += timeSinceLastUpdate
        
        let currentDuration = controller.pressing(button: .Down) ? duration / 10 : duration
        let height = sprite.height / 2
        
        if time >= currentDuration {
            sprite.y += height
            linkedSprite.y += height
            time = 0
        }
        
        if let lateralMove = self.lateralMove {
            // Application du déplacement.
            lateralMove.update(timeSinceLastUpdate: timeSinceLastUpdate)
            if lateralMove.ended {
                self.lateralMove = nil
            }
        } else if controller.pressed(button: .Left) {
            // Déplacement à gauche
            self.lateralMove = LateralMove(main: sprite, extra: linkedSprite, direction: .Left, board: board)
        } else if controller.pressed(button: .Right) {
            // Déplacement à droite
            self.lateralMove = LateralMove(main: sprite, extra: linkedSprite, direction: .Right, board: board)
        }
        
        sprite.factory.updateLocationOfSprite(sprite: sprite)
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
    
    func update(timeSinceLastUpdate: TimeInterval, sprite: Sprite) {
        if let rotation = self.rotation {
            // Application de la rotation.
            rotation.update(timeSinceLastUpdate: timeSinceLastUpdate)
            if rotation.ended, let index = Direction.circle.firstIndex(of: self.direction) {
                self.direction = Direction.circle[(index + rotation.count + Direction.circle.count) % Direction.circle.count]
                self.rotation = nil
            }
        } else if controller.pressed(button: .RotateLeft) {
            self.rotation = Rotation(main: linkedSprite, extra: sprite, direction: .Left, board: board)
        } else if controller.pressed(button: .RotateRight) {
            self.rotation = Rotation(main: linkedSprite, extra: sprite, direction: .Right, board: board)
        }
        
        sprite.factory.updateLocationOfSprite(sprite: sprite)
    }
    
}

