//
//  PlayerMotion.swift
//  PuzzleSuit
//
//  Created by Raphaël Calabro on 24/01/2016.
//  Copyright © 2016 Raphaël Calabro. All rights reserved.
//

import GLKit

class MainCardMotion : Motion {
    
    let extra : Sprite
    
    init(extra: Sprite) {
        self.extra = extra
    }
    
    func load(sprite: Sprite) {
        // Pas de chargement.
    }
    
    func updateWithTimeSinceLastUpdate(timeSinceLastUpdate: NSTimeInterval, sprite: Sprite) {
        if Input.instance.pressed(.RotateLeft) {
            
        }
    }
    
}

class ExtraCardMotion : Motion {
    
    var rotating = false
    
    func load(sprite: Sprite) {
        // Pas de chargement.
    }
    
    func updateWithTimeSinceLastUpdate(timeSinceLastUpdate: NSTimeInterval, sprite: Sprite) {
        // TODO: Écrire la méthode.
    }
    
}
