//
//  Streams.swift
//  MeltedIce
//
//  Created by Raphaël Calabro on 26/06/2015.
//  Copyright (c) 2015 Raphaël Calabro. All rights reserved.
//

import GLKit

class Streams {

    static let byteSize = 1
    static let characterSize = 2
    static let integerSize = 4
    static let longSize = 8

    static let bitsInAByte : Int = 8
    static let maximumValueOfAByte : UInt8 = 0xFF
    
    class func inputStreams(resources: [(name: String, ext: String)]) -> [(url: NSURL, inputStream: NSInputStream)]? {
        var inputStreams : [(url: NSURL, inputStream: NSInputStream)] = []
        
        for (name, ext) in resources {
            if let url = NSBundle.mainBundle().URLForResource(name, withExtension: ext), let inputStream = NSInputStream(URL: url) {
                inputStreams.append(url: url, inputStream: inputStream)
            } else {
                return nil
            }
        }
        
        return inputStreams
    }
    
    class func readByte(inputStream: NSInputStream) -> UInt8 {
        let buffer = UnsafeMutablePointer<UInt8>.alloc(byteSize)
        let read = inputStream.read(buffer, maxLength: byteSize)
        
        var result : UInt8 = 0
        
        if read == byteSize {
            result = buffer[0]
        }
        
        buffer.destroy()
        
        return result
    }
    
    class func readBoolean(inputStream : NSInputStream) -> Bool {
        return readByte(inputStream) == 1
    }
    
    class func readInt(inputStream : NSInputStream) -> Int {
        let buffer = UnsafeMutablePointer<UInt8>.alloc(integerSize)
        let read = inputStream.read(buffer, maxLength: integerSize)
        
        var result = 0
        
        if read == integerSize {
            let int32Buffer = UnsafeMutablePointer<Int32>(buffer)
            result = Int(int32Buffer[0])
        }
        
        buffer.destroy()
        
        return result
    }
    
    class func readFloat(inputStream : NSInputStream) -> Float {
        let buffer = UnsafeMutablePointer<UInt8>.alloc(integerSize)
        let read = inputStream.read(buffer, maxLength: integerSize)
        
        var result : Float = 0
        
        if read == integerSize {
            let floatBuffer = UnsafeMutablePointer<Float32>(buffer)
            result = floatBuffer[0]
        }
        
        buffer.destroy()
        
        return result
    }
    
    class func readDouble(inputStream : NSInputStream) -> Double {
        let buffer = UnsafeMutablePointer<UInt8>.alloc(longSize)
        let read = inputStream.read(buffer, maxLength: longSize)
        
        var result : Double = 0
        
        if read == longSize {
            let doubleBuffer = UnsafeMutablePointer<Float64>(buffer)
            result = doubleBuffer[0]
        }
        
        buffer.destroy()
        
        return result
    }
    
    class func readByteArray(inputStream : NSInputStream) -> [UInt8] {
        let count = readInt(inputStream)
        var result = [UInt8]()
        result.reserveCapacity(count)
        
        for _ in 0..<count {
            result.append(readByte(inputStream))
        }
        
        return result
    }
    
    class func readNullableByteArray(inputStream : NSInputStream) -> [UInt8]? {
        if readBoolean(inputStream) {
            return readByteArray(inputStream)
        } else {
            return nil
        }
    }
    
    class func readIntArray(inputStream : NSInputStream) -> [Int] {
        let count = readInt(inputStream)
        var result = [Int]()
        result.reserveCapacity(count)
        
        for _ in 0..<count {
            result.append(readInt(inputStream))
        }
        
        return result
    }
    
    class func readString(inputStream : NSInputStream) -> String {
        let length = readInt(inputStream) * characterSize
        
        if length == 0 {
            return ""
        }
        
        let buffer = UnsafeMutablePointer<UInt8>.alloc(length)
        let read = inputStream.read(buffer, maxLength: length)
        
        let string : String
        
        if read == length {
            string = NSString(bytes: buffer, length: length, encoding: NSUTF16LittleEndianStringEncoding) as! String
        } else {
            string = ""
        }
        
        buffer.destroy()
        
        return string
    }
    
    class func readNullableString(inputStream : NSInputStream) -> String? {
        if readBoolean(inputStream) {
            return readString(inputStream)
        } else {
            return nil
        }
    }
    
    class func readColor(inputStream : NSInputStream) -> Color {
        let red = readInt(inputStream)
        let green = readInt(inputStream)
        let blue = readInt(inputStream)
        let alpha = readInt(inputStream)
        
        return Color(intRed: red, intGreen: green, intBlue: blue, intAlpha: alpha)
    }
    
    class func readFloatFromByteArray(bytes: [UInt8], atIndex start: Int) -> (float: Float, readCount: Int) {
        var index = start
        
        let pointer = UnsafeMutablePointer<UInt8>.alloc(4)
        pointer[0] = bytes[index++]
        pointer[1] = bytes[index++]
        pointer[2] = bytes[index++]
        pointer[3] = bytes[index++]
        
        let floatPointer = UnsafeMutablePointer<Float32>(pointer)
        let float = Float(floatPointer[0])
        pointer.destroy()
        
        return (float: float, readCount: index - start)
    }
    
    class func readStringFromByteArray(bytes: [UInt8], atIndex start: Int) -> (string: String, readCount: Int) {
        var index = start
        
        let pointer = UnsafeMutablePointer<UInt8>.alloc(4)
        pointer[0] = bytes[index++]
        pointer[1] = bytes[index++]
        pointer[2] = bytes[index++]
        pointer[3] = bytes[index++]
        
        let intPointer = UnsafeMutablePointer<Int32>(pointer)
        let length = Int(intPointer[0]) * Streams.characterSize
        pointer.destroy()
        
        let string : String
        
        if length > 0 {
            let buffer = UnsafeMutablePointer<UInt8>.alloc(length)
            for i in 0..<length {
                buffer[i] = bytes[index++]
            }
            
            string = NSString(bytes: buffer, length: length, encoding: NSUTF16LittleEndianStringEncoding) as! String
            buffer.destroy()
            
        } else {
            string = ""
        }
        
        return (string: string, readCount: index - start)
    }

}