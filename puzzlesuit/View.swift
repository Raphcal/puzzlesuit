//
//  View.swift
//  MeltedIce
//
//  Created by Raphaël Calabro on 05/01/2016.
//  Copyright © 2016 Raphaël Calabro. All rights reserved.
//

import GLKit

class View : NSObject {
    
    @objc static let instance = View()
    
    var width : GLfloat
    var height : GLfloat
    
    var zoomedWidth : GLfloat {
        get {
            return width * zoom
        }
    }
    
    var zoomedHeight : GLfloat {
        get {
            return height * zoom
        }
    }
    
    /// Rapport entre la taille de l'écran et la vue.
    var ratio : GLfloat
    
    /// Zoom général de la vue.
    var zoom : GLfloat = 1
    
    override init() {
        let screenWidth: GLfloat = 640
        let screenHeight: GLfloat = 480
        
        self.width = 320
        self.ratio = width / screenWidth
        self.height = screenHeight * ratio
    }
    
    @objc func applyZoom() {
        glLoadIdentity()
        #if os(iOS)
            glOrthof(0, zoomedWidth, 0, zoomedHeight, -1, 1)
        #else
            glOrtho(0, GLdouble(zoomedWidth), 0, GLdouble(zoomedHeight), -1, 1)
        #endif
    }
    
    @objc func updateViewWith(bounds: CGRect) {
        #if VIEW_UPDATE_WITH_ZOOM
            let zoom = max(
                Float(bounds.width) / (12 * 32),
                Float(bounds.height) / (6.8 * 32))
            
            self.width = GLfloat(bounds.width) / zoom
            self.height = GLfloat(bounds.height) / zoom
            
            let screenWidth = GLfloat(bounds.width)
            self.ratio = width / screenWidth
        #else
            let screenWidth = GLfloat(bounds.width)
            let screenHeight = GLfloat(bounds.height)
            
            self.ratio = width / screenWidth
            self.height = screenHeight * ratio
        #endif
    }
    
}
