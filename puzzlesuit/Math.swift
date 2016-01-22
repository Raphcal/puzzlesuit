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
		return pow(sin(GLfloat(M_PI / 2) * min(max(value - from, 0) / to, 1)), 2)
	}
    
    static func smoothStep(from: NSTimeInterval, to: NSTimeInterval, value: NSTimeInterval) -> NSTimeInterval {
        return pow(sin(NSTimeInterval(M_PI / 2) * min(max(value - from, 0) / to, 1)), 2)
    }
	
	static func toRadian(degree: GLfloat) -> GLfloat {
		return degree * GLfloat(M_PI / 180)
	}
	
	static func toDegree(radian: GLfloat) -> GLfloat {
		return radian * GLfloat(180 / M_PI)
	}
    
    static func differenceBetweenAngle(angle: GLfloat, andAngle other: GLfloat) -> GLfloat {
        let difference = other - angle
        let π = GLfloat(M_PI)
        
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
