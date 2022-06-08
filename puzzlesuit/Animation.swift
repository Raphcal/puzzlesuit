//
//  Animation.swift
//  MeltedIce
//
//  Created by Raphaël Calabro on 28/06/2015.
//  Copyright (c) 2015 Raphaël Calabro. All rights reserved.
//

import Foundation

enum AnimationName : Int {
    case Stand = 0, Walk, Run, Skid, Jump, Fall, Shaky, Bounce, Duck, Raise, Appear, Disappear, Attack, Hurt, Die
}

protocol Animation {
    
    func update(timeSinceLastUpdate: TimeInterval)
    func draw(sprite: Sprite)
    func transitionToNextAnimation(nextAnimation: Animation) -> Animation
    
    var definition : AnimationDefinition { get set }
    var frameIndex : Int { get set }
    var frame : Frame { get }
    var speed : Float { get set }
    
}

class Frame {
    
    /// Emplacement x dans l'atlas.
    let x : Int
    /// Emplacement y dans l'atlas.
    let y : Int
    /// Largeur de l'image.
    let width : Int
    /// Hauteur de l'image.
    let height : Int
    /// Zone de collision.
    let hitbox : Square
    
    init() {
        self.x = 0
        self.y = 0
        self.width = 0
        self.height = 0
        self.hitbox = Square.empty
    }
    
    init(width: Int, height: Int) {
        self.x = 0
        self.y = 0
        self.width = width
        self.height = height
        self.hitbox = Square.empty
    }
    
    init(inputStream : InputStream) {
        self.x = Streams.readInt(inputStream)
        self.y = Streams.readInt(inputStream)
        self.width = Streams.readInt(inputStream)
        self.height = Streams.readInt(inputStream)
        
        if Streams.readBoolean(inputStream) {
            let left = GLfloat(Streams.readInt(inputStream))
            let top = GLfloat(Streams.readInt(inputStream))
            let width = GLfloat(Streams.readInt(inputStream))
            let height = GLfloat(Streams.readInt(inputStream))
            
            self.hitbox = Square(left: left, top: top, width: width, height: height)
        } else {
            self.hitbox = Square.empty
        }
    }
    
    func draw(sprite: Sprite) {
        sprite.factory.setTextureOfReference(reference: sprite.reference, x: x, y: y, width: width, height: height, mirror: sprite.direction.isMirror())
    }
    
}

// MARK: - Implémentation des différents types d'animation

class NoAnimation : Animation {
    
    static let instance : NoAnimation = NoAnimation()
    
    var definition : AnimationDefinition = AnimationDefinition()
    var frameIndex : Int = 0
    let frame : Frame
    var speed : Float = 0
    
    init() {
        self.frame = Frame()
    }
    
    init(definition: AnimationDefinition) {
        self.frame = Frame()
        self.definition = definition
    }
    
    init(frame: Frame) {
        self.frame = frame
    }
    
    func update(timeSinceLastUpdate: TimeInterval) {
        // Pas de traitement
    }
    
    func draw(sprite: Sprite) {
        // Pas de traitement
    }
    
    func transitionToNextAnimation(nextAnimation: Animation) -> Animation {
        return nextAnimation
    }
    
}

class SingleFrameAnimation : Animation {
    
    var definition : AnimationDefinition {
        didSet {
            start()
        }
    }
    var frameIndex : Int {
        didSet {
            if frameIndex >= 0 && frameIndex < definition.frames.count {
                self.frame = definition.frames[frameIndex]
            }
        }
    }
    var frame : Frame
    var speed : Float = 1
    var frequency : TimeInterval
    
    init(definition: AnimationDefinition) {
        self.definition = definition
        self.frequency = 1 / TimeInterval(definition.frequency)
        self.frameIndex = 0
        if definition.frames.count > 0 {
            self.frame = definition.frames[0]
        } else {
            self.frame = Frame()
        }
    }
    
    convenience init(animation: AnimationName, fromSprite sprite: Sprite) {
        self.init(definition: sprite.definition.animations[animation.rawValue])
    }
    
    func update(timeSinceLastUpdate: TimeInterval) {
        // Pas de traitement
    }
    
    func draw(sprite: Sprite) {
        frame.draw(sprite: sprite)
    }
    
    func transitionToNextAnimation(nextAnimation: Animation) -> Animation {
        return nextAnimation
    }
    
    func start() {
        self.frameIndex = 0
    }
    
}

class LoopingAnimation : SingleFrameAnimation {
    
    var time : TimeInterval = 0
    
    override func update(timeSinceLastUpdate: TimeInterval) {
        time += timeSinceLastUpdate * TimeInterval(speed)
        
        if time >= frequency {
            let elapsedFrames = Int(time / frequency)
            self.frameIndex = (frameIndex + elapsedFrames) % definition.frames.count
            time -= TimeInterval(elapsedFrames) * frequency
        }
    }
    
}

class PlayOnceAnimation : SingleFrameAnimation {
    
    let onEnd : (() -> Void)?
    
    private var startDate : NSDate
    private var called : Bool
    
    override init(definition: AnimationDefinition) {
        self.onEnd = nil
        self.startDate = NSDate()
        self.called = false
        
        super.init(definition: definition)
    }
    
    init(definition: AnimationDefinition, onEnd: @escaping () -> Void) {
        self.onEnd = onEnd
        self.startDate = NSDate()
        self.called = false
        
        super.init(definition: definition)
    }
    
    override func update(timeSinceLastUpdate: TimeInterval) {
        let timeSinceStart = NSDate().timeIntervalSince(startDate as Date)
        let frame = Int(timeSinceStart / frequency)
        
        if frame < definition.frames.count {
            self.frameIndex = frame
        } else {
            self.frameIndex = definition.frames.count - 1
            
            if onEnd != nil && !called {
                self.called = true
                onEnd!()
            }
        }
    }
    
    override func start() {
        super.start()
        self.startDate = NSDate()
    }
    
}

class BlinkingAnimation : Animation {
    
    static let Pair = 2
    
    var animation : Animation
    let onEnd : ((_ animation: Animation) -> Void)?
    let duration : TimeInterval
    
    var time : TimeInterval = 0
    let blinkRate : TimeInterval
    
    private var visible = true
    
    var definition : AnimationDefinition {
        get {
            return animation.definition
        }
        set {
            animation.definition = newValue
        }
    }
    var frameIndex : Int {
        get {
            return animation.frameIndex
        }
        set {
            animation.frameIndex = newValue
        }
    }
    var frame : Frame {
        get {
            return animation.frame
        }
    }
    var speed : Float {
        get {
            return animation.speed
        }
        set {
            animation.speed = newValue
        }
    }
    
    init(animation: Animation, blinkRate: TimeInterval = 0.2, duration: TimeInterval = 0, onEnd:((_ animation: Animation) -> Void)? = nil) {
        self.animation = animation
        self.onEnd = onEnd
        self.duration = duration
        self.blinkRate = blinkRate
    }
    
    func update(timeSinceLastUpdate: TimeInterval) {
        self.time += timeSinceLastUpdate
        
        let frame = Int(time / blinkRate)
        self.visible = (frame % BlinkingAnimation.Pair) == 0
        
        if let onEnd = self.onEnd, time >= duration {
            onEnd(animation)
        }
        
        animation.update(timeSinceLastUpdate: timeSinceLastUpdate)
    }
    
    func draw(sprite: Sprite) {
        if visible {
            animation.draw(sprite: sprite)
        } else {
            sprite.factory.clearTextureOfSprite(sprite: sprite)
        }
    }
    
    func transitionToNextAnimation(nextAnimation: Animation) -> Animation {
        self.animation = nextAnimation
        return self
    }
    
}
