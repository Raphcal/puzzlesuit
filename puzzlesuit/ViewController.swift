//
//  ViewController.swift
//  PuzzleSuit
//
//  Created by Raphaël Calabro on 22/01/2016.
//  Copyright © 2016 Raphaël Calabro. All rights reserved.
//

import Cocoa
import OpenGL.GL

class ViewController: NSViewController {

    @IBOutlet weak var gameView : GameView!
    let director = Director()
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let context = gameView.openGLContext {
            context.makeCurrentContext()
        } else {
            NSLog("Erreur de chargement du contexte OpenGL")
        }
        
        glEnable(GLenum(GL_BLEND))
        glBlendFunc(GLenum(GL_ONE), GLenum(GL_ONE_MINUS_SRC_ALPHA))
        glAlphaFunc(GLenum(GL_GREATER), 0.1)
        glEnable(GLenum(GL_ALPHA_TEST))
        
        glEnable(GLenum(GL_TEXTURE_2D))
        
        glEnableClientState(GLenum(GL_VERTEX_ARRAY))
        glEnableClientState(GLenum(GL_TEXTURE_COORD_ARRAY))
        
        gameView.director = director
        director.start()
        
        gameView.initializeDisplayLink()
    }


}

