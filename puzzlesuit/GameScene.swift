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
    
    let boardFactory = SpriteFactory(capacity: 192)
    let uiFactory = SpriteFactory(capacity: 64)
    
    let unit : GLfloat = 16
    var leftPlayerGameFlow = GameFlow()
    var rightPlayerGameFlow = GameFlow()
    
    var grid : Grid?
    
    func load() {
        let size = Spot(x: unit * GLfloat(Board.columns), y: unit * GLfloat(Board.rows))
        let generator = Generator(capacity: 256)
        
        self.leftPlayerGameFlow = flowWithGenerator(generator, size: size, side: .Left)
        self.rightPlayerGameFlow = flowWithGenerator(generator, size: size, side: .Right)
        
        leftPlayerGameFlow.controller = Input.instance
        rightPlayerGameFlow.controller = InstantCpu(fastWhenGoodHandIsFound: false, sameKindScore: 0, sameSuitScore: 4, straightScore: 0, rowMalus: 1)
        
        if let palette = Palette(resource: "palette0"), let map = Map(resource: "map0") {
            palette.loadTexture()
            self.grid = Grid(palette: palette, map: map)
        }
    }
    
    func unload() {
        if let grid = self.grid {
            Resources.releaseTexture(grid.palette.texture)
        }
    }
    
    func updateWithTimeSinceLastUpdate(timeSinceLastUpdate: NSTimeInterval) {
        // Limitation du lag
        let time = min(timeSinceLastUpdate, 0.1)
        
        boardFactory.updateWithTimeSinceLastUpdate(time)
        uiFactory.updateWithTimeSinceLastUpdate(time)
        
        leftPlayerGameFlow.updateWithTimeSinceLastUpdate(time)
        rightPlayerGameFlow.updateWithTimeSinceLastUpdate(time)
    }
    
    func draw() {
        grid?.drawFrom(0, to: 1)
        boardFactory.draw()
        grid?.drawFrom(1, to: 3)
        uiFactory.draw()
    }

    private func flowWithGenerator(generator: Generator, size: Spot, side: Side) -> GameFlow {
        let board = Board(factory: boardFactory, square: Square(left: side.boardLeft(size), top: 32, width: size.x, height: size.y))
        return GameFlow(side: side, board: board, generator: generator, factory: uiFactory)
    }
    
}