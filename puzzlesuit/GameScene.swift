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
        
        self.leftPlayerGameFlow = flowWithGenerator(generator, size: size, side: .Left)
        self.rightPlayerGameFlow = flowWithGenerator(generator, size: size, side: .Right)
        
        leftPlayerGameFlow.controller = Input.instance
        rightPlayerGameFlow.controller = InstantCpu(fastWhenGoodHandIsFound: false, sameKindScore: 0, sameSuitScore: 4, straightScore: 0, rowMalus: 1)
    }
    
    func updateWithTimeSinceLastUpdate(timeSinceLastUpdate: NSTimeInterval) {
        // Limitation du lag
        let time = min(timeSinceLastUpdate, 0.1)
        
        factory.updateWithTimeSinceLastUpdate(time)
        
        leftPlayerGameFlow.updateWithTimeSinceLastUpdate(time)
        rightPlayerGameFlow.updateWithTimeSinceLastUpdate(time)
    }
    
    func draw() {
        factory.draw()
    }

    private func flowWithGenerator(generator: Generator, size: Spot, side: Side) -> GameFlow {
        let board = Board(factory: factory, square: Square(left: side.boardLeft(size), top: 32, width: size.x, height: size.y))
        return GameFlow(side: side, board: board, generator: generator)
    }
    
}