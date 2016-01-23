//
//  GameScene.swift
//  PuzzleSuit
//
//  Created by Raphaël Calabro on 23/01/2016.
//  Copyright © 2016 Raphaël Calabro. All rights reserved.
//

import GLKit

class GameScene : NSObject, Scene {
    
    var director : Director!
    var backgroundColor = Color(red: 1, green: 1, blue: 1)
    
    let factory = SpriteFactory(capacity: 255)
    
    func load() {
        let sprite1 = factory.sprite(0)
        let sprite2 = factory.sprite(6)
        
        sprite1.center = Spot(x: View.instance.width / 2, y: 48)
        sprite2.center = Spot(x: View.instance.width / 2, y: 16)
    }
    
    func updateWithTimeSinceLastUpdate(timeSinceLastUpdate: NSTimeInterval) {
        factory.updateWithTimeSinceLastUpdate(timeSinceLastUpdate)
    }
    
    func draw() {
        factory.draw()
    }

    
}