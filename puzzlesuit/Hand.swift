//
//  Hand.swift
//  puzzlesuit
//
//  Created by Raphaël Calabro on 01/02/2016.
//  Copyright © 2016 Raphaël Calabro. All rights reserved.
//

import Foundation

enum Hand {
    
    case Flush(suit: Suit, count: Int)
    case SameKind(rank: Rank, count: Int, flush: Bool)
    case Straight(count: Int, flush: Bool)
    
    // TODO: TWO_PAIRS ?
    
    func chips() -> Int {
        switch self {
        case let .Flush(_, count):
            return count - 4
        case let .SameKind(rank, count, flush):
            let multiplier = flush ? 2 : 1
            let base : Int
            if rank == .As {
                base = Board.columns
            } else if rank.rawValue >= Rank.Jack.rawValue && rank.rawValue <= Rank.King.rawValue {
                base = 4
            } else {
                base = 2
            }
            return (base + count - 3) * multiplier
        case let .Straight(count, flush):
            let multiplier = flush ? 2 : 1
            
            return Board.columns * multiplier + (count - 5)
        }
    }
    
    func description() -> String {
        switch self {
        case let .Flush(suit, count):
            return "\(suit) suit \(count) flush (\(chips()))"
        case let .SameKind(rank, count, flush):
            let isFlush = flush ? " flush" : ""
            return "\(count) of \(rank)\(isFlush) (\(chips()))"
        case let .Straight(count, flush):
            let isFlush = flush ? " flush" : ""
            return "\(count) straight\(isFlush) (\(chips()))"
        }
    }
    
}