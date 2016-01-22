//
//  Counter.swift
//  MeltedIce
//
//  Created by Raphaël Calabro on 01/07/2015.
//  Copyright (c) 2015 Raphaël Calabro. All rights reserved.
//

import GLKit

/// Compteur affichant une valeur alignée en haut à droite en utilisant un sprite par chiffre.
class Counter : Spot {
    
    let factory : SpriteFactory
    var digits : [Int] = []
    var sprites : [Sprite] = []
    var value : Int = 0 {
        didSet {
            updateDigits()
        }
    }
    
    override init() {
        self.factory = SpriteFactory()
        
        super.init()
    }
    
    init(factory: SpriteFactory, x: GLfloat, y: GLfloat) {
        self.factory = factory
        super.init(x: x, y: y)
        
        updateDigits()
    }
    
    deinit {
        for sprite in sprites {
            sprite.destroy()
        }
    }
    
    private func updateDigits() {
        self.digits.removeAll(keepCapacity: true)
        
        if(value <= 0) {
            digits.append(0)
        } else {
            for var number = value; number > 0; number /= 10 {
                digits.append(number % 10)
            }
        }
        
        displayValue()
    }
    
    private func displayValue() {
        while sprites.count > digits.count {
            sprites[sprites.count - 1].destroy()
            sprites.removeAtIndex(sprites.count - 1)
        }
        while sprites.count < digits.count {
            sprites.append(createDigit())
        }
        
        for index in 0..<digits.count {
            let sprite = sprites[index]
            
            // Pour l'alignement à gauche, utiliser "+ index * sprite.width".
            sprite.topLeft = Spot(x: self.x - GLfloat(index) * sprite.width, y: self.y)
            
            // Pour l'alignement à gauche, utiliser "digits.count - index - 1".
            sprite.animation.frameIndex = digits[index]
        }
    }
    
    private func createDigit() -> Sprite {
        let sprite = factory.sprite(Sprite.countGUIDefinition)
        
        let definition = sprite.animation.definition
        let animation = SingleFrameAnimation(definition: definition)
        
        sprite.animation = animation
        return sprite
    }
    
}

/// Alignement typographique de la valeur d'un objet Text.
/// L'alignement se fait par rapport à la position x de l'objet.
enum TextAlignment {
    case Left, Center, Right
}

/// Affiche un texte aligné en haut à gauche en utilisant un sprite par lettre.
class Text : Spot, Shape {
    
    class func displayText(text: String, factory: SpriteFactory, atPoint point: Spot) {
        let _ = Text(factory: factory, x: point.x, y: point.y, text: text)
    }
    
    let zero = Text.integerFromCharacter("0")
    let nine = Text.integerFromCharacter("9")
    let upperCaseA = Text.integerFromCharacter("A")
    let upperCaseZ = Text.integerFromCharacter("Z")
    let lowerCaseA = Text.integerFromCharacter("a")
    let lowerCaseZ = Text.integerFromCharacter("z")
    let semicolon = Text.integerFromCharacter(":")
    let space = Text.integerFromCharacter(" ")
    
    let digitAnimation = 0
    let upperCaseAnimation = 1
    let lowerCaseAnimation = 2
    let semicolonAnimation = 3
    
    let spaceWidth : GLfloat = 8
    
    let factory : SpriteFactory
    var sprites : [Sprite] = []
    var value : String = "" {
        didSet {
            if value != oldValue {
                displayText()
            }
        }
    }
    
    var alignment = TextAlignment.Left {
        didSet {
            switch alignment {
            case .Left:
                reflowTextFromX(x)
            case .Center:
                reflowTextFromX(x - width / 2)
            case .Right:
                reflowTextFromX(x - width)
            }
        }
    }
    var width : GLfloat = 0
    var height : GLfloat = 0
    
    var top : GLfloat {
        get {
            return y
        }
    }
    
    var bottom : GLfloat {
        get {
            return y + height
        }
    }
    
    var left : GLfloat {
        get {
            switch alignment {
            case .Left:
                return x
            case .Center:
                return x - width / 2
            case .Right:
                return x - width
            }
        }
    }
    
    var right : GLfloat {
        get {
            switch alignment {
            case .Left:
                return x + width
            case .Center:
                return x + width / 2
            case .Right:
                return x
            }
        }
    }
    
    override init() {
        self.factory = SpriteFactory()
        
        super.init()
    }

    /* -- Désactivé car nécessite de garder un pointeur sur les textes pour ne pas qu'ils s'effacent.
    deinit {
        for sprite in sprites {
            sprite.destroy()
        }
    }
    */
    
    init(factory: SpriteFactory, x: GLfloat, y: GLfloat, text: String) {
        self.factory = factory
        self.value = text
        super.init(x: x, y: y)
        
        displayText()
    }
    
    func setBlinking(blinking: Bool) {
        for sprite in sprites {
            sprite.setBlinking(blinking)
        }
    }
    
    func setBlinkingWithRate(blinkRate: NSTimeInterval) {
        for sprite in sprites {
            sprite.setBlinkingWithRate(blinkRate)
        }
    }
    
    func moveToLocation(location: Spot) {
        let differenceX = location.x - x
        let differenceY = location.y - y
        
        for sprite in sprites {
            sprite.x += differenceX
            sprite.y += differenceY
            factory.updateLocationOfSprite(sprite)
        }
        
        self.x = location.x
        self.y = location.y
    }
    
    private func displayText() {
        var x = self.x
        var width : GLfloat = 0
        var height : GLfloat = 0
        
        var sprites = [Sprite]()
        
        var index = 0
        for c in value.utf8 {
            if Int8(c) == space {
                x += spaceWidth
                width += spaceWidth
            } else {
                // Création d'un sprite par lettre pour afficher le texte donné.
                let sprite = spriteForIndex(index++)
                setFrameOfSprite(sprite, toCharacter: Int8(c))
                sprite.topLeft = Spot(x: x, y: self.y)
                
                sprites.append(sprite)
                
                x += sprite.width
                width += sprite.width
                height = max(sprite.height, height)
            }
        }
        
        for _ in index..<self.sprites.count {
            let sprite = self.sprites.removeLast()
            sprite.destroy()
        }
        
        self.width = width
        self.height = height
        self.sprites = sprites
    }
    
    private func spriteForIndex(index: Int) -> Sprite {
        let sprite : Sprite
        
        if index < sprites.count {
            sprite = sprites[index]
        } else {
            sprite = factory.sprite(Sprite.countGUIDefinition)
            sprites.append(sprite)
        }
        
        return sprite
    }
    
    private func setFrameOfSprite(sprite: Sprite, toCharacter value: Int8) {
        if value >= zero && value <= nine {
            // Chiffre.
            sprite.animation = SingleFrameAnimation(definition: sprite.definition.animations[digitAnimation])
            sprite.animation.frameIndex = value - zero
            
            resizeSprite(sprite)
            
        } else if value >= upperCaseA && value <= upperCaseZ {
            // Lettre majuscule.
            sprite.animation = SingleFrameAnimation(definition: sprite.definition.animations[upperCaseAnimation])
            sprite.animation.frameIndex = value - upperCaseA
            
            resizeSprite(sprite)
            
        } else if value >= lowerCaseA && value <= lowerCaseZ {
            // Lettre minuscule.
            sprite.animation = SingleFrameAnimation(definition: sprite.definition.animations[lowerCaseAnimation])
            sprite.animation.frameIndex = value - lowerCaseA
            
            resizeSprite(sprite)
            
        } else if value == semicolon {
            // "Deux points".
            sprite.animation = SingleFrameAnimation(definition: sprite.definition.animations[semicolonAnimation])
            sprite.animation.frameIndex = 0
            
            resizeSprite(sprite)
        
        } else {
            // Espace ou lettre non supportée.
            sprite.animation = NoAnimation.instance
        }
    }
    
    private func resizeSprite(sprite: Sprite) {
        let frame = sprite.animation.frame
        sprite.width = GLfloat(frame.width)
        sprite.height = GLfloat(frame.height)
    }
    
    private class func integerFromCharacter(c: Character) -> Int8 {
        let string = String(c)
        let nsString = NSString(string: string)
        let utf8Pointer = nsString.UTF8String
        
        return utf8Pointer[0]
    }
    
    private func reflowTextFromX(x: GLfloat) {
        let difference = sprites[0].x - x
        
        for sprite in sprites {
            sprite.x -= difference
            factory.updateLocationOfSprite(sprite)
        }
    }
    
}