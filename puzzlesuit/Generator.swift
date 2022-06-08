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
        let next = count
        count += 1
        return next
    }
    
}

class Generator {
    
    let cards : [Card]
    
    init() {
        self.cards = []
    }
    
    init(capacity: Int) {
        let deck = Deck()
        self.cards = (0 ..< capacity).map { _ in deck.next() }
    }
    
    func cardForState(state: GeneratorState) -> Card {
        return cards[state.next() % cards.count]
    }
    
}
