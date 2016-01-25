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
    let tile : Spot
    
    init(factory: SpriteFactory, square: Square) {
        self.factory = factory
        self.grid = [Sprite?](count: columns * (rows + hiddenRows), repeatedValue: nil)
        self.tile = Spot(x: square.width / GLfloat(columns), y: square.height / GLfloat(rows))
        
        super.init(square: square)
    }
    
    func resolve() {
        for index in 0..<grid.count {
            let x = index % columns
            let y = index / columns
            
        }
    }
    
    func createCards(mainCard: Card, extraCard: Card) {
        let main = spriteForCard(mainCard)
        let extra = spriteForCard(extraCard)
        
        main.motion = MainCardMotion(extra: extra)
        extra.motion = ExtraCardMotion()
    }
    
    func attachSprite(sprite: Sprite) {
        grid[indexForSprite(sprite)] = sprite
    }
    
    func detach() {
        // TODO: Écrire la méthode.
    }
    
    private func indexForSprite(sprite: Sprite) -> Int {
        return Int((sprite.x - x) / sprite.width) + (Int((sprite.y - y) / sprite.height) + hiddenRows) * rows
    }
    
    private func spriteForCard(card: Card) -> Sprite {
        let sprite = factory.sprite(card.suit.rawValue)
        sprite.animation = SingleFrameAnimation(definition: sprite.definition.animations[0])
        sprite.animation.frameIndex = card.value
        return sprite
    }
    
}