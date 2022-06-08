//
//  Deck.swift
//  PuzzleSuit
//
//  Created by Raphaël Calabro on 27/01/2016.
//  Copyright © 2016 Raphaël Calabro. All rights reserved.
//

import Foundation

class Deck {
    
    var cards = [Card]()
    
    func next() -> Card {
        if cards.count == 0 {
            fillDeck()
        }
        return cards.remove(at: Random.next(range: cards.count))
    }
    
    private func fillDeck() {
        for suit in Suit.all {
            for value in Rank.all {
                cards.append(Card(suit: suit, rank: value))
            }
        }
    }
    
}
