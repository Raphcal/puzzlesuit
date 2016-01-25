//
//  GameScene.swift
//  PuzzleSuit
//
//  Created by Raphaël Calabro on 23/01/2016.
//  Copyright © 2016 Raphaël Calabro. All rights reserved.
//

import GLKit

class GameScene : NSObject, Scene {
    
    var director : Director!
    var backgroundColor = Color(red: 1, green: 1, blue: 1)
    
    let factory = SpriteFactory(capacity: 255)
    
    let size : GLfloat = 16
    var flow = GameFlow()
    
    func load() {
        let margin = (View.instance.height - size * GLfloat(Board.rows)) / 2
        let board = Board(factory: factory, square: Square(left: margin, top: margin, width: size * GLfloat(Board.columns), height: size * GLfloat(Board.rows)))
        let generator = Generator(capacity: 256)
        self.flow = GameFlow(board: board, generator: generator)
    }
    
    func updateWithTimeSinceLastUpdate(timeSinceLastUpdate: NSTimeInterval) {
        factory.updateWithTimeSinceLastUpdate(timeSinceLastUpdate)
        flow.updateWithTimeSinceLastUpdate(timeSinceLastUpdate)
    }
    
    func draw() {
        factory.draw()
    }

    
}