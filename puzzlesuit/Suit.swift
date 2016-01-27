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
    
    static let all = [Suit.Club, Heart, Diamond, Spade]
    
}

enum Value : Int {
    
    case As, Two, Three, Four, Jack, Queen, King
    
    static let all = [Value.As, .Two, .Three, .Four, .Jack, .Queen, .King]
    
}