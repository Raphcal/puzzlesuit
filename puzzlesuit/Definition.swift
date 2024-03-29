//
//  Definition.swift
//  MeltedIce
//
//  Created by Raphaël Calabro on 28/06/2015.
//  Copyright (c) 2015 Raphaël Calabro. All rights reserved.
//

import Foundation

class SpriteDefinition : Equatable {
    
    static let fileExtension = "sprites"
    
    let index : Int
    let name : String?
    let width : Int
    let height : Int
    let type : SpriteType
    let animations : [AnimationDefinition]
    let motionScriptFile : String?
    let distance : Distance
    
    init() {
        self.index = -1
        self.name = ""
        self.width = 0
        self.height = 0
        self.type = .Decoration
        self.animations = []
        self.motionScriptFile = nil
        self.distance = .Behind
    }
    
    init(type: SpriteType, width: Int, height: Int, animations: [AnimationDefinition]) {
        self.index = -1
        self.name = ""
        self.width = width
        self.height = height
        self.type = type
        self.animations = animations
        self.motionScriptFile = nil
        self.distance = .Behind
    }
    
    init(inputStream : InputStream, index: Int) {
        self.index = index
        self.name = Streams.readNullableString(inputStream)
        self.width = Streams.readInt(inputStream)
        self.height = Streams.readInt(inputStream)
        
        if let type = SpriteType(rawValue: Streams.readInt(inputStream)) {
            self.type = type
        } else {
            self.type = .Decoration
        }
        
        if let distance = Distance(rawValue: Streams.readInt(inputStream)) {
            self.distance = distance
        } else {
            self.distance = .Behind
        }
        
        self.motionScriptFile = Streams.readNullableString(inputStream)
        
        // Animations
        let animationCount = Streams.readInt(inputStream)
        var animations : [AnimationDefinition] = []
        
        for _ in 0..<animationCount {
            animations.append(AnimationDefinition(inputStream: inputStream))
        }
        
        self.animations = animations
    }
    
    class func definitionsFromInputStream(inputStream : InputStream) -> [SpriteDefinition] {
        var definitions : [SpriteDefinition] = []
        
        let definitionCount = Streams.readInt(inputStream)
        for index in 0..<definitionCount {
            definitions.append(SpriteDefinition(inputStream: inputStream, index: index))
        }
        
        return definitions
    }
    
    class func definitionsFromResource(resource: String) -> [SpriteDefinition]? {
        if let url = Bundle.main.url(forResource: resource, withExtension: fileExtension), let inputStream = InputStream(url: url) {
            inputStream.open()
            let definitions = definitionsFromInputStream(inputStream: inputStream)
            inputStream.close()
            
            return definitions
            
        } else {
            return nil
        }
    }
    
}

func == (lhs: SpriteDefinition, rhs: SpriteDefinition) -> Bool {
    return lhs.index == rhs.index
}

class AnimationDefinition {
    
    let name : String
    let frames : [Frame]
    let frequency : Int
    let looping : Bool
    
    init() {
        self.name = ""
        self.frames = []
        self.frequency = 1
        self.looping = false
    }
    
    init(frames: [Frame]) {
        self.name = ""
        self.frames = frames
        self.frequency = 1
        self.looping = false
    }
    
    init(inputStream : InputStream) {
        self.name = Streams.readString(inputStream)
        self.frequency = Streams.readInt(inputStream)
        self.looping = Streams.readBoolean(inputStream)
        
        // Directions et frames
        let directionCount = Streams.readInt(inputStream)
        
        var mainFrames : [Frame] = []
        
        for _ in 0..<directionCount {
            let key = Streams.readDouble(inputStream)
            
            // Frames
            let frameCount = Streams.readInt(inputStream)
            
            var frames : [Frame] = []
            
            for _ in 0..<frameCount {
                frames.append(Frame(inputStream: inputStream))
            }
            
            if key == 0 || mainFrames.isEmpty {
                mainFrames = frames
            }
        }
        
        self.frames = mainFrames
    }
    
    func toAnimation() -> Animation {
        if looping {
            return LoopingAnimation(definition: self)
            
        } else if frames.count > 1 {
            return PlayOnceAnimation(definition: self)
            
        } else if frames.count == 1 {
            return SingleFrameAnimation(definition: self)
            
        } else {
            return NoAnimation(definition: self)
        }
    }
    
    func toAnimation(onEnd: @escaping () -> Void) -> Animation {
        return PlayOnceAnimation(definition: self, onEnd: onEnd)
    }
}
