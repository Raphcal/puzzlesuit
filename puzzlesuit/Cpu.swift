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

class BaseCpu : Controller {
    
    var flow = GameFlow()
    var target = BoardLocation(x: 0, y: 0)
    var targetDirection = Direction.Up
    
    var down = false
    
    // MARK: - Gestion des contrôles
    
    var direction : GLfloat = 0
    
    func pressed(button: GamePadButton) -> Bool {
        let board = flow.board
        
        let currentDirection = (flow.hand[1].motion as! ExtraCardMotion).direction
        
        switch button {
        case .Left:
            return board.locationForPoint(flow.hand[0]).x > target.x
        case .Right:
            return board.locationForPoint(flow.hand[0]).x < target.x
        case .RotateLeft:
            switch currentDirection {
            case .Up:
                return targetDirection == .Left || targetDirection == .Down
            case .Left:
                return targetDirection == .Down
            case .Down:
                return targetDirection == .Right || targetDirection == .Up
            case .Right:
                return targetDirection == .Up || targetDirection == .Left
            }
        case .RotateRight:
            switch currentDirection {
            case .Up:
                return targetDirection == .Right || targetDirection == .Down
            case .Right:
                return targetDirection == .Down || targetDirection == .Left
            case .Down:
                return targetDirection == .Left || targetDirection == .Up
            case .Left:
                return targetDirection == .Up || targetDirection == .Right
            }
        default:
            return false
        }
    }
    
    func pressing(button: GamePadButton) -> Bool {
        return button == .Down && down
    }
    
    func draw() {
        // Pas d'affichage.
    }
    
    func updateWithTouches(touches: [Int : Spot]) {
        // Pas d'utilisation de l'écran tactile.
    }
    
}

class RandomCpu : BaseCpu, Cpu {
    
    func handChanged(hand: [Card], nextHand: [Card]) {
        target = BoardLocation(x: Random.next(Board.columns), y: 0)
        targetDirection = Direction.circle[Random.next(Direction.circle.count)]
        NSLog("Colonne \(target.x), rotation : \(targetDirection)")
    }
    
}

class InstantCpu : BaseCpu, Cpu {
    
    let fastWhenGoodHandIsFound : Bool
    
    let sameKindScore : Int
    let sameSuitScore : Int
    let straightScore : Int
    let rowMalus : Int
    
    init(fastWhenGoodHandIsFound: Bool = true, sameKindScore: Int = 2, sameSuitScore: Int = 1, straightScore: Int = 1, rowMalus : Int = 4) {
        self.fastWhenGoodHandIsFound = fastWhenGoodHandIsFound
        self.sameKindScore = sameKindScore
        self.sameSuitScore = sameSuitScore
        self.straightScore = straightScore
        self.rowMalus = 4
    }
    
    func handChanged(hand: [Card], nextHand: [Card]) {
        self.down = false
        
        let main = bestLocationForCard(hand[0])
        let extra = bestLocationForCard(hand[1])
        
        if abs(main.location.x - extra.location.x) == 1 {
            // Les 2 meilleures cases sont voisines.
            self.target = main.location
            if main.location.x < extra.location.x {
                self.targetDirection = .Right
            } else {
                self.targetDirection = .Left
            }
        } else if main.score > extra.score {
            self.target = main.location
            self.targetDirection = .Up
        } else {
            self.target = extra.location
            self.targetDirection = .Down
        }
    }
    
    private func bestLocationForCard(card: Card) -> (location: BoardLocation, score: Int) {
        // TODO: Éviter de faire une boucle par carte.
        let board = flow.board
        
        var bestColumn = Random.next(Board.columns)
        var bestScore = 0
        
        let identifier = Identifier(board: flow.board)
        for column in 0..<Board.columns {
            if let top = board.topOfColumn(column) {
                let sameKind = identifier.sameKindsAsCard(card, location: top, ignore: []).count - 1
                let sameSuit = identifier.sameSuitAsCard(card, location: top, ignore: []).count - 1
                let straight = identifier.straightIncludingCard(card, location: top, ignore: []).count - 1

                // Voir s'il faut plutôt limiter à la colonne 2
                let rowScore = (top.y - Board.hiddenRows - Board.rows) / rowMalus
                
                // TODO: Calculer les suites aussi.
                
                let score = sameKind * sameKindScore + straight * straightScore + sameSuit * sameSuitScore + rowScore
                if score > bestScore {
                    bestScore = score
                    bestColumn = column
                    self.down = fastWhenGoodHandIsFound
                }
            }
        }
        
        // TODO: Renvoyer nil quand aucun emplacement n'est considéré bon.
        return (location: BoardLocation(x: bestColumn, y: 0), score: bestScore)
    }
    
}

class ZoneCpu : BaseCpu, Cpu {
    
    var zones = [Zone()]
    
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
    
    private func flushTargetForHand(hand: [Card], inZone zone: Zone, board: Board) -> BoardLocation {
        // TODO: Décider l'emplacement du bloc actuel.
        return BoardLocation(x: 0, y: 0)
    }
    
}