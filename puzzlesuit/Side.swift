//
//  Side.swift
//  puzzlesuit
//
//  Created by Raphaël Calabro on 28/01/2016.
//  Copyright © 2016 Raphaël Calabro. All rights reserved.
//

import GLKit

enum Side {
    
    case Left, Right
    
    func boardLeft(size: Spot) -> GLfloat {
        switch self {
        case .Left:
            return 16
        case .Right:
            return View.instance.width - 16 - size.x
        }
    }
    
    func oppositeSide() -> Side {
        switch self {
        case .Left:
            return .Right
        case .Right:
            return .Left
        }
    }
    
    func event() -> Event {
        switch self {
        case .Left:
            return .LeftSideSentChips
        case .Right:
            return .RightSideSentChips
        }
    }
    
}