//
//  Preferences.swift
//  FluidSimulation
//
//  Created by Gabriel Thomson on 12/15/24.
//

import Metal

@MainActor
class Preferences {
    static let mainPixelFormat: MTLPixelFormat = .bgra8Unorm
    static let mainDepthFormat: MTLPixelFormat = .depth32Float
    static let numberOfParticles: Int = 100
    static let aspectRatio: Float = 16.0 / 9.0
    static let dAspectRatio: Double = 16.0 / 9.0
}
