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
        for reference in stride(from: capacity - 1, through: 0, by: -1) {
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
        for index in stride(from: available.count - 1, through: 0, by: -1) {
            let reference = available[index]

            if reference > other {
                available.remove(at: index)
                return reference
            }
        }
        return nextReference()
    }
    
    func next(other: Int?) -> Int {
        if let reference = other {
            return nextReferenceAfter(other: reference)
        } else {
            return nextReference()
        }
    }
    
    func releaseReference(reference: Int) {
        available.append(reference)
    }
    
}
