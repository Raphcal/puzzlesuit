//
//  Text.swift
//  puzzlesuit
//
//  Created by Raphaël Calabro on 11/02/2016.
//  Copyright © 2016 Raphaël Calabro. All rights reserved.
//

import GLKit

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
    
    let zero = Text.integerFromCharacter(c: "0")
    let nine = Text.integerFromCharacter(c: "9")
    let upperCaseA = Text.integerFromCharacter(c: "A")
    let upperCaseZ = Text.integerFromCharacter(c: "Z")
    let lowerCaseA = Text.integerFromCharacter(c: "a")
    let lowerCaseZ = Text.integerFromCharacter(c: "z")
    let semicolon = Text.integerFromCharacter(c: ":")
    let space = Text.integerFromCharacter(c: " ")
    
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
                reflowTextFromX(x: x)
            case .Center:
                reflowTextFromX(x: x - width / 2)
            case .Right:
                reflowTextFromX(x: x - width)
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
    
    /* Désactivé car nécessite de garder un pointeur sur les textes pour ne pas qu'ils s'effacent.
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
            sprite.setBlinking(blinking: blinking)
        }
    }
    
    func setBlinkingWithRate(blinkRate: TimeInterval) {
        for sprite in sprites {
            sprite.setBlinkingWithRate(blinkRate: blinkRate)
        }
    }
    
    func moveToLocation(location: Spot) {
        let differenceX = location.x - x
        let differenceY = location.y - y
        
        for sprite in sprites {
            sprite.x += differenceX
            sprite.y += differenceY
            factory.updateLocationOfSprite(sprite: sprite)
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
                let sprite = spriteForIndex(index: index)
                index += 1
                setFrameOfSprite(sprite: sprite, toCharacter: Int8(c))
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
            sprite = factory.sprite(definition: Sprite.countGUIDefinition)
            sprites.append(sprite)
        }
        
        return sprite
    }
    
    private func setFrameOfSprite(sprite: Sprite, toCharacter value: Int8) {
        if value >= zero && value <= nine {
            // Chiffre.
            sprite.animation = SingleFrameAnimation(definition: sprite.definition.animations[digitAnimation])
            sprite.animation.frameIndex = Int(value - zero)
            
            resizeSprite(sprite: sprite)
            
        } else if value >= upperCaseA && value <= upperCaseZ {
            // Lettre majuscule.
            sprite.animation = SingleFrameAnimation(definition: sprite.definition.animations[upperCaseAnimation])
            sprite.animation.frameIndex = Int(value - upperCaseA)
            
            resizeSprite(sprite: sprite)
            
        } else if value >= lowerCaseA && value <= lowerCaseZ {
            // Lettre minuscule.
            sprite.animation = SingleFrameAnimation(definition: sprite.definition.animations[lowerCaseAnimation])
            sprite.animation.frameIndex = Int(value - lowerCaseA)
            
            resizeSprite(sprite: sprite)
            
        } else if value == semicolon {
            // "Deux points".
            sprite.animation = SingleFrameAnimation(definition: sprite.definition.animations[semicolonAnimation])
            sprite.animation.frameIndex = 0
            
            resizeSprite(sprite: sprite)
            
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
        let utf8Pointer = nsString.utf8String
        
        return utf8Pointer![0]
    }
    
    private func reflowTextFromX(x: GLfloat) {
        let difference = sprites[0].x - x
        
        for sprite in sprites {
            sprite.x -= difference
            factory.updateLocationOfSprite(sprite: sprite)
        }
    }
    
}
