//
//  BoardLocation.swift
//  puzzlesuit
//
//  Created by Raphaël Calabro on 28/01/2016.
//  Copyright © 2016 Raphaël Calabro. All rights reserved.
//

import Foundation

struct BoardLocation {
    
    let x : Int
    let y : Int
    
    func index() -> Int {
        return y * Board.columns + x
    }
    
}

func + (left: BoardLocation, right: BoardLocation) -> BoardLocation {
    return BoardLocation(x: left.x + right.x, y: left.y + right.y)
}

func == (left: BoardLocation, right: BoardLocation) -> Bool {
    return left.x == right.x && left.y == right.y
}

func != (left: BoardLocation, right: BoardLocation) -> Bool {
    return left.x != right.x || left.y != right.y
}

func += (inout left: BoardLocation, right: BoardLocation) {
    left = left + right
}
