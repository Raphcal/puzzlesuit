//
//  Identifier.swift
//  puzzlesuit
//
//  Created by Raphaël Calabro on 26/01/2016.
//  Copyright © 2016 Raphaël Calabro. All rights reserved.
//

import Foundation

class Identifier {
    
    let board : Board
    var status : [Bool]
    
    var locations = [BoardLocation]()
    
    init(board: Board) {
        self.board = board
        self.status = [Bool](count: board.grid.count, repeatedValue: false)
    }
    
    func locationsOfSameKindAsCard(card: Card, location: BoardLocation) -> [BoardLocation] {
        locations(card, origin: location, from: nil)
        return locations
    }
    
    private func locations(card: Card, origin: BoardLocation, from: Direction?) {
        self.locations.append(origin)
        status[origin.index()] = true
        
        for direction in [Direction.Left, .Up, .Right, .Down] {
            goTo(direction, from: from, origin: origin, card: card)
        }
    }
    
    private func goTo(to: Direction, from: Direction?, origin: BoardLocation, card: Card) {
        if from != to && canGoTo(to, origin: origin), let other = board.cardAtLocation(origin + to.location()) where other.value == card.value {
            locations(card, origin: origin + to.location(), from: to.reverse())
        }
    }
    
    private func canGoTo(to: Direction, origin: BoardLocation) -> Bool {
        let nextIndex = (origin + to.location()).index()
        switch to {
        case .Left:
            return origin.x > 0 && !status[nextIndex]
        case .Right:
            return origin.x < Board.columns - 1 && !status[nextIndex]
        case .Up:
            return origin.y > 0 && !status[nextIndex]
        case .Down:
            return origin.y < Board.rows + Board.hiddenRows - 1 && !status[nextIndex]
        }
    }
    
}