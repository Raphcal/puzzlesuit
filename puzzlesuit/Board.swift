//
//  GameGrid.swift
//  PuzzleSuit
//
//  Created by Raphaël Calabro on 24/01/2016.
//  Copyright © 2016 Raphaël Calabro. All rights reserved.
//

import GLKit

class Board : Square {
    
    let factory : SpriteFactory
    
    let columns = 6
    let rows = 12
    let hiddenRows = 2
    
    var grid : [Sprite?]
    let cardSize : Spot
    
    var detached = 0
    
    init(factory: SpriteFactory, square: Square) {
        self.factory = factory
        self.grid = [Sprite?](count: columns * (rows + hiddenRows), repeatedValue: nil)
        self.cardSize = Spot(x: square.width / GLfloat(columns), y: square.height / GLfloat(rows))
        
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
    
    func spriteBelowSprite(sprite: Sprite) -> Sprite? {
        return grid[indexForX(sprite.x, y: sprite.bottom + 1)]
    }
    
    func attachSprite(sprite: Sprite) {
        detached--
        grid[indexForSprite(sprite)] = sprite
        
        // TODO: Sauvegarder les points de collisions et faire "resolve" à partir de ces points.
    }
    
    func detach() {
        // TODO: Écrire la méthode.
    }
    
    func resolve() {
        for index in 0..<grid.count {
            let x = index % columns
            let y = index / columns
            
        }
    }
    
    private func indexForSprite(sprite: Sprite) -> Int {
        return indexForX(sprite.x, y: sprite.y)
    }
    
    private func indexForX(x: GLfloat, y: GLfloat) -> Int {
        return Int((x - self.x) / cardSize.x) + (Int((y - self.y) / cardSize.y) + hiddenRows) * rows
    }
    
    private func spriteForCard(card: Card) -> Sprite {
        let sprite = factory.sprite(card.suit.rawValue)
        sprite.animation = SingleFrameAnimation(definition: sprite.definition.animations[0])
        sprite.animation.frameIndex = card.value
        
        sprite.x = 2 * cardSize.x  + cardSize.x / 2
        sprite.y = -cardSize.y / 2
        
        return sprite
    }
    
}