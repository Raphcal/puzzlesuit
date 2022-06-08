//
//  Grid.swift
//  MeltedIce
//
//  Created by Raphaël Calabro on 27/06/2015.
//  Copyright (c) 2015 Raphaël Calabro. All rights reserved.
//

import GLKit

class Grid : NSObject {
    
    let palette : Palette
    let map : Map
    var vertexPointers = [SurfaceArray]()
    var texCoordPointers = [SurfaceArray]()
    
    override init() {
        self.palette = Palette()
        self.map = Map()
        
        super.init()
    }
    
    init(palette: Palette, map: Map) {
        self.palette = palette
        self.map = map
        super.init()
        
        createVerticesAndTextureCoordinates()
    }
    
    // MARK: Affichage.
    
    func draw() {
        drawFrom(from: 0, to: map.layers.count)
    }
    
    func drawFrom(from: Int, to: Int) {
        Draws.bindTexture(palette.texture)
        
        for index in from..<to {
            let layer = map.layers[index]
            let camera = Camera.instance.topLeft
            
            Draws.translateForPoint(camera, scrollRate: layer.scrollRate)
            Draws.drawWithVertexPointer(vertexPointers[index].memory, texCoordPointer: texCoordPointers[index].memory, count: vertexPointers[index].count)
            Draws.cancelTranslationForPoint(camera, scrollRate: layer.scrollRate)
        }
    }
    
    private func createVerticesAndTextureCoordinates() {
        for layer in map.layers {
            let length = layer.length * Surfaces.vertexesByQuad
            let vertexPointer = SurfaceArray(capacity: length, coordinates: Surfaces.coordinatesByVertice)
            let texCoordPointer = SurfaceArray(capacity: length, coordinates: Surfaces.coordinatesByTexture)
            
            for y in 0..<layer.height {
                for x in 0..<layer.width {
                    if let tile = layer.tileAtX(x: x, y: y) {
                        vertexPointer.appendQuad(x + layer.topLeft.x, y: y + layer.topLeft.y)
                        texCoordPointer.appendTile(tile, from: palette)
                    }
                }
            }
            
            vertexPointers.append(vertexPointer)
            texCoordPointers.append(texCoordPointer)
        }
    }
   
}

// MARK: -

class Backdrop {
    
    /// Nombre de cases horizontalement.
    static let width = 13
    /// Nombre de cases verticalement.
    static let height = 8
    /// Taille maximum d'une couche.
    static let maximumLength = width * height
    
    let palette : Palette
    let map : Map
    var vertexPointers = [SurfaceArray]()
    var texCoordPointers = [SurfaceArray]()
    
    init(palette: Palette, map: Map) {
        self.palette = palette
        self.map = map
        
        createVerticesAndTextureCoordinates()
    }
    
    func update(offset: GLfloat = 0) {
        for index in 0..<map.layers.count {
            let layer = map.layers[index]
            let vertexPointer = vertexPointers[index]
            let texCoordPointer = texCoordPointers[index]
            
            let cameraLeft = (Camera.instance.left + offset) * layer.scrollRate.x
            let cameraTop = Camera.instance.top * layer.scrollRate.y
            
            let left = Int(cameraLeft / Surfaces.tileSize)
            let top = Int(cameraTop / Surfaces.tileSize)
            
            vertexPointer.reset()
            texCoordPointer.reset()
            
            for y in top..<top + Backdrop.height {
                for x in left..<left + Backdrop.width {
                    if let tile = layer.tileAtX(x: x % layer.width, y: y % layer.height) {
                        vertexPointer.appendQuad(Surfaces.tileSize, height: Surfaces.tileSize, left: GLfloat(x) * Surfaces.tileSize - cameraLeft, top: GLfloat(y) * Surfaces.tileSize - cameraTop, distance: 0)
                        texCoordPointer.appendTile(tile, from: palette)
                    }
                }
            }
        }
    }
    
    func draw() {
        Draws.bindTexture(palette.texture)
        
        for index in 0..<map.layers.count {
            let vertexPointer = vertexPointers[index]
            let texCoordPointer = texCoordPointers[index]
            
            Draws.drawWithVertexPointer(vertexPointer.memory, texCoordPointer: texCoordPointer.memory, count: vertexPointer.count)
        }
    }
    
    private func createVerticesAndTextureCoordinates() {
        for _ in 0..<map.layers.count {
            let vertexPointer = SurfaceArray(capacity: Backdrop.maximumLength * Surfaces.vertexesByQuad, coordinates: Surfaces.coordinatesByVertice)
            let texCoordPointer = SurfaceArray(capacity: Backdrop.maximumLength * Surfaces.vertexesByQuad, coordinates: Surfaces.coordinatesByTexture)
            
            vertexPointers.append(vertexPointer)
            texCoordPointers.append(texCoordPointer)
        }
    }
    
}
