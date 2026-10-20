//
//  Engine.swift
//  FluidSimulation
//
//  Created by Gabriel Thomson on 12/15/24.
//

import Metal
import os

let logger = Logger(subsystem: "FluidSimulation", category: "Main")

func logNonZero<N: AdditiveArithmetic>(_ n: N, variableName: String = "No name") {
    if n == N.zero {
        let value = String(describing: n)
        logger.log("\(variableName) has value \(value)")
    }
}

@MainActor
final class Engine {
    static let device = MTLCreateSystemDefaultDevice()!
    static let commandQueue = device.makeCommandQueue()!
    static let library = device.makeDefaultLibrary()!
}
