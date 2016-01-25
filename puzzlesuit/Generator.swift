//
//  Generator.swift
//  PuzzleSuit
//
//  Created by Raphaël Calabro on 25/01/2016.
//  Copyright © 2016 Raphaël Calabro. All rights reserved.
//

import Foundation

class GeneratorState {
    
    private var count = 0
    
    func next() -> Int {
        return count++
    }
    
}

class Generator {
    
    let cards : [Card]
    
    init(capacity: Int, highest: Int = 4, suits: [Suit] = Suit.all()) {
        var cards = [Card]()
        
        for _ in 0..<capacity {
            if let suit = Suit(rawValue: Random.next(suits.count)) {
                cards.append(Card(suit: suit, value: Random.next(highest)))
            }
        }
        
        self.cards = cards
    }
    
    func cardForState(state: GeneratorState) -> Card {
        return cards[state.next() % cards.count]
    }
    
}