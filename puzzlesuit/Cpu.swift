//
//  AI.swift
//  PuzzleSuit
//
//  Created by Raphaël Calabro on 28/01/2016.
//  Copyright © 2016 Raphaël Calabro. All rights reserved.
//

import Foundation

enum Aim {
    
    case NoAim, Clean, Flush, SameKinds, Straight, Chain
    
}

enum ZoneUse {
    
    case NotUsed, Garbage, Chain
    
}

struct Zone {
    
    var use = ZoneUse.NotUsed
    var aim = Aim.NoAim
    var preferredSuit : Suit?
    var preferredRank : Rank?
    var from = 0
    var to = Board.columns
    
}

class Cpu : Controller {
    
    // MARK: - Gestion des contrôles
    
    var direction : GLfloat = 0
    
    var zones = [Zone()]
    
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
        
        if zone.aim == .NoAim {
            
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
    
}