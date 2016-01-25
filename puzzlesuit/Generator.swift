//
//  Generator.swift
//  PuzzleSuit
//
//  Created by Raphaël Calabro on 25/01/2016.
//  Copyright © 2016 Raphaël Calabro. All rights reserved.
//

import Foundation

class Generator {
    
    let tiles : [Int]
    
    init(capacity: Int) {
        self.tiles = []
    }
    
    func nextWith(count: Int) {
        return tiles[(count + count / tiles.count) % tiles.count]
    }
    
}