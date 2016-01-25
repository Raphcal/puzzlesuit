//
//  Card.swift
//  puzzlesuit
//
//  Created by Raphaël Calabro on 25/01/2016.
//  Copyright © 2016 Raphaël Calabro. All rights reserved.
//

import Foundation

struct Card {
    
    let suit : Suit
    let value : Int
    
    init(suit: Suit, value: Int) {
        self.suit = suit
        self.value = value
    }
    
    init(sprite: Sprite) {
        if let suit = Suit(rawValue: sprite.definition.index) {
            self.suit = suit
            self.value = sprite.animation.frameIndex
        } else {
            self.suit = .Club
            self.value = 0
        }
    }
    
}