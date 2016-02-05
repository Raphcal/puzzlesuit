//
//  Surfaces.swift
//  MeltedIce
//
//  Created by Raphaël Calabro on 28/06/2015.
//  Copyright (c) 2015 Raphaël Calabro. All rights reserved.
//

import GLKit

/// Méthodes de gestion des surfaces OpenGL.
class Surfaces : NSObject {
    
    // 384 x 224
    
    static let vertexesByQuad = 6
    static let coordinatesByVertice = 3
    static let coordinatesByTexture = 2
    static let tileSize : Float = 16
    
    static let colorComposants = 4
    
    static func setQuad(buffer: UnsafeMutablePointer<GLfloat>, sprite: Sprite) {
        setQuad(buffer, index: sprite.reference, width: sprite.width, height: sprite.height, left: sprite.left, top: sprite.top)
    }
    
    static func setQuad(buffer : UnsafeMutablePointer<GLfloat>, index : Int, width : GLfloat, height : GLfloat, left : GLfloat, top : GLfloat, distance : GLfloat = 0) {
        var entry = index * coordinatesByVertice * vertexesByQuad
        
        let invertedTop = -top
        
        // bas gauche
        buffer[entry++] = left
        buffer[entry++] = invertedTop - height
        buffer[entry++] = distance
        
        // (idem)
        buffer[entry++] = left
        buffer[entry++] = invertedTop - height
        buffer[entry++] = distance
        
        // bas droite
        buffer[entry++] = left + width
        buffer[entry++] = invertedTop - height
        buffer[entry++] = distance
        
        // haut gauche
        buffer[entry++] = left
        buffer[entry++] = invertedTop
        buffer[entry++] = distance
        
        // haut droite
        buffer[entry++] = left + width
        buffer[entry++] = invertedTop
        buffer[entry++] = distance
        
        // (idem)
        buffer[entry++] = left + width
        buffer[entry++] = invertedTop
        buffer[entry] = distance
    }
    
    static func setQuadWithRotation(rotation: GLfloat, buffer: UnsafeMutablePointer<GLfloat>, sprite: Sprite) {
        setQuadWithRotation(sprite.rotate(rotation), buffer: buffer, sprite: sprite)
    }
    
    static func setQuadWithRotation(rotation: GLfloat, pivot: Spot, buffer: UnsafeMutablePointer<GLfloat>, sprite: Sprite) {
        setQuadWithRotation(sprite.rotate(rotation, withPivot: pivot), buffer: buffer, sprite: sprite)
    }
    
    private static func setQuadWithRotation(rotatedSquare: Quadrilateral, buffer: UnsafeMutablePointer<GLfloat>, sprite: Sprite) {
        var entry = sprite.reference * coordinatesByVertice * vertexesByQuad
        let distance : GLfloat = 0
        
        // bas gauche
        buffer[entry++] = rotatedSquare.bottomLeft.x
        buffer[entry++] = -rotatedSquare.bottomLeft.y
        buffer[entry++] = distance
        
        // (idem)
        buffer[entry++] = rotatedSquare.bottomLeft.x
        buffer[entry++] = -rotatedSquare.bottomLeft.y
        buffer[entry++] = distance
        
        // bas droite
        buffer[entry++] = rotatedSquare.bottomRight.x
        buffer[entry++] = -rotatedSquare.bottomRight.y
        buffer[entry++] = distance
        
        // haut gauche
        buffer[entry++] = rotatedSquare.topLeft.x
        buffer[entry++] = -rotatedSquare.topLeft.y
        buffer[entry++] = distance
        
        // haut droite
        buffer[entry++] = rotatedSquare.topRight.x
        buffer[entry++] = -rotatedSquare.topRight.y
        buffer[entry++] = distance
        
        // (idem)
        buffer[entry++] = rotatedSquare.topRight.x
        buffer[entry++] = -rotatedSquare.topRight.y
        buffer[entry] = distance
    }
    
    static func setTile(buffer : UnsafeMutablePointer<GLfloat>, index : Int, width : GLfloat, height : GLfloat, x : GLfloat, y : GLfloat, mirror : Bool) {
        if !mirror {
            setTile(buffer, index: index, width: width, height: height, left: x, top: y)
        } else {
            setTile(buffer, index: index, width: -width, height: height, left: x + width, top: y)
        }
    }
    
    static func setTile(buffer : UnsafeMutablePointer<GLfloat>, index : Int, width : GLfloat, height : GLfloat, left : GLfloat, top : GLfloat) {
        var entry = index * coordinatesByTexture * vertexesByQuad
        
        // Bas gauche
        buffer[entry++] = left
        buffer[entry++] = top + height
        
        // (idem)
        buffer[entry++] = left
        buffer[entry++] = top + height
        
        // Bas droite
        buffer[entry++] = width + left
        buffer[entry++] = top + height
        
        // Haut gauche
        buffer[entry++] = left
        buffer[entry++] = top
        
        // Haut droite
        buffer[entry++] = width + left
        buffer[entry++] = top
        
        // (idem)
        buffer[entry++] = width + left
        buffer[entry] = top
    }
    
    static func setBlackColor(buffer: UnsafeMutablePointer<GLfloat>, index: Int, to: Int, alpha: GLfloat) {
        var entry = index
        
        while entry < to {
            buffer[entry++] = 0
            buffer[entry++] = 0
            buffer[entry++] = 0
            buffer[entry++] = alpha
        }
    }
}
