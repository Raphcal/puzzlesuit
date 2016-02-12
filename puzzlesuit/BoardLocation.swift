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
    
    static func centerOfLocations(locations: [BoardLocation]) -> BoardLocation {
        var x = 0
        var y = 0
        
        for location in locations {
            x += location.x
            y += location.y
        }
        
        return BoardLocation(x: x / locations.count, y: y / locations.count)
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
