//
//  Identifier.swift
//  puzzlesuit
//
//  Created by Raphaël Calabro on 26/01/2016.
//  Copyright © 2016 Raphaël Calabro. All rights reserved.
//

import Foundation

class Matcher {
    
    let suit : Suit?
    let value : Int?
    
    convenience init() {
        self.init(suit: nil, value: nil)
    }
    
    convenience init(value: Int) {
        self.init(suit: nil, value: value)
    }
    
    convenience init(suit: Suit) {
        self.init(suit: suit, value: nil)
    }
    
    init(suit: Suit?, value: Int?) {
        self.suit = suit
        self.value = value
    }
    
    func matches(card: Card) -> Bool {
        if let suit = self.suit where suit != card.suit {
            return false
        }
        if let value = self.value where value != card.value {
            return false
        }
        return true
    }
    
}

class Identifier {
    
    let board : Board
    var status : [Bool]
    
    var locations = [BoardLocation]()
    
    init(board: Board) {
        self.board = board
        self.status = [Bool](count: board.grid.count, repeatedValue: false)
    }
    
    func sameKindsAsCard(card: Card, location: BoardLocation) -> [BoardLocation] {
        findCardsMatching(Matcher(value: card.value), at: location)
        return result()
    }
    
    func pairsAroundLocations(locations: [BoardLocation], ignore: [BoardLocation]) -> [BoardLocation] {
        for location in ignore {
            status[location.index()] = true
        }
        findPairsAround(locations[0], notInLocation: locations[1])
        findPairsAround(locations[1], notInLocation: locations[0])
        return result()
    }
    
    func sameSuitAsCard(card: Card, location: BoardLocation) -> [BoardLocation] {
        findCardsMatching(Matcher(suit: card.suit), at: location)
        return result()
    }
    
    func isFlush(locations: [BoardLocation]) -> Bool {
        var reference : Card? = nil
        
        for location in locations {
            if let card = board.cardAtLocation(location) {
                if let other = reference {
                    if card.suit != other.suit {
                        return false
                    }
                } else {
                    reference = card
                }
            }
        }
        
        return true
    }
    
    private func findPairsAround(location: BoardLocation, notInLocation other: BoardLocation) {
        var oldLocations = self.locations
        
        status[location.index()] = true
        
        for direction in [Direction.Left, .Up, .Right, .Down] {
            let nextLocation = location + direction.location()
            
            if nextLocation != other && canGoTo(direction, origin: location), let card = board.cardAtLocation(nextLocation) {
                findCardsMatching(Matcher(value: card.value), at: nextLocation, from: direction.reverse())
            }
            
            if locations.count == oldLocations.count + 1 {
                self.locations = oldLocations
            } else {
                oldLocations = self.locations
            }
        }
    }
    
    private func findCardsMatching(matcher: Matcher, at origin: BoardLocation, from: Direction? = nil) {
        self.locations.append(origin)
        status[origin.index()] = true
        
        for direction in [Direction.Left, .Up, .Right, .Down] {
            goTo(direction, from: from, origin: origin, matcher: matcher)
        }
    }
    
    private func goTo(to: Direction, from: Direction?, origin: BoardLocation, matcher: Matcher) {
        if from != to && canGoTo(to, origin: origin), let other = board.cardAtLocation(origin + to.location()) where matcher.matches(other) {
            findCardsMatching(matcher, at: origin + to.location(), from: to.reverse())
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
    
    private func result() -> [BoardLocation] {
        let result = locations
        
        self.status = [Bool](count: board.grid.count, repeatedValue: false)
        self.locations.removeAll()
        
        return result
    }
    
}