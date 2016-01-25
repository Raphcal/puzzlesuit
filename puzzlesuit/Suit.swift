//
//  CardColor.swift
//  puzzlesuit
//
//  Created by Raphaël Calabro on 25/01/2016.
//  Copyright © 2016 Raphaël Calabro. All rights reserved.
//

import Foundation

enum Suit : Int {
    
    case Club, Heart, Diamond, Spade
    
    static func all() -> [Suit] {
        return [Club, Heart, Diamond, Spade]
    }
    
}