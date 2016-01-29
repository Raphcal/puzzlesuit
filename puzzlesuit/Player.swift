//
//  Player.swift
//  puzzlesuit
//
//  Created by Raphaël Calabro on 28/01/2016.
//  Copyright © 2016 Raphaël Calabro. All rights reserved.
//

import Foundation

protocol Player {
    
    func mainCardMotion() -> Motion
    func extraCardMotion() -> Motion
    
}