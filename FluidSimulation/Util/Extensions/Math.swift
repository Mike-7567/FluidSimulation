//
//  Math.swift
//  FluidSimulation
//
//  Created by Gabriel Thomson on 2/20/25.
//
import CoreGraphics
import Foundation
import Metal

extension CGColor {
    static let red: CGColor = CGColor(red: 1, green: 0, blue: 0, alpha: 1)
    static let green: CGColor = CGColor(red: 0, green: 1, blue: 0, alpha: 1)
    static let blue: CGColor = CGColor(red: 0, green: 0, blue: 1, alpha: 1)
    
    func redComponent() -> Float {
        guard let red = self.components?[0] else {
            logger.log("Could not get red component")
            return 0
        }
        
        return Float(red)
    }
    
    func greenComponent() -> Float {
        guard let green = self.components?[1] else {
            logger.log("Could not get green component")
            return 0
        }
        
        return Float(green)
    }

    func blueComponent() -> Float {
        guard let blue = self.components?[2] else {
            logger.log("Could not get blue component")
            return 0
        }
        
        return Float(blue)
    }
    
    func toSimdColor() -> simd_float4 {
        if self.components?.count == 4 {
            return simd_float4(self.redComponent(), self.greenComponent(), self.blueComponent(), Float(self.alpha))
        } else {
            logger.log("Could not convert CGColor to simd_float4")
            return simd_float4(1, 0, 1, 1)
        }
    }
}

extension Float {
    func toRadians() -> Float {
        return self * .pi / 180.0
    }
    
    func round(to: Int) -> Float {
        let power = Float(pow(1.0, Float(to)))
        return (self * power).rounded() / power
    }
}

extension simd_float2 {
    func length() -> Float {
        return sqrt(x * x + y * y)
    }
    
    var isNaN: Bool {
        return x.isNaN || y.isNaN
    }
}

extension simd_float3 {
    static let xAxis = simd_float3(1, 0, 0)
    static let yAxis = simd_float3(0, 1, 0)
    static let zAxis = simd_float3(0, 0, 1)
    
    func length() -> Float {
        return sqrt(x * x + y * y + z * z)
    }
}

extension simd_float4 {
    static let white = simd_float4(1, 1, 1, 1)
    static let black = simd_float4(0, 0, 0, 1)
    static let red = simd_float4(1, 0, 0, 1)
    static let green = simd_float4(0, 1, 0, 1)
    static let blue = simd_float4(0, 0, 1, 1)
    
    func toCGColor() -> CGColor {
        return CGColor(red: CGFloat(x), green: CGFloat(y), blue: CGFloat(z), alpha: CGFloat(w))
    }
}

extension simd_float4x4 {
    static let identity = simd_float4x4(simd_float4(1, 0, 0, 0), simd_float4(0, 1, 0, 0), simd_float4(0, 0, 1, 0), simd_float4(0, 0, 0, 1))
    
    //translate, rotate, and scale from
    //https://github.com/twohyjr/Metal-Game-Engine-Tutorial/blob/Episode9.0_MovingTheGameObjectAround/Episode9.0_Moving%20The%20Game%20Object%20Around/Game%20Engine/Maths/Math.swift
    mutating func translate(direction: simd_float3) {
        var result = matrix_identity_float4x4
            
        let x: Float = direction.x
        let y: Float = direction.y
        let z: Float = direction.z
            
        result.columns = (
            simd_float4(1,0,0,0),
            simd_float4(0,1,0,0),
            simd_float4(0,0,1,0),
            simd_float4(x,y,z,1))
            
        self = matrix_multiply(self, result)
    }
        
    mutating func scale(axis: simd_float3) {
        var result = matrix_identity_float4x4
        
        let x: Float = axis.x
        let y: Float = axis.y
        let z: Float = axis.z
        
        result.columns = (
            simd_float4(x,0,0,0),
            simd_float4(0,y,0,0),
            simd_float4(0,0,z,0),
            simd_float4(0,0,0,1))
        
        self = matrix_multiply(self, result)
    }
    
    mutating func rotate(angle: Float, axis: simd_float3) {
        var result = matrix_identity_float4x4
        
        let x: Float = axis.x
        let y: Float = axis.y
        let z: Float = axis.z
        
        let c: Float = cos(angle)
        let s: Float = sin(angle)
        
        let mc: Float = (1 - c)
        
        let r1c1: Float = x * x * mc + c
        let r2c1: Float = x * y * mc + z * s
        let r3c1: Float = x * z * mc - y * s
        let r4c1: Float = 0.0
        
        let r1c2: Float = y * x * mc - z * s
        let r2c2: Float = y * y * mc + c
        let r3c2: Float = y * z * mc + x * s
        let r4c2: Float = 0.0
        
        let r1c3: Float = z * x * mc + y * s
        let r2c3: Float = z * y * mc - x * s
        let r3c3: Float = z * z * mc + c
        let r4c3: Float = 0.0
        
        let r1c4: Float = 0.0
        let r2c4: Float = 0.0
        let r3c4: Float = 0.0
        let r4c4: Float = 1.0
        
        result.columns = (
            simd_float4(r1c1, r2c1, r3c1, r4c1),
            simd_float4(r1c2, r2c2, r3c2, r4c2),
            simd_float4(r1c3, r2c3, r3c3, r4c3),
            simd_float4(r1c4, r2c4, r3c4, r4c4))
        
        self = matrix_multiply(self, result)
    }
    
    //https://gamedev.stackexchange.com/questions/120338/what-does-a-perspective-projection-matrix-look-like-in-opengl
    static func perspective(degreesFov: Float, aspectRatio: Float, near: Float, far: Float)->matrix_float4x4{
        let fov = degreesFov * .pi / 180
            
        let t: Float = tan(fov / 2)
            
        let x: Float = 1 / (aspectRatio * t)
        let y: Float = 1 / t
        let z: Float = -((far + near) / (far - near))
        let w: Float = -((2 * far * near) / (far - near))
            
        var result = matrix_identity_float4x4
        result.columns = (
            simd_float4(x,  0,  0,   0),
            simd_float4(0,  y,  0,   0),
            simd_float4(0,  0,  z,  -1),
            simd_float4(0,  0,  w,   0))
        return result
    }
}

extension MTLSize {
    static let one = MTLSize(width: 1, height: 1, depth: 1)
}

//https://stackoverflow.com/questions/26181221/how-to-convert-a-decimal-number-to-binary-in-swift
extension String {

    static func binaryRepresentation<F: FixedWidthInteger>(of val: F) -> String {

        let binaryString = String(val, radix: 2)

        if val.leadingZeroBitCount > 0 {
            return String(repeating: "0", count: val.leadingZeroBitCount) + binaryString
        }

        return binaryString
    }
}

extension Date {
    
    static var now: String {
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: date)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss:SSS"
        return formatter.string(from: calendar.date(from: components)!)
    }
}



extension UInt8 {
    var bool: Bool {
        return self != 0
    }
}
