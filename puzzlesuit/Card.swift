//
//  Card.swift
//  puzzlesuit
//
//  Created by Raphaël Calabro on 25/01/2016.
//  Copyright © 2016 Raphaël Calabro. All rights reserved.
//

import Foundation

protocol Entry {

    // func sprite() -> Sprite
    
}

struct Card : Entry {
    
    let suit : Suit
    let rank : Rank
    
    init(suit: Suit, rank: Rank) {
        self.suit = suit
        self.rank = rank
    }
    
    init(sprite: Sprite) {
        if let suit = Suit(rawValue: sprite.definition.index), let rank = Rank(rawValue: sprite.animation.frameIndex) {
            self.suit = suit
            self.rank = rank
        } else {
            self.suit = .Club
            self.rank = .As
        }
    }
    
}

struct Chip : Entry {
    // Pas de comportement particulier.
}