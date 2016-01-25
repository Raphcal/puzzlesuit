//
//  GameGrid.swift
//  PuzzleSuit
//
//  Created by Raphaël Calabro on 24/01/2016.
//  Copyright © 2016 Raphaël Calabro. All rights reserved.
//

import GLKit

struct BoardLocation {
    
    let x : Int
    let y : Int
    
    func index() -> Int {
        return y * Board.columns + x
    }
    
}

class Board : Square {
    
    static let columns = 6
    static let rows = 12
    static let hiddenRows = 2
    
    let factory : SpriteFactory
    
    var grid : [Sprite?]
    let cardSize : Spot
    
    var detached = 0
    
    var dirty = [BoardLocation]()
    
    override init() {
        self.factory = SpriteFactory()
        self.grid = []
        self.cardSize = Spot()
        
        super.init()
    }
    
    init(factory: SpriteFactory, square: Square) {
        self.factory = factory
        self.grid = [Sprite?](count: Board.columns * (Board.rows + Board.hiddenRows), repeatedValue: nil)
        self.cardSize = Spot(x: square.width / GLfloat(Board.columns), y: square.height / GLfloat(Board.rows))
        
        super.init(square: square)
    }
    
    func spritesForMainCard(mainCard: Card, andExtraCard extraCard: Card) -> [Sprite] {
        let main = spriteForCard(mainCard)
        let extra = spriteForCard(extraCard)
        
        extra.y -= cardSize.y
        
        main.motion = MainCardMotion(extra: extra)
        extra.motion = ExtraCardMotion(main: main)
        
        let sprites = [main, extra]
        detached += sprites.count
        
        return sprites
    }
    
    func isAboveSomething(sprite: Sprite) -> Bool {
        let location = locationForX(sprite.x, y: sprite.bottom + 1)
        return location.y >= (Board.rows + Board.hiddenRows) || grid[location.index()] != nil
    }
    
    func attachSprite(sprite: Sprite) throws {
        detached--
        
        let location = locationForSprite(sprite)
        dirty.append(location)
        
        if location.x == 2 && location.y == 1 {
            throw GameError.Lost
        }
        
        let index = location.index()
        grid[index] = sprite
        
        // Correction de la position
        sprite.x = self.left + cardSize.x * GLfloat(location.x)
        sprite.y = self.top + cardSize.y * GLfloat(location.y)
    }
    
    func detachSpriteAtIndex(index: Int) {
        // TODO: Écrire la méthode.
        // Calculer à partir du contenu de dirty.
    }
    
    func resolve() {
        for location in dirty {
            // TODO: Vérifier les mains possibles.
        }
    }
    
    private func locationForSprite(sprite: Sprite) -> BoardLocation {
        return locationForX(sprite.x, y: sprite.y)
    }
    
    private func locationForX(x: GLfloat, y: GLfloat) -> BoardLocation {
        return BoardLocation(x: Int((x - self.left) / cardSize.x), y: Int((y - self.top) / cardSize.y) + Board.hiddenRows)
    }
    
    private func spriteForCard(card: Card) -> Sprite {
        let sprite = factory.sprite(card.suit.rawValue)
        sprite.animation = SingleFrameAnimation(definition: sprite.definition.animations[0])
        sprite.animation.frameIndex = card.value
        
        sprite.x = 2 * cardSize.x  + cardSize.x / 2
        sprite.y = -cardSize.y / 2
        sprite.width = cardSize.x
        sprite.height = cardSize.y
        
        return sprite
    }
    
}