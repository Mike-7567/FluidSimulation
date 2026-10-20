//
//  FluidSimulationTests.swift
//  FluidSimulationTests
//
//  Created by Gabriel Thomson on 3/11/25.
//

import Testing
@testable import FluidSimulation

struct FluidSimulationTests {
    
    @Test("Test smoothing kernal")
    func smoothingKernalTest() throws {
        var prevValue: Float = -.greatestFiniteMagnitude
        for d in stride(from: 0.0, to: 2.0, by: 0.1) {
            let v = cSmoothingKernalDerivative(Float(d), 1)
            
            #expect(v >= prevValue)
            
            prevValue = v
            
            print("Distance: \(d), Value: \(v)")
        }
    }
    
    struct ConcurrencyTests {
        
        @MainActor
        @Test("Check for data races") func checkForDataRaces() throws {
            let concurrentSim1 = Simulation()
            let concurrentSim2 = Simulation()
            
            var settings = defaultSimSettings
            
            settings.numOfParticles = 20
            settings.simState = 0
            
            concurrentSim1.simSettings = settings
            
            concurrentSim2.simSettings = settings
            
            let particles = Array(repeating: Particle(position: simd_float2(.random(in: -settings.bounds.x / 2...settings.bounds.x / 2), .random(in: -settings.bounds.y / 2...settings.bounds.y / 2))), count: Int(settings.numOfParticles))
            
            concurrentSim1.particles = particles
            concurrentSim2.particles = particles
            
            for i in 0..<1000 {
                concurrentSim1.update()
                concurrentSim2.update()
                
                for j in 0..<concurrentSim1.particles.count {
                    try #require(concurrentSim1.particles[j] == concurrentSim2.particles[j], "Test failed at iteration \(i)")
                }
            }
        }
    }
    
    @MainActor
    @Test func randomNumberGenerator() throws {
        MyRandomNumberGenerator.updateSimdFloat(in: -1...1)
        MyRandomNumberGenerator.shouldAutomaticlyUpdateValue = false
        for _ in 0..<10 {
            print(MyRandomNumberGenerator.getNextSimdFloat())
        }
    }
}
