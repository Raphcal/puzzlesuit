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
    
    let unit : GLfloat = 16
    var flow = GameFlow()
    
    func load() {
        let size = Spot(x: unit * GLfloat(Board.columns), y: unit * GLfloat(Board.rows))
        
        let leftBoard = Board(factory: factory, square: Square(left: 16, top: 32, width: size.x, height: size.y))
        let rightBoard = Board(factory: factory, square: Square(left: View.instance.width - 16 - size.x, top: 32, width: size.x, height: size.y))
        
        let generator = Generator(capacity: 256)
        
        self.flow = GameFlow(board: leftBoard, generator: generator)
    }
    
    func updateWithTimeSinceLastUpdate(timeSinceLastUpdate: NSTimeInterval) {
        factory.updateWithTimeSinceLastUpdate(timeSinceLastUpdate)
        flow.updateWithTimeSinceLastUpdate(timeSinceLastUpdate)
    }
    
    func draw() {
        factory.draw()
    }

    
}