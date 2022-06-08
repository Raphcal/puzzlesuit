//
//  Move.swift
//  puzzlesuit
//
//  Created by Raphaël Calabro on 28/01/2016.
//  Copyright © 2016 Raphaël Calabro. All rights reserved.
//

import GLKit

class LateralMove {
    
    let duration : TimeInterval = 0.1
    var time : TimeInterval = 0
    
    let main: Sprite
    let extra: Sprite
    
    let distance : GLfloat
    
    var ended = false
    
    init?(main: Sprite, extra: Sprite, direction: Direction, board: Board) {
        self.main = main
        self.extra = extra
        self.distance = main.width * direction.value()

        if !board.canMoveToPoint(point: Spot(x: main.x + distance, y: main.y)) || !board.canMoveToPoint(point: Spot(x: extra.x + distance, y: extra.y)) {
            return nil
        }
    }
    
    func update(timeSinceLastUpdate: TimeInterval) {
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
    
    let duration : TimeInterval = 0.1
    var time : TimeInterval = 0
    
    let center : Spot
    let sprite : Sprite
    
    let from : GLfloat
    let rotation : GLfloat
    let count : Int
    let length : GLfloat
    
    var ended = false
    
    init?(main: Sprite, extra: Sprite, direction: Direction, board: Board) {
        self.center = main
        self.sprite = extra
        self.from = atan2(extra.y - main.y, extra.x - main.x)
        self.length = distance(SIMD2<Float>(main.x, main.y), SIMD2<Float>(extra.x, extra.y))
        
        for i in 1..<4 {
            let rotation = GLfloat.pi / 2 * direction.value() * GLfloat(i)
            let targetAngle = from + rotation
            let targetPoint = Spot(x: main.x + cos(targetAngle) * length, y: main.y + sin(targetAngle) * length)
            
            if board.canMoveToPoint(point: targetPoint) {
                self.count = i * Int(direction.value())
                self.rotation = rotation
                return
            }
            
            if main.x == extra.x {
                let inverseRotation = GLfloat.pi / 2 * direction.reverse().value() * GLfloat(i)
                let inverseAngle = from + inverseRotation
                let inversePoint = Spot(x: main.x + cos(inverseAngle) * length, y: main.y + sin(inverseAngle) * length)
                
                if board.canMoveToPoint(point: inversePoint) {
                    main.x = inversePoint.x
                    self.count = i * Int(direction.value())
                    self.rotation = rotation
                    return
                }
            }
        }
        
        self.count = 0
        self.rotation = 0
        return nil
    }
    
    func update(timeSinceLastUpdate: TimeInterval) {
        self.time += timeSinceLastUpdate
        let progression = min(GLfloat(time / duration), 1)
        
        let angle = from + rotation * progression
        sprite.x = center.x + cos(angle) * length
        sprite.y = center.y + sin(angle) * length
        
        self.ended = progression == 1
    }
    
}
