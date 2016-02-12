//
//  Opponent.swift
//  PuzzleSuit
//
//  Created by Raphaël Calabro on 09/02/2016.
//  Copyright © 2016 Raphaël Calabro. All rights reserved.
//

import Foundation

enum Opponent {
    
    case First
    case Second
    case Third
    case Fourth
    case Fifth
    case Sixth
    case Seventh
    case Eighth
    case Nineth
    case Tenth
    
    var controller : Controller {
        get {
            switch self {
            case .First:
                return InstantCpu(sameSuitScore: 1, rowScore: 1)
            case .Second:
                return InstantCpu(fastWhenGoodHandIsFound: true, preferSides: true, sameSuitScore: 1)
            default:
                return InstantCpu(fast: true, sameSuitScore: 1, rowScore: 1)
            }
        }
    }
    
}
