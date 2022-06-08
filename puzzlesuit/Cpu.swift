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
            return board.locationForPoint(point: flow.hand[0]).x > target.x
        case .Right:
            return board.locationForPoint(point: flow.hand[0]).x < target.x
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
        target = BoardLocation(x: Random.next(range: Board.columns), y: 0)
        targetDirection = Direction.circle[Random.next(range: Direction.circle.count)]
    }
    
}

class InstantCpu : BaseCpu, Cpu {
    
    let fast : Bool
    let fastWhenGoodHandIsFound : Bool
    
    let sameKindScore : Int
    let sameSuitScore : Int
    let straightScore : Int
    let rowScore : Int
    
    let preferSides : Bool
    
    init(fast: Bool = false, fastWhenGoodHandIsFound: Bool = false, sameKindScore: Int = 0, sameSuitScore: Int = 0, straightScore: Int = 0, rowScore : Int = 0, preferSides: Bool = false) {
        self.fast = fast
        self.fastWhenGoodHandIsFound = fast || fastWhenGoodHandIsFound
        self.sameKindScore = sameKindScore
        self.sameSuitScore = sameSuitScore
        self.straightScore = straightScore
        self.rowScore = rowScore
        self.preferSides = preferSides
    }
    
    func handChanged(hand: [Card], nextHand: [Card]) {
        self.down = fast
        
        let main = bestLocationForCard(card: hand[0])
        let extra = bestLocationForCard(card: hand[1])
        
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
        
        var bestColumn = preferSides ? Random.next(range: 2) * Board.columns : Random.next(range: Board.columns)
        var bestScore = 0
        
        let identifier = Identifier(board: flow.board)
        for column in 0..<Board.columns {
            if let top = board.topOfColumn(column: column) {
                let sameKind = identifier.sameKindsAsCard(card: card, location: top, ignore: []).count - 1
                let sameSuit = identifier.sameSuitAsCard(card: card, location: top, ignore: []).count - 1
                let straight = identifier.straightIncludingCard(card: card, location: top, ignore: []).count - 1

                // Voir s'il faut plutôt limiter à la colonne 2
                let row = top.y - Board.hiddenRows
                
                let score = sameKind * sameKindScore
                    + straight * straightScore
                    + sameSuit * sameSuitScore
                    + row * rowScore
                
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

class HandCpu : BaseCpu, Cpu {
    
    func handChanged(hand: [Card], nextHand: [Card]) {
        self.down = true
        
        let main = bestLocationForCard(card: hand[0])
        let extra = bestLocationForCard(card: hand[1])
        
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
        let board = flow.board
        
        var bestColumn = Random.next(range: Board.columns)
        var bestScore = 0
        
        let identifier = Identifier(board: flow.board)
        for column in 0..<Board.columns {
            if let top = board.topOfColumn(column: column) {
                // TODO: Calculer un score (positif) pour la hauteur (plus c'est bas, plus le score est élevé)
                
                let hands = identifier.handsForCard(card: card, atLocation: top)
                
                var score = 0
                for hand in hands {
                    score += hand.hand.chips()
                }
                
                if score > bestScore {
                    bestScore = score
                    bestColumn = column
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
        let zone = preferredZoneForHand(hand: hand)
        
        // TODO: Diviser la zone en plus petites zones.
        let allCards = hand + nextHand
        
        if zone.aim == nil {
            zone.aim = aimForCards(cards: allCards)
        }
        
        switch zone.aim! {
        case .Flush:
            self.target = flushTargetForHand(hand: hand, inZone: zone, board: flow.board)
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
                    suitCount += 1
                }
                if card.rank == zone.preferredRank {
                    rankCount += 1
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
        var suits = [Int](repeating: 0, count: Suit.all.count)
        var ranks = [Int](repeating: 0, count: Rank.all.count)
        
        for card in cards {
            suits[card.suit.rawValue] += 1
            ranks[card.rank.rawValue] += 1
        }
        
        let maxSuitCount = suits.max()!
        let maxRankCount = ranks.max()!
        
        // TODO: Gérer les suites (straight).
        
        if maxSuitCount > maxRankCount {
            return .Flush(suit: Suit(rawValue: suits.firstIndex(of: maxSuitCount)!)!)
        } else {
            return .SameKinds(rank: Rank(rawValue: ranks.firstIndex(of: maxRankCount)!)!)
        }
    }
    
    private func flushTargetForHand(hand: [Card], inZone zone: Zone, board: Board) -> BoardLocation {
        // TODO: Décider l'emplacement du bloc actuel.
        return BoardLocation(x: 0, y: 0)
    }
    
}
