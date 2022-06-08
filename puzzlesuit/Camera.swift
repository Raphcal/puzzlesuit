//
//  Camera.swift
//  MeltedIce
//
//  Created by Raphaël Calabro on 28/06/2015.
//  Copyright (c) 2015 Raphaël Calabro. All rights reserved.
//

import GLKit

class Camera : Square {
    
    static let instance = Camera()
    static let defaultMoveTime : TimeInterval = 1
    
    /// Cadre dans lequel se déplace la caméra.
    var frame : Square
    
    /// Décalage vertical causé par les zoom.
    var offsetY : GLfloat = 0
    
    var motion : CameraMotion = NoCameraMotion()
    
    override init() {
        let width = View.instance.width
        let height = View.instance.height
        self.frame = Square(left: 0, top: 0, width: width, height: height)
        
        super.init(left: 0, top: 0, width: width, height: height)
    }
    
    func update(timeSinceLastUpdate: TimeInterval) {
        let center = motion.locationWithTimeSinceLastUpdate(timeSinceLastUpdate: timeSinceLastUpdate)
        
        self.x = max(min(center.x, frame.right - width / 2), frame.left + width / 2)
        self.y = max(min(center.y, frame.bottom - height / 2), frame.top + height / 2) + offsetY
    }
    
    func center(width: GLfloat, height: GLfloat) {
        self.x = width / 2
        self.y = height / 2
    }
    
    func isSpriteInView(sprite: Sprite) -> Bool {
        return SimpleHitbox(center: self, width: width + sprite.width, height: height + sprite.height).collidesWith(sprite: sprite)
    }
    
    func removeSpriteIfOutOfView(sprite: Sprite) {
        if !isSpriteInView(sprite: sprite) {
            sprite.destroy()
        }
    }

}

protocol CameraMotion {
    
    func locationWithTimeSinceLastUpdate(timeSinceLastUpdate: TimeInterval) -> Spot
 
    func to(other: CameraMotion) -> CameraMotion
    
}

class NoCameraMotion : CameraMotion {
    
    func locationWithTimeSinceLastUpdate(timeSinceLastUpdate: TimeInterval) -> Spot {
        return Camera.instance
    }
    
    func to(other: CameraMotion) -> CameraMotion {
        return other
    }
    
}

