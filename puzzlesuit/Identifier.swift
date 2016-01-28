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
    let rank : Rank?
    
    convenience init() {
        self.init(suit: nil, rank: nil)
    }
    
    convenience init(rank: Rank) {
        self.init(suit: nil, rank: rank)
    }
    
    convenience init(suit: Suit) {
        self.init(suit: suit, rank: nil)
    }
    
    init(suit: Suit?, rank: Rank?) {
        self.suit = suit
        self.rank = rank
    }
    
    func matches(card: Card) -> Bool {
        if let suit = self.suit where suit != card.suit {
            return false
        }
        if let rank = self.rank where rank != card.rank {
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
    
    func sameKindsAsCard(card: Card, location: BoardLocation, ignore: [BoardLocation]) -> [BoardLocation] {
        ignoreLocations(ignore)
        findCardsMatching(Matcher(rank: card.rank), at: location)
        return result()
    }
    
    func pairsAroundLocations(locations: [BoardLocation], ignore: [BoardLocation]) -> [BoardLocation] {
        ignoreLocations(ignore)
        findPairsAround(locations[0], notInLocation: locations[1])
        findPairsAround(locations[1], notInLocation: locations[0])
        return result()
    }
    
    func sameSuitAsCard(card: Card, location: BoardLocation, ignore: [BoardLocation]) -> [BoardLocation] {
        ignoreLocations(ignore)
        findCardsMatching(Matcher(suit: card.suit), at: location)
        return result()
    }
    
    func straightIncludingCard(card: Card, location: BoardLocation, ignore: [BoardLocation]) -> [BoardLocation] {
        ignoreLocations(ignore)
    
        locations.appendContentsOf(findStraightFromRank(card.rank, suit: card.suit, next: -1, at: location))
        locations.append(location)
        locations.appendContentsOf(findStraightFromRank(card.rank, suit: card.suit, next: 1, at: location))
        
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
                findCardsMatching(Matcher(rank: card.rank), at: nextLocation, from: direction.reverse())
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
    
    private func findStraightFromRank(rank: Rank, suit: Suit, next: Int, at origin: BoardLocation, from: Direction? = nil) -> [BoardLocation] {
        var locations = [BoardLocation]()
        
        if from != nil {
            locations.append(origin)
        }
        
        if let nextRank = rank + next {
            var maximumSameSuitCount = 0
            var maximum = [BoardLocation]()
            
            for to in [Direction.Left, .Up, .Right, .Down] {
                if from != to && canGoTo(to, origin: origin), let other = board.cardAtLocation(origin + to.location()) where other.rank == nextRank {
                    let result = findStraightFromRank(nextRank, suit: suit, next: next, at: origin + to.location(), from: to.reverse())
                    
                    let sameSuitCount = result.reduce(0, combine: { (count, location) -> Int in
                        if let card = board.cardAtLocation(location) where card.suit == suit {
                            return count + 1
                        } else {
                            return count
                        }
                    })
                    
                    if result.count > maximum.count || (result.count == maximum.count && sameSuitCount > maximumSameSuitCount) {
                        maximum = result
                        maximumSameSuitCount = sameSuitCount
                    }
                }
            }
            locations.appendContentsOf(maximum)
        }
        return locations
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
    
    private func ignoreLocations(locations: [BoardLocation]) {
        for location in locations {
            status[location.index()] = true
        }
    }
    
    private func result() -> [BoardLocation] {
        let result = locations
        reset()
        return result
    }
    
    private func reset() {
        self.status = [Bool](count: board.grid.count, repeatedValue: false)
        self.locations.removeAll()
    }
    
}