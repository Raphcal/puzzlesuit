//
//  Side.swift
//  puzzlesuit
//
//  Created by Raphaël Calabro on 28/01/2016.
//  Copyright © 2016 Raphaël Calabro. All rights reserved.
//

import Foundation

class Side {
    
    let controller : Controller
    let board : Board
    
    init(controller: Controller, board: Board) {
        self.controller = controller
        self.board = board
    }
    
    func setMotionForMainSprite(main: Sprite, extraSprite extra: Sprite) {
        main.motion = MainCardMotion(board: board, extra: extra)
        extra.motion = ExtraCardMotion(board: board, main: main)
    }
    
}