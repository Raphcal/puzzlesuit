//
//  Sprite.swift
//  MeltedIce
//
//  Created by Raphaël Calabro on 28/06/2015.
//  Copyright (c) 2015 Raphaël Calabro. All rights reserved.
//

import GLKit

enum SpriteType : Int {
    case Decoration, Player, Platform, Collectable, Destroyable, BadGuy, Collidable
    
    func hasCollisions() -> Bool {
        return self.rawValue > SpriteType.Player.rawValue
    }
}

class Sprite : Square {
    
    static let snowyDefinition = 0
    static let whiteDefinition = 1
    static let bubbleDefinition = 2
    static let explosionDefinition = 7
    static let countGUIDefinition = 11
    static let lifeGUIDefinition = 12
    static let cursorDefinition = 25
    static let splashDefinition = 26
    static let buttonGUIDefinition = 30
    
    // MARK: Propriétés
    
    override var center : Spot {
        didSet {
            factory.updateLocationOfSprite(self)
        }
    }
    
    override var topLeft : Spot {
        didSet {
            factory.updateLocationOfSprite(self)
        }
    }
    
    var front : GLfloat {
        get {
            return x + direction.value() * width / 2
        }
    }
    
    let definition : SpriteDefinition
    
    var direction : Direction = .Right
    
    let factory : SpriteFactory
    let reference : Int
    
    var type : SpriteType = .Decoration
    
    var hitbox : Hitbox = SimpleHitbox()
    var motion : Motion = NoMotion.instance
    
    var currentAnimation : AnimationName?
    var animation : Animation = NoAnimation.instance
    
    var dead : Bool = false
    var removed : Bool = false
    
    var variables : [String : GLfloat] = [:]
    var objects : [String : AnyObject] = [:]
    
    // MARK: Constructeur
    
    override init() {
        self.definition = SpriteDefinition()
        self.factory = SpriteFactory()
        self.reference = 0
        
        super.init()
    }
    
    convenience init(motion: Motion) {
        self.init()
        self.motion = motion
    }
    
    init(reference: Int, definition: SpriteDefinition, parent: SpriteFactory) {
        self.factory = parent
        self.definition = definition
        self.type = definition.type
        self.reference = reference
        
        if definition.animations.count > 0 {
            self.animation = definition.animations[0].toAnimation()
            self.currentAnimation = .Stand
        }
        
        super.init(left: 0, top: 0, width: GLfloat(definition.width), height: GLfloat(definition.height))
        
        if unsafeAddressOf(animation.frame.hitbox) != unsafeAddressOf(Square.empty) {
            self.hitbox = SpriteHitbox(sprite: self)
        } else {
            self.hitbox = SimpleHitbox(center: self, width: self.width, height: self.height)
        }
    }
    
    // MARK: Gestion des mises à jour
    
    func updateWithTimeSinceLastUpdate(timeSinceLastUpdate: NSTimeInterval) {
        motion.updateWithTimeSinceLastUpdate(timeSinceLastUpdate, sprite: self)
        animation.updateWithTimeSinceLastUpdate(timeSinceLastUpdate)
        animation.draw(self)
    }
    
    func isLookingTowardPoint(point: Spot) -> Bool {
        return direction.isSameValue(point.x - self.x)
    }
    
    // MARK: Méthodes de suppression du sprite
    
    func destroy() {
        self.removed = true
        
        if definition.animations[AnimationName.Disappear.rawValue].frames.count > 0 {
            self.type = .Decoration
            setAnimation(AnimationName.Disappear, onEnd: { self.factory.removeSprite(self) })
            self.motion = NoMotion.instance
            
        } else {
            factory.removeSprite(self)
        }
    }
    
    func explode(definition: Int) {
        self.removed = true
        
        let explosion = factory.sprite(definition)
        explosion.center = self.center
        explosion.motion = NoMotion.instance
        explosion.setAnimation(.Stand, onEnd: { self.factory.removeSprite(explosion) })
        
        factory.removeSprite(self)
    }
    
    // MARK: Gestion des animations
    
    func setAnimation(name: AnimationName) {
        setAnimation(name, force: false)
    }
    
    func setAnimation(name: AnimationName, force: Bool) {
        if name != currentAnimation || force {
            let nextAnimation = definition.animations[name.rawValue].toAnimation()
            self.animation = animation.transitionToNextAnimation(nextAnimation)
            self.currentAnimation = name
        }
    }
    
    func setAnimation(name: AnimationName, onEnd: () -> Void) {
        let nextAnimation = definition.animations[name.rawValue].toAnimation(onEnd)
        self.animation = animation.transitionToNextAnimation(nextAnimation)
        self.currentAnimation = name
    }
    
    func setBlinkingWithDuration(duration: NSTimeInterval) {
        self.animation = BlinkingAnimation(animation: animation, blinkRate: 0.2, duration: duration) { animation in
            self.animation = animation
        }
    }
    
    func setBlinkingWithRate(blinkRate: NSTimeInterval) {
        self.animation = BlinkingAnimation(animation: animation, blinkRate: blinkRate)
    }
    
    func setBlinking(blinking: Bool) {
        if blinking {
            if !(animation is BlinkingAnimation) {
                let blinkingAnimation = BlinkingAnimation(animation: animation)
                self.animation = blinkingAnimation
            }
        } else {
            if let blinkingAnimation = self.animation as? BlinkingAnimation {
                self.animation = blinkingAnimation.animation
            }
        }
    }
    
    // MARK: Accès aux variables
    
    func variable(name: String) -> GLfloat {
        if let value = self.variables[name] {
            return value
        } else {
            return 0
        }
    }
    
}