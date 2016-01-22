//
//  Pool.swift
//  MeltedIce
//
//  Created by Raphaël Calabro on 19/01/2016.
//  Copyright © 2016 Raphaël Calabro. All rights reserved.
//

import Foundation

class ReferencePool {
    
    private var available : [Int]
    
    init() {
        self.available = []
    }
    
    init(capacity: Int) {
        var available = [Int]()
        for var reference = capacity - 1; reference >= 0; reference-- {
            available.append(reference)
        }
        self.available = available
    }
    
    init(from: Int, to: Int) {
        let count = abs(to - from)
        let step = (to - from) / count
        
        var available = [Int]()
        var reference = to
        for _ in 0..<count {
            available.append(reference)
            reference -= step
        }
        
        self.available = available
    }
    
    func nextReference() -> Int {
        return available.removeLast()
    }
    
    func nextReferenceAfter(other: Int) -> Int {
        for var index = available.count - 1; index >= 0; index-- {
            let reference = available[index]
            
            if reference > other {
                available.removeAtIndex(index)
                return reference
            }
        }
        return nextReference()
    }
    
    func next(other: Int?) -> Int {
        if let reference = other {
            return nextReferenceAfter(reference)
        } else {
            return nextReference()
        }
    }
    
    func releaseReference(reference: Int) {
        available.append(reference)
    }
    
}