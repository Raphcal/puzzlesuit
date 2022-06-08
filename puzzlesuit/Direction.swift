//
//  Direction.swift
//  MeltedIce
//
//  Created by Raphaël Calabro on 29/06/2015.
//  Copyright (c) 2015 Raphaël Calabro. All rights reserved.
//

import GLKit

enum Direction : Int {
    case Left = 0, Right, Up, Down
    
    static let all = [Direction.Left, .Right, .Up, .Down]
    static let circle = [Direction.Up, .Right, .Down, .Left]
    
    private static let values : [GLfloat] = [-1, 1, -1, 1]
    private static let reverses : [Direction] = [.Right, .Left, .Down, .Up]
    private static let axes : [Axe] = [.Horizontal, .Horizontal, .Vertical, .Vertical]
    private static let angles : [GLfloat] = [GLfloat.pi, 0, GLfloat.pi + .pi / 2, GLfloat.pi / 2]
    private static let locations = [BoardLocation(x: -1, y: 0), BoardLocation(x: 1, y: 0), BoardLocation(x: 0, y: -1), BoardLocation(x: 0, y: 1)]
    
    func value() -> GLfloat {
        return Direction.values[rawValue]
    }
    
    func reverse() -> Direction {
        return Direction.reverses[rawValue]
    }
    
    func isSameValue(value: GLfloat) -> Bool {
        return value * self.value() >= 0
    }
    
    func isMirror() -> Bool {
        return self == .Left
    }
    
    func asAxe() -> Axe {
        return Direction.axes[rawValue]
    }
    
    func angle() -> GLfloat {
        return Direction.angles[rawValue]
    }
    
    func location() -> BoardLocation {
        return Direction.locations[rawValue]
    }
    
    static func directionFromSprite(from: Sprite, toSprite to: Sprite) -> Direction {
        if from.x <= to.x {
            return .Right
        } else {
            return .Left
        }
    }
}

enum Axe {
    case Horizontal, Vertical
    
    static let count = 2
}
