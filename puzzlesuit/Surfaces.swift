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
    
    @objc static let vertexesByQuad = 6
    @objc static let coordinatesByVertice = 3
    @objc static let coordinatesByTexture = 2
    @objc static let tileSize : Float = 16
    
    @objc static let colorComposants = 4
    
    @objc static func setQuad(buffer: UnsafeMutablePointer<GLfloat>, sprite: Sprite) {
        setQuad(buffer: buffer, index: sprite.reference, width: sprite.width, height: sprite.height, left: sprite.left, top: sprite.top)
    }
    
    @objc static func setQuad(buffer : UnsafeMutablePointer<GLfloat>, index : Int, width : GLfloat, height : GLfloat, left : GLfloat, top : GLfloat, distance : GLfloat = 0) {
        let entry = index * coordinatesByVertice * vertexesByQuad
        
        let invertedTop = -top
        
        // bas gauche
        buffer[entry + 0] = left
        buffer[entry + 1] = invertedTop - height
        buffer[entry + 2] = distance
        
        // (idem)
        buffer[entry + 3] = left
        buffer[entry + 4] = invertedTop - height
        buffer[entry + 5] = distance
        
        // bas droite
        buffer[entry + 6] = left + width
        buffer[entry + 7] = invertedTop - height
        buffer[entry + 8] = distance
        
        // haut gauche
        buffer[entry + 9] = left
        buffer[entry + 10] = invertedTop
        buffer[entry + 11] = distance
        
        // haut droite
        buffer[entry + 12] = left + width
        buffer[entry + 13] = invertedTop
        buffer[entry + 14] = distance
        
        // (idem)
        buffer[entry + 15] = left + width
        buffer[entry + 16] = invertedTop
        buffer[entry + 17] = distance
    }
    
    @objc static func setQuadWithRotation(rotation: GLfloat, buffer: UnsafeMutablePointer<GLfloat>, sprite: Sprite) {
        setQuadWithRotation(rotatedSquare: sprite.rotate(rotation: rotation), buffer: buffer, sprite: sprite)
    }
    
    @objc static func setQuadWithRotation(rotation: GLfloat, pivot: Spot, buffer: UnsafeMutablePointer<GLfloat>, sprite: Sprite) {
        setQuadWithRotation(rotatedSquare: sprite.rotate(rotation: rotation, withPivot: pivot), buffer: buffer, sprite: sprite)
    }
    
    private static func setQuadWithRotation(rotatedSquare: Quadrilateral, buffer: UnsafeMutablePointer<GLfloat>, sprite: Sprite) {
        let entry = sprite.reference * coordinatesByVertice * vertexesByQuad
        let distance : GLfloat = 0
        
        // bas gauche
        buffer[entry + 0] = rotatedSquare.bottomLeft.x
        buffer[entry + 1] = -rotatedSquare.bottomLeft.y
        buffer[entry + 2] = distance
        
        // (idem)
        buffer[entry + 3] = rotatedSquare.bottomLeft.x
        buffer[entry + 4] = -rotatedSquare.bottomLeft.y
        buffer[entry + 5] = distance
        
        // bas droite
        buffer[entry + 6] = rotatedSquare.bottomRight.x
        buffer[entry + 7] = -rotatedSquare.bottomRight.y
        buffer[entry + 8] = distance
        
        // haut gauche
        buffer[entry + 9] = rotatedSquare.topLeft.x
        buffer[entry + 10] = -rotatedSquare.topLeft.y
        buffer[entry + 11] = distance
        
        // haut droite
        buffer[entry + 12] = rotatedSquare.topRight.x
        buffer[entry + 13] = -rotatedSquare.topRight.y
        buffer[entry + 14] = distance
        
        // (idem)
        buffer[entry + 15] = rotatedSquare.topRight.x
        buffer[entry + 16] = -rotatedSquare.topRight.y
        buffer[entry + 17] = distance
    }
    
    @objc static func setTile(buffer : UnsafeMutablePointer<GLfloat>, index : Int, width : GLfloat, height : GLfloat, x : GLfloat, y : GLfloat, mirror : Bool) {
        if !mirror {
            setTile(buffer: buffer, index: index, width: width, height: height, left: x, top: y)
        } else {
            setTile(buffer: buffer, index: index, width: -width, height: height, left: x + width, top: y)
        }
    }
    
    @objc static func setTile(buffer : UnsafeMutablePointer<GLfloat>, index : Int, width : GLfloat, height : GLfloat, left : GLfloat, top : GLfloat) {
        let entry = index * coordinatesByTexture * vertexesByQuad
        
        // Bas gauche
        buffer[entry + 0] = left
        buffer[entry + 1] = top + height
        
        // (idem)
        buffer[entry + 2] = left
        buffer[entry + 3] = top + height
        
        // Bas droite
        buffer[entry + 4] = width + left
        buffer[entry + 5] = top + height
        
        // Haut gauche
        buffer[entry + 6] = left
        buffer[entry + 7] = top
        
        // Haut droite
        buffer[entry + 8] = width + left
        buffer[entry + 9] = top
        
        // (idem)
        buffer[entry + 10] = width + left
        buffer[entry + 11] = top
    }
    
    @objc static func setBlackColor(buffer: UnsafeMutablePointer<GLfloat>, index: Int, to: Int, alpha: GLfloat) {
        var entry = index

        while entry < to {
            buffer[entry + 0] = 0
            buffer[entry + 1] = 0
            buffer[entry + 2] = 0
            buffer[entry + 3] = alpha
            entry += 4
        }
    }
}
