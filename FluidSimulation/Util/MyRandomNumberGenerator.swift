//
//  Random.swift
//  FluidSimulation
//
//  Created by Gabriel Thomson on 3/13/25.
//

@MainActor
struct MyRandomNumberGenerator {
    static var shouldAutomaticlyUpdateValue: Bool = true
    static private var nextFloat: Float = 0
    static private var nextSimdFloat: simd_float4 = .one
    
    static func getNextFloat(in range: ClosedRange<Float> = -1...1) -> Float {
        if shouldAutomaticlyUpdateValue {
            nextFloat = Float.random(in: range)
        }
        return nextFloat
    }
    
    static func updateFloat(in range: ClosedRange<Float> = -1...1) {
        nextFloat = Float.random(in: range)
    }
    
    static func getNextSimdFloat(in range: ClosedRange<Float> = -1...1) -> simd_float4 {
        if shouldAutomaticlyUpdateValue {
            nextSimdFloat = .random(in: range)
        }
        return nextSimdFloat
    }
    
    static func updateSimdFloat(in range: ClosedRange<Float> = -1...1) {
        nextSimdFloat = .random(in: range)
    }
}
