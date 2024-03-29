//
//  FadeScene.swift
//  MeltedIce
//
//  Created by Raphaël Calabro on 02/09/2015.
//  Copyright (c) 2015 Raphaël Calabro. All rights reserved.
//

import GLKit

class FadeScene : NSObject, Fade {
    
    let halfProgress : GLfloat = 0.5
    let fullProgress : GLfloat = 1
    
    var director : Director!
    var backgroundColor : Color = Color()
    
    var previousScene : Scene = EmptyScene()
    var nextScene : Scene = EmptyScene()
    
    var firstScene : Bool = true
    
    var progress : GLfloat = 0
    var time : TimeInterval = 0
    let duration : TimeInterval = 1
    
    let vertexPointer : UnsafeMutablePointer<GLfloat>
    let colorPointer : UnsafeMutablePointer<GLfloat>
    
    override init() {
        self.vertexPointer = UnsafeMutablePointer<GLfloat>.allocate(capacity: Surfaces.vertexesByQuad * Surfaces.coordinatesByVertice)
        self.colorPointer = UnsafeMutablePointer<GLfloat>.allocate(capacity: Surfaces.vertexesByQuad * Surfaces.colorComposants)
        
        Surfaces.setQuad(buffer: self.vertexPointer, index: 0, width: View.instance.width, height: View.instance.height * 3, left: 0, top: 0)
    }
    
    deinit {
        self.vertexPointer.deallocate()
        self.colorPointer.deallocate()
    }
    
    func load() {
        self.time = 0
        self.firstScene = true
        self.backgroundColor = previousScene.backgroundColor
    }
    
    func update(timeSinceLastUpdate: TimeInterval) {
        self.time += timeSinceLastUpdate
        self.progress = min(GLfloat(time / duration), fullProgress)
        
        if !firstScene && progress >= fullProgress {
            director.nextScene = nextScene
            
        } else if firstScene && progress >= halfProgress {
            firstScene = false
            // TODO: Charger ici la seconde scène ?
            nextScene.willAppear?()
            nextScene.update(timeSinceLastUpdate: 0)
            self.backgroundColor = nextScene.backgroundColor
        }
    }
    
    func draw() {
        let darkness : GLfloat
        if firstScene {
            darkness = min(progress, halfProgress) * 2
            previousScene.draw()
        } else {
            darkness = max(1 - (progress - halfProgress) * 2, 0)
            nextScene.draw()
        }
        
        Surfaces.setBlackColor(buffer: self.colorPointer, index: 0, to: Surfaces.vertexesByQuad * Surfaces.colorComposants, alpha: darkness)
        
        Draws.drawWithVertexPointer(self.vertexPointer, colorPointer: self.colorPointer, count: GLsizei(Surfaces.vertexesByQuad))
    }
    
}
