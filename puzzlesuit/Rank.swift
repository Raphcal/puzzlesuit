//
//  Rank.swift
//  puzzlesuit
//
//  Created by Raphaël Calabro on 28/01/2016.
//  Copyright © 2016 Raphaël Calabro. All rights reserved.
//

import Foundation

enum Rank : Int {
    
    case As, Two, Three, Four, Jack, Queen, King
    
    static let all = [Rank.As, .Two, .Three, .Four, .Jack, .Queen, .King]
    
}

func + (left: Rank, right: Int) -> Rank? {
    return Rank(rawValue: left.rawValue + right)
}
