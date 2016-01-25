//
//  Spot.swift
//  MeltedIce
//
//  Created by Raphaël Calabro on 28/06/2015.
//  Copyright (c) 2015 Raphaël Calabro. All rights reserved.
//

import GLKit

class Spot : NSObject {
    
    var x : GLfloat
    var y : GLfloat
    
    override init() {
        self.x = 0
        self.y = 0
    }
    
    init(x: GLfloat, y: GLfloat) {
        self.x = x
        self.y = y
    }
    
    init(point: Spot) {
        self.x = point.x
        self.y = point.y
    }
    
    init(bottomOfSquare square: Square) {
        self.x = square.x
        self.y = square.bottom
    }
    
    class func spotAtX(x: GLfloat, y: GLfloat) -> Spot {
        return Spot(x: x, y: y)
    }
    
}

protocol Shape {
    
    var x : GLfloat { get }
    var y : GLfloat { get }
    var width : GLfloat { get }
    var height : GLfloat { get }
    var top : GLfloat { get }
    var bottom : GLfloat { get }
    var left : GLfloat { get }
    var right : GLfloat { get }
    
}

class Square : Spot, Shape {
    
    static let empty = Square()
    
    var width : GLfloat
    var height : GLfloat
    
    var center : Spot {
        get {
            return self
        }
        set {
            self.x = newValue.x
            self.y = newValue.y
        }
    }
    
    var topLeft : Spot {
        get {
            return Spot(x: x - width / 2, y: y - height / 2)
        }
        set {
            self.x = newValue.x + width / 2
            self.y = newValue.y + height / 2
        }
    }
    
    var bottomRight : Spot {
        get {
            return Spot(x: x + width / 2, y: y + height / 2)
        }
        set {
            self.x = newValue.x - width / 2
            self.y = newValue.y - height / 2
        }
    }
    
    var size : Spot {
        get {
            return Spot(x: width, y: height)
        }
        set {
            self.width = newValue.x
            self.height = newValue.y
        }
    }
    
    var top : GLfloat {
        get {
            return y - height / 2
        }
    }
    
    var bottom : GLfloat {
        get {
            return y + height / 2
        }
    }
    
    var left : GLfloat {
        get {
            return x - width / 2
        }
    }
    
    var right : GLfloat {
        get {
            return x + width / 2
        }
    }
    
    override init() {
        self.width = 0
        self.height = 0
        
        super.init()
    }
    
    init(square: Square) {
        self.width = square.width
        self.height = square.height
        
        super.init(point: square)
    }
    
    init(centerX: GLfloat, centerY: GLfloat, width: GLfloat, height: GLfloat) {
        self.width = width
        self.height = height
        
        super.init(x: centerX, y: centerY)
    }
    
    init(left: GLfloat, top: GLfloat, width: GLfloat, height: GLfloat) {
        self.width = width
        self.height = height
        
        super.init(x: left + width / 2, y: top + height / 2)
    }
    
    init(top: GLfloat, bottom: GLfloat, left: GLfloat, right: GLfloat) {
        self.width = right - left
        self.height = bottom - top
        
        super.init(x: left + width / 2, y: top + height / 2)
    }
    
    /// Calcule la rotation à appliquer pour l'angle donné.
    static func rotationForAngle(angle: GLfloat, direction: Direction) -> GLfloat {
        var degree = angle * 180 / GLfloat(M_PI)
        if direction == .Left {
            degree -= 180
        }
        while degree < 0 {
            degree += 360
        }
        let step : GLfloat = 22.5
        degree = nearbyint(degree / step) * step
        return degree * GLfloat(M_PI) / 180
    }
    
    func rotate(rotation: GLfloat) -> Quadrilateral {
        let distance = sqrt(width * width + height * height) / 2
        let quarter = GLfloat(M_PI_4)
        return Quadrilateral(
            topLeft: Spot(x: x + cos(-quarter * 3 + rotation) * distance, y: y + sin(-quarter * 3 + rotation) * distance),
            topRight: Spot(x: x + cos(-quarter + rotation) * distance, y: y + sin(-quarter + rotation) * distance),
            bottomLeft: Spot(x: x + cos(quarter * 3 + rotation) * distance, y: y + sin(quarter * 3 + rotation) * distance),
            bottomRight: Spot(x: x + cos(quarter + rotation) * distance, y: y + sin(quarter + rotation) * distance)
        )
    }
    
    func rotate(rotation: GLfloat, withPivot pivot: Spot) -> Quadrilateral {
        var vertices = [Spot]()
        let reference = float2(pivot.x, pivot.y)
        for vertex in [float2(left, top), float2(right, top), float2(left, bottom), float2(right, bottom)] {
            let length = distance(vertex, reference)
            let angle : GLfloat = atan2(vertex.y - reference.y, vertex.x - reference.x)
            vertices.append(Spot(x: pivot.x + cos(angle + rotation) * length, y: pivot.y + sin(angle + rotation) * length))
        }
        return Quadrilateral(vertices: vertices)
    }
    
}

class Quadrilateral {
    
    let topLeft : Spot
    let topRight : Spot
    let bottomLeft : Spot
    let bottomRight : Spot
    
    var left : GLfloat {
        return min(topLeft.x, topRight.x, bottomLeft.x, bottomRight.x)
    }
    
    var right : GLfloat {
        return max(topLeft.x, topRight.x, bottomLeft.x, bottomRight.x)
    }
    
    var top : GLfloat {
        return min(topLeft.y, topRight.y, bottomLeft.y, bottomRight.y)
    }
    
    var bottom : GLfloat {
        return max(topLeft.y, topRight.y, bottomLeft.y, bottomRight.y)
    }
    
    init(vertices: [Spot]) {
        self.topLeft = vertices[0]
        self.topRight = vertices[1]
        self.bottomLeft = vertices[2]
        self.bottomRight = vertices[3]
    }
    
    init(topLeft: Spot, topRight: Spot, bottomLeft: Spot, bottomRight: Spot) {
        self.topLeft = topLeft
        self.topRight = topRight
        self.bottomLeft = bottomLeft
        self.bottomRight = bottomRight
    }
    
    func enclosingSquare() -> Square {
        return Square(left: left, top: top, width: right - left, height: bottom - top)
    }
    
}

