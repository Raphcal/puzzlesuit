//
//  TitleScene.swift
//  puzzlesuit
//
//  Created by Raphaël Calabro on 10/02/2016.
//  Copyright © 2016 Raphaël Calabro. All rights reserved.
//

import GLKit

class TitleScene : NSObject, Scene {
    
    var director : Director!
    var backgroundColor = Color(red: 1, green: 1, blue: 1)
    
    func load() {
        // TODO: À écrire.
    }
    
    func updateWithTimeSinceLastUpdate(timeSinceLastUpdate: NSTimeInterval) {
        if Input.instance.pressed(.Start) {
            director.nextScene = GameScene()
        }
    }
    
    func draw() {
        // TODO: À écrire.
    }
    
}