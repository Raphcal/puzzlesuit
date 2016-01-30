//
//  AI.swift
//  PuzzleSuit
//
//  Created by Raphaël Calabro on 28/01/2016.
//  Copyright © 2016 Raphaël Calabro. All rights reserved.
//

import Foundation

enum Aim {
    
    case Clean, Flush(suit: Suit), SameKinds(rank: Rank), Straight, Chain
    
}

enum ZoneUse {
    
    case NotUsed, Garbage, Chain
    
}

class Wait {
    
    var rank : Rank?
    var suit : Suit?
    var spot : Spot = Spot()
    
}

class Zone {
    
    var use = ZoneUse.NotUsed
    var aim : Aim?
    var preferredSuit : Suit?
    var preferredRank : Rank?
    var from = 0
    var to = Board.columns
    var waits = [Wait]()
    
}

protocol Cpu {
    
    var flow : GameFlow { get set }
    
    func handChanged(hand: [Card], nextHand: [Card])
    
}

class BaseCpu : Controller, Cpu {
    
    var flow = GameFlow()
    var target = Spot()
    
    // MARK: - Gestion des contrôles
    
    var direction : GLfloat = 0
    
    func pressed(button: GamePadButton) -> Bool {
        let board = flow.board
        
        let handLocation = board.locationForPoint(flow.hand[0])
        let targetLocation = board.locationForPoint(target)
        
        if handLocation.x > targetLocation.x {
            return button == .Left
        } else if handLocation.x < targetLocation.x {
            return button == .Right
        } else {
            return false
        }
    }
    
    func pressing(button: GamePadButton) -> Bool {
        return false
    }
    
    func draw() {
        // Pas d'affichage.
    }
    
    func updateWithTouches(touches: [Int : Spot]) {
        // Pas d'utilisation de l'écran tactile.
    }
    
    // MARK: - Fonctions spécifiques
    
    func handChanged(hand: [Card], nextHand: [Card]) {
        let column = Random.next(Board.columns)
        target = Spot(x: GLfloat(column) * flow.hand[0].width + flow.board.left, y: 0)
        NSLog("Colonne \(column) (\(target.x))")
    }
    
}

class ZoneCpu : Controller, Cpu {
    
    var flow = GameFlow()
    var zones = [Zone()]
    var target = Spot()
    
    // MARK: - Gestion des contrôles
    
    var direction : GLfloat = 0
    
    func pressed(button: GamePadButton) -> Bool {
        return false
    }
    
    func pressing(button: GamePadButton) -> Bool {
        return false
    }
    
    func draw() {
        // Pas d'affichage.
    }
    
    func updateWithTouches(touches: [Int : Spot]) {
        // Pas d'utilisation de l'écran tactile.
    }
    
    // MARK: - Fonctions spécifiques
    
    func handChanged(hand: [Card], nextHand: [Card]) {
        NSLog("Coucou")
        
        let zone = preferredZoneForHand(hand)
        
        // TODO: Diviser la zone en plus petites zones.
        let allCards = hand + nextHand
        
        if zone.aim == nil {
            zone.aim = aimForCards(allCards)
        }
        
        switch zone.aim! {
        case let .Flush(suit):
            self.target = flushTargetForHand(hand, inZone: zone, board: flow.board)
        default:
            break
        }
    }
    
    private func preferredZoneForHand(hand: [Card]) -> Zone {
        var preferredZone : Zone? = nil
        
        var bestSuitZone : Zone? = nil
        var bestSuitCount = -1
        
        var bestRankZone : Zone? = nil
        var bestRankCount = -1
        
        for zone in zones {
            var suitCount = 0
            var rankCount = 0
            
            for card in hand {
                if card.suit == zone.preferredSuit {
                    suitCount++
                }
                if card.rank == zone.preferredRank {
                    rankCount++
                }
            }
            
            if suitCount > bestSuitCount {
                bestSuitCount = suitCount
                bestSuitZone = zone
            }
            if rankCount > bestRankCount {
                bestRankCount = rankCount
                bestRankZone = zone
            }
        }
        
        if bestSuitCount > bestRankCount {
            preferredZone = bestSuitZone
        } else {
            preferredZone = bestRankZone
        }
        
        return preferredZone!
    }
    
    private func aimForCards(cards: [Card]) -> Aim {
        var suits = [Int](count: Suit.all.count, repeatedValue: 0)
        var ranks = [Int](count: Rank.all.count, repeatedValue: 0)
        
        for card in cards {
            suits[card.suit.rawValue]++
            ranks[card.rank.rawValue]++
        }
        
        let maxSuitCount = suits.maxElement()!
        let maxRankCount = ranks.maxElement()!
        
        // TODO: Gérer les suites (straight).
        
        if maxSuitCount > maxRankCount {
            return .Flush(suit: Suit(rawValue: suits.indexOf(maxSuitCount)!)!)
        } else {
            return .SameKinds(rank: Rank(rawValue: ranks.indexOf(maxRankCount)!)!)
        }
    }
    
    private func flushTargetForHand(hand: [Card], inZone zone: Zone, board: Board) -> Spot {
        // TODO: Décider l'emplacement du bloc actuel.
        return Spot()
    }
    
}