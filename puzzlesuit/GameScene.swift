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
    var leftPlayerGameFlow = GameFlow()
    var rightPlayerGameFlow = GameFlow()
    
    func load() {
        let size = Spot(x: unit * GLfloat(Board.columns), y: unit * GLfloat(Board.rows))
        let generator = Generator(capacity: 256)
        
        self.leftPlayerGameFlow = flowWithGenerator(generator, size: size, left: 16)
        self.rightPlayerGameFlow = flowWithGenerator(generator, size: size, left: View.instance.width - 16 - size.x)
        
        leftPlayerGameFlow.controller = Input.instance
        rightPlayerGameFlow.controller = BaseCpu()
    }
    
    func updateWithTimeSinceLastUpdate(timeSinceLastUpdate: NSTimeInterval) {
        factory.updateWithTimeSinceLastUpdate(timeSinceLastUpdate)
        
        leftPlayerGameFlow.updateWithTimeSinceLastUpdate(timeSinceLastUpdate)
        rightPlayerGameFlow.updateWithTimeSinceLastUpdate(timeSinceLastUpdate)
    }
    
    func draw() {
        factory.draw()
    }

    private func flowWithGenerator(generator: Generator, size: Spot, left: GLfloat) -> GameFlow {
        let board = Board(factory: factory, square: Square(left: left, top: 32, width: size.x, height: size.y))
        return GameFlow(board: board, generator: generator)
    }
    
}