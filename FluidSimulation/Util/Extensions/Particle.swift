//
//  Particle.swift
//  FluidSimulation
//
//  Created by Gabriel Thomson on 12/17/24.
//

extension Particle: Equatable, CustomStringConvertible {
    public var description: String {
        return "Pos: \(position.x), \(position.y) Vel: \(velocity.x), \(velocity.y), Den: \(density), Pred: \(predictedPosition.x), \(predictedPosition.y)"
    }
    
    
    init(position: SIMD2<Float>) {
        self.init(position: position, velocity: .zero, density: 0, predictedPosition: position, isSelected: 0)
    }
    
    func containsNAN() -> Bool {
        return velocity.isNaN || position.isNaN || density.isNaN || predictedPosition.isNaN
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.position == rhs.position && lhs.velocity == rhs.velocity && lhs.density == rhs.density && lhs.predictedPosition == rhs.predictedPosition
    }
    
    
}
