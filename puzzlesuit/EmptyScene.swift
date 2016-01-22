//
//  EmptyScene.swift
//  MeltedIce
//
//  Created by Raphaël Calabro on 02/09/2015.
//  Copyright (c) 2015 Raphaël Calabro. All rights reserved.
//

import Foundation

/// Scène vide.
class EmptyScene : NSObject, Scene {
    
    var director : Director?
    var backgroundColor : Color = Color()
    
    func updateWithTimeSinceLastUpdate(timeSinceLastUpdate: NSTimeInterval) {
        // Pas de mise à jour.
    }
    
    func draw() {
        // Pas de dessin.
    }
    
}