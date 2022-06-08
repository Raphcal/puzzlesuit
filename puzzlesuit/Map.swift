//
//  Layer.swift
//  MeltedIce
//
//  Created by Raphaël Calabro on 26/06/2015.
//  Copyright (c) 2015 Raphaël Calabro. All rights reserved.
//

import GLKit

class Map : NSObject {
    
    static let fileExtension = "map"
    
    let width : Int
    let height : Int
    let backgroundColor : Color
    let layers : [Layer]
    
    override init() {
        self.width = 0
        self.height = 0
        self.backgroundColor = Color()
        self.layers = []
    }
    
    init(layer: Layer) {
        self.width = layer.width
        self.height = layer.height
        self.backgroundColor = Color()
        self.layers = [layer]
    }
    
    init(layers: [Layer], backgroundColor: Color) {
        self.layers = layers
        self.backgroundColor = backgroundColor
        
        var maxWidth = 0
        var maxHeight = 0
        
        for layer in layers {
            if layer.width > maxWidth {
                maxWidth = layer.width
            }
            if layer.height > maxHeight {
                maxHeight = layer.height
            }
        }
        
        self.width = maxWidth
        self.height = maxHeight
    }
    
    init(inputStream : InputStream) {
        self.backgroundColor = Streams.readColor(inputStream)
        
        let count = Streams.readInt(inputStream)
        var layers : [Layer] = []
        
        var maxWidth = 0
        var maxHeight = 0
        
        for _ in 0..<count {
            let layer = Layer(inputStream: inputStream)
            
            if layer.width > maxWidth {
                maxWidth = layer.width
            }
            if layer.height > maxHeight {
                maxHeight = layer.height
            }
            
            layers.append(layer)
        }
        
        self.layers = layers
        self.width = maxWidth
        self.height = maxHeight
    }
    
    convenience init?(resource : String) {
        if let url = Bundle.main.url(forResource: resource, withExtension: Map.fileExtension), let inputStream = InputStream(url: url) {
            inputStream.open()
            self.init(inputStream: inputStream)
            inputStream.close()
            
        } else {
            self.init()
            return nil
        }
    }
    
    func layerIndex(name: String) -> Int? {
        for index in 0..<layers.count {
            if layers[index].name == name {
                return index;
            }
        }
        return nil;
    }
    
    func mapFromVisibleRect() -> Map {
        var layers = [Layer]()
        
        for layer in self.layers {
            let left = Int(floor(Camera.instance.left * layer.scrollRate.x / Surfaces.tileSize))
            let right = Int(ceil(Camera.instance.right * layer.scrollRate.x / Surfaces.tileSize))
            let top = Int(floor(Camera.instance.top * layer.scrollRate.y / Surfaces.tileSize))
            let bottom = Int(ceil(Camera.instance.bottom * layer.scrollRate.y / Surfaces.tileSize))
            
            var tiles = [Int?]()
            var count = 0
            
            for y in top..<bottom {
                for x in left..<right {
                    let tile = layer.tileAtX(x: x, y: y)
                    tiles.append(tile)
                    
                    if tile != nil {
                        count += 1
                    }
                }
            }
            
            layers.append(Layer(name: layer.name, width: right - left, height: bottom - top, tiles: tiles, length: count, scrollRate: layer.scrollRate, topLeft: (x: left, y: top)))
        }
        
        return Map(layers: layers, backgroundColor: self.backgroundColor)
    }
}

class Layer {
    
    let name : String
    let width : Int
    let height : Int
    let tiles : [Int?]
    let scrollRate : Spot
    let length : Int
    let topLeft : (x: Int, y: Int)
    
    init() {
        self.name = ""
        self.width = 0
        self.height = 0
        self.tiles = []
        self.scrollRate = Spot()
        self.length = 0
        self.topLeft = (x: 0, y: 0)
    }
    
    init(name: String, width: Int, height: Int, tiles: [Int?], length: Int, scrollRate: Spot, topLeft: (x: Int, y: Int)) {
        self.name = name
        self.width = width
        self.height = height
        self.tiles = tiles
        self.length = length
        self.scrollRate = scrollRate
        self.topLeft = topLeft
    }
    
    init(name : String, width : Int, height : Int, tiles : [Int?], scrollRateX : Float, scrollRateY : Float) {
        self.name = name
        self.width = width
        self.height = height
        self.tiles = tiles
        self.scrollRate = Spot(x: scrollRateX, y: scrollRateY)
        
        var length = 0
        for tile in tiles {
            if let tile = tile, tile > -1 {
                length += 1
            }
        }
        self.length = length
        self.topLeft = (x: 0, y: 0)
    }
    
    init(inputStream : InputStream) {
        self.name = Streams.readString(inputStream)
        self.width = Streams.readInt(inputStream)
        self.height = Streams.readInt(inputStream)
        
        let scrollRateX = Streams.readFloat(inputStream)
        let scrollRateY = Streams.readFloat(inputStream)
        self.scrollRate = Spot(x: scrollRateX, y: scrollRateY)
        
        let count = Streams.readInt(inputStream)
        var tiles : [Int?] = []
        var length = 0
        
        for _ in 0..<count {
            let tile = Streams.readInt(inputStream)
            
            if tile > -1 {
                tiles.append(tile)
                length += 1
            } else {
                tiles.append(nil)
            }
        }
        
        self.tiles = tiles
        self.length = length
        self.topLeft = (x: 0, y: 0)
    }
    
    func tileAtX(x : Int, y: Int) -> Int? {
        if x >= 0 && x < width && y >= 0 && y < height {
            return tiles[y * width + x]
        } else {
            return nil
        }
    }
    
    func tileAtPoint(point: Spot) -> Int? {
        return tileAtX(x: Int(point.x / Surfaces.tileSize), y: Int(point.y / Surfaces.tileSize))
    }
    
    func pointInTileAtPoint(point: Spot) -> Spot {
        return Spot(x: modulo(value: point.x, divisor: Surfaces.tileSize), y: modulo(value: point.y, divisor: Surfaces.tileSize))
    }
    
    private func modulo(value: GLfloat, divisor: GLfloat) -> GLfloat {
        let division = value / divisor
        return (division - floor(division)) * divisor
    }
    
    func tileTop(point: Spot) -> GLfloat {
        return GLfloat(Int(point.y / Surfaces.tileSize)) * Surfaces.tileSize
    }
    
    func tileBottom(point: Spot) -> GLfloat {
        return GLfloat(Int(point.y / Surfaces.tileSize) + 1) * Surfaces.tileSize
    }

    func tileBorder(point: Spot, direction: Direction) -> GLfloat {
        return GLfloat(Int(point.x / Surfaces.tileSize) + direction.rawValue) * Surfaces.tileSize
    }
    
}
