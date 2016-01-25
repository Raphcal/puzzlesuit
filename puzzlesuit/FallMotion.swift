//
//  FallMotion.swift
//  puzzlesuit
//
//  Created by Raphaël Calabro on 25/01/2016.
//  Copyright © 2016 Raphaël Calabro. All rights reserved.
//

import GLKit

class FallMotion : Motion {
    
    /// Ensemble des sprites situés au dessus de celui-ci et qui vont chuter en même temps.
    let column : [Sprite]
    
    init(column: [Sprite] = []) {
        self.column = column
    }
    
    func load(sprite: Sprite) {
        // Pas de chargement.
    }
    
    func updateWithTimeSinceLastUpdate(timeSinceLastUpdate: NSTimeInterval, sprite: Sprite) {
        // TODO: Écrire la méthode.
        
        sprite.factory.updateLocationOfSprite(sprite)
    }
    
}
