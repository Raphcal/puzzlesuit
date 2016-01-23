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
    static let defaultMoveTime : NSTimeInterval = 1
    
    /// Cadre dans lequel se déplace la caméra.
    var frame : Square
    
    /// Décalage vertical causé par les zoom.
    var offsetY : GLfloat = 0
    
    var motion : CameraMotion = NoCameraMotion()
    
    var target : Spot? {
        didSet {
            if let target = self.target {
                self.motion = motion.to(LockedCameraMotion(target: target))
            } else {
                self.motion = motion.to(NoCameraMotion())
            }
            self.center = motion.locationWithTimeSinceLastUpdate(0)
        }
    }
    
    override init() {
        let width = View.instance.width
        let height = View.instance.height
        self.frame = Square(left: 0, top: 0, width: width, height: height)
        
        super.init(left: 0, top: 0, width: width, height: height)
    }
    
    func updateWithTimeSinceLastUpdate(timeSinceLastUpdate: NSTimeInterval) {
        let center = motion.locationWithTimeSinceLastUpdate(timeSinceLastUpdate)
        
        self.x = max(min(center.x, frame.right - width / 2), frame.left + width / 2)
        self.y = max(min(center.y, frame.bottom - height / 2), frame.top + height / 2) + offsetY
    }
    
    func center(width: GLfloat, height: GLfloat) {
        self.x = width / 2
        self.y = height / 2
    }
    
    func moveTo(target: Spot) {
        moveTo(target, time: Camera.defaultMoveTime, onLock: nil);
    }
    
    func moveTo(target: Spot, onLock : () -> Void) {
        moveTo(target, time: Camera.defaultMoveTime, onLock: onLock);
    }
    
    func moveTo(target: Spot, time: NSTimeInterval, onLock: (() -> Void)?) {
        self.motion = motion.to(MovingToTargetCameraMotion(origin: Camera.instance, target: target, onLock: onLock))
    }
    
    func isSpriteInView(sprite: Sprite) -> Bool {
        return SimpleHitbox(center: self, width: width + sprite.width, height: height + sprite.height).collidesWith(sprite)
    }
    
    func removeSpriteIfOutOfView(sprite: Sprite) {
        if !isSpriteInView(sprite) {
            sprite.destroy()
        }
    }

}

protocol CameraMotion {
    
    func locationWithTimeSinceLastUpdate(timeSinceLastUpdate: NSTimeInterval) -> Spot
 
    func to(other: CameraMotion) -> CameraMotion
    
}

class NoCameraMotion : CameraMotion {
    
    func locationWithTimeSinceLastUpdate(timeSinceLastUpdate: NSTimeInterval) -> Spot {
        return Camera.instance
    }
    
    func to(other: CameraMotion) -> CameraMotion {
        return other
    }
    
}

class LockedCameraMotion : CameraMotion {
    
    let target : Spot
    
    init(target: Spot) {
        self.target = target
    }
    
    func locationWithTimeSinceLastUpdate(timeSinceLastUpdate: NSTimeInterval) -> Spot {
        return target
    }
    
    func to(other: CameraMotion) -> CameraMotion {
        return other
    }
    
}

class MovingToTargetCameraMotion : CameraMotion {
    
    let origin : Spot
    let target : Spot
    let duration : NSTimeInterval = 1
    var elapsed : NSTimeInterval = 0
    var onLock : (() -> Void)?
    
    init(origin: Spot, target: Spot, onLock: (() -> Void)?) {
        self.origin = Spot(point: origin)
        self.target = target
        self.onLock = onLock
    }
    
    func locationWithTimeSinceLastUpdate(timeSinceLastUpdate: NSTimeInterval) -> Spot {
        self.elapsed += timeSinceLastUpdate
        
        if elapsed >= duration {
            onLock?()
            self.onLock = nil
            self.elapsed = duration
            
            Camera.instance.motion = LockedCameraMotion(target: target)
        }
        
        let ratio = GLfloat(elapsed / duration)
        return Spot(x: target.x * ratio + origin.x * (1 - ratio), y: target.y * ratio + origin.y * (1 - ratio))
    }
    
    func to(other: CameraMotion) -> CameraMotion {
        return other
    }
    
}

class EarthquakeCameraMotion : CameraMotion {
    
    var motion : CameraMotion
    let random = Random()
    let amplitude : GLfloat = 4
    
    init() {
        self.motion = Camera.instance.motion
    }
    
    func locationWithTimeSinceLastUpdate(timeSinceLastUpdate: NSTimeInterval) -> Spot {
        let center = motion.locationWithTimeSinceLastUpdate(timeSinceLastUpdate)
        return Spot(x: center.x + random.next(amplitude) - amplitude / 2, y: center.y + random.next(amplitude) - amplitude / 2)
    }
    
    func to(other: CameraMotion) -> CameraMotion {
        self.motion = other
        return self
    }
    
}

class TimedEarthquakeCameraMotion : CameraMotion {
    
    let random = Random()
    let duration : NSTimeInterval
    var time : NSTimeInterval = 0
    var motion : CameraMotion
    
    init(duration: NSTimeInterval) {
        self.duration = duration
        self.motion = Camera.instance.motion
    }
    
    func locationWithTimeSinceLastUpdate(timeSinceLastUpdate: NSTimeInterval) -> Spot {
        self.time += timeSinceLastUpdate
        
        if time >= duration {
            Camera.instance.motion = motion
        }
        
        let center = motion.locationWithTimeSinceLastUpdate(timeSinceLastUpdate)
        let amplitude = GLfloat(Math.smoothStep(0, to: duration, value: time) * 4)
        return Spot(x: center.x, y: center.y + random.next(amplitude) - amplitude / 2)
    }
    
    func to(other: CameraMotion) -> CameraMotion {
        self.motion = other
        return self
    }
    
}

class QuakeCameraMotion : CameraMotion {
    
    let random = Random()
    var amplitude : GLfloat
    var motion : CameraMotion
    
    init(amplitude: GLfloat) {
        self.amplitude = amplitude
        self.motion = Camera.instance.motion
    }
    
    func locationWithTimeSinceLastUpdate(timeSinceLastUpdate: NSTimeInterval) -> Spot {
        self.amplitude = max(amplitude - GLfloat(timeSinceLastUpdate * 10), 0)
        
        if amplitude == 0 {
            Camera.instance.motion = motion
        }
        
        let center = motion.locationWithTimeSinceLastUpdate(timeSinceLastUpdate)
        return Spot(x: center.x, y: center.y + random.next(amplitude) - amplitude / 2)
    }
    
    func to(other: CameraMotion) -> CameraMotion {
        self.motion = other
        return self
    }
    
}

class TwoPlayerCameraMotion : CameraMotion {
    
    let first : Spot
    let second : Spot
    
    init(first: Spot, second: Spot) {
        self.first = first
        self.second = second
    }
    
    func locationWithTimeSinceLastUpdate(timeSinceLastUpdate: NSTimeInterval) -> Spot {
        let minX, maxX : GLfloat
        if first.x < second.x {
            minX = first.x
            maxX = second.x
        } else {
            minX = second.x
            maxX = first.x
        }
        
        let width = View.instance.width
        
        // TODO: MOINS ZOOMER !
        let center = Spot(x: (first.x + second.x) / 2, y: (first.y + second.y) / 2)
        let left = max(min(minX - width / 4, center.x - width / 2), center.x - width * 0.75)
        let right = min(max(maxX + width / 4, center.x + width / 2), center.x + width * 0.75)
        
        Camera.instance.width = right - left
        View.instance.zoom = Camera.instance.width / View.instance.width
        Camera.instance.height = View.instance.zoomedHeight
        View.instance.applyZoom()
        
        Camera.instance.offsetY = (Camera.instance.height - View.instance.height) / 2
        
        return center
    }
    
    func to(other: CameraMotion) -> CameraMotion {
        return self
    }
    
}