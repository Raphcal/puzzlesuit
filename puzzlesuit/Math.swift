//
//  Math.swift
//  MeltedIce
//
//  Created by Raphaël Calabro on 06/07/2015.
//  Copyright (c) 2015 Raphaël Calabro. All rights reserved.
//

import GLKit

class Math {

	static func smoothStep(from: GLfloat, to: GLfloat, value: GLfloat) -> GLfloat {
		return pow(sin(GLfloat.pi / 2 * min(max(value - from, 0) / to, 1)), 2)
	}
    
    static func smoothStep(from: TimeInterval, to: TimeInterval, value: TimeInterval) -> TimeInterval {
        return pow(sin((TimeInterval.pi / 2) * min(max(value - from, 0) / to, 1)), 2)
    }
	
	static func toRadian(degree: GLfloat) -> GLfloat {
        return degree * GLfloat.pi / 180
	}
	
	static func toDegree(radian: GLfloat) -> GLfloat {
        return radian * 180 / .pi
	}
    
    static func differenceBetweenAngle(angle: GLfloat, andAngle other: GLfloat) -> GLfloat {
        let difference = other - angle
        let π = GLfloat.pi
        
        if difference < -π {
            return difference + π * 2
        } else if difference > π {
            return difference - π * 2
        } else {
            return difference
        }
    }
    
    static func mod(value: Int, by modulo: Int) -> Int {
        return ((value % modulo) + modulo) % modulo
    }
	
}
