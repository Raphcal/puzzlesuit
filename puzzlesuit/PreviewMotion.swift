//
//  PreviewMotion.swift
//  puzzlesuit
//
//  Created by Raphaël Calabro on 29/01/2016.
//  Copyright © 2016 Raphaël Calabro. All rights reserved.
//

import GLKit

class PreviewMotion : Motion {
    
    func load(sprite: Sprite) {
        // Pas d'initialisation.
    }
    
    func updateWithTimeSinceLastUpdate(timeSinceLastUpdate: NSTimeInterval, sprite: Sprite) {
        // TODO: Écrire la méthode.
    }
    
    func swapToCards(cards: [Card]) {
        // TODO: Faire descendre le sprite (1 instance pas Sprite) et lorsqu'il atteint sa cible (sprite.y + sprite.height * 2), changer son image puis le faire réapparaître depuis le haut (de sprite.y - sprite.height * 4) jusqu'à sa position initiale. Utiliser Math.smooth pour les déplacements.
    }
    
}
