//
//  Scene.swift
//  MeltedIce
//
//  Created by Raphaël Calabro on 29/06/2015.
//  Copyright (c) 2015 Raphaël Calabro. All rights reserved.
//

import Foundation

@objc protocol Scene {
    
    var director : Director? { get set }
    var backgroundColor : Color { get set }
    
    /// Chargement initial de la scène. Appelé lors d'une transition vers cette scène.
    optional func load()
    
    /// Rechargement de la scène. La scène est déjà affiché mais elle doit être rechargée (exemple : mort).
    optional func reload()
    
    /// Libération de la scène. Appelé lors de la transition vers une autre scène.
    optional func unload()
    
    /// La vue devient la scène principale du directeur.
    optional func willAppear()
    
    /// Gestion de la mise à jour de la scène.
    func updateWithTimeSinceLastUpdate(timeSinceLastUpdate: NSTimeInterval)
    
    /// Affichage de la scène.
    func draw()
    
}

protocol PreloadableScene : Scene {
    
    func loadInBackground(operationQueue: NSOperationQueue)
    
}

protocol Fade : Scene {
    
    var progress : Float { get set }
    var previousScene : Scene { get set }
    var nextScene : Scene { get set }
    
}

class NoFade : NSObject, Fade {
    
    var progress : Float = 1
    var previousScene : Scene = EmptyScene()
    var nextScene : Scene = EmptyScene()
    var director : Director? = nil
    var backgroundColor = Color()
    
    func draw() {
        // Pas de dessin.
    }
    
    func updateWithTimeSinceLastUpdate(timeSinceLastUpdate: NSTimeInterval) {
        // Pas de mise à jour.
    }
    
}

