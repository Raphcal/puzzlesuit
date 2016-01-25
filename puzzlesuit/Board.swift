//
//  GameGrid.swift
//  PuzzleSuit
//
//  Created by Raphaël Calabro on 24/01/2016.
//  Copyright © 2016 Raphaël Calabro. All rights reserved.
//

import GLKit

class Board : Square {
    
    let columns = 6
    let rows = 12
    let hiddenRows = 2
    
    var grid : [Sprite?]
    let tile : Spot
    
    override init(left: GLfloat, top: GLfloat, width: GLfloat, height: GLfloat) {
        self.grid = [Sprite?](count: columns * (rows + hiddenRows), repeatedValue: nil)
        self.tile = Spot(x: width / GLfloat(columns), y: height / GLfloat(rows))
        super.init(left: left, top: top, width: width, height: height)
    }
    
    func resolve() {
        // TODO: Écrire la méthode.
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
    
}