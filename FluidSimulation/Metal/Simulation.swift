//
//  Simulation.swift
//  FluidSimulation
//
//  Created by Gabriel Thomson on 2/13/25.
//

import Metal
import SwiftUI

@MainActor
class Simulation {
    static let main = Simulation()
    
    //MARK: Fields
    let controller = Controller(cameraPos: simd_float3(0, 0, 10))
    let indexBuffer: MTLBuffer
    let quadVertexBuffer: MTLBuffer = Vertex.quadBuffer(halfSize: 0.05)
    var simSettings = defaultSimSettings
    var particlesBuffer: MTLBuffer
    //var particles: [Particle]
    //var spacialLookup: [Entry] = Array(repeating: Entry(cellKey: 0, particleIndex: 0), count: Int(defaultSimSettings.numOfParticles))
    var spacialLookupBuffer: MTLBuffer
    //var startIndicies: [UInt32] = Array(repeating: .max, count: Int(defaultSimSettings.numOfParticles))
    var startIndiciesBuffer: MTLBuffer
    
    let circle = Circle()
    var sceneConstants = SceneConstants(projectionMatrix: .perspective(degreesFov: 45, aspectRatio: Preferences.aspectRatio, near: 0.1, far: 1000), viewMatrix: .identity)
    
    //MARK: Init
    init() {
        let indices: [UInt16] = [0, 1, 0, 2, 3, 2, 3, 1]
        indexBuffer = Engine.device.makeBuffer(bytes: indices, length: MemoryLayout<UInt16>.stride * indices.count, options: [])!
        
        var particles: [Particle] = []
        let count = Int(simSettings.numOfParticles)
        
        let particleSpacing: Float = 0.3
        
        let particlesPerRow = Int(sqrt(Float(count)))
        let particlesPerColumn = Int((count - 1) / particlesPerRow + 1)
        let spacing: Float = 0.01 * 2 + particleSpacing
        
        for i in 0..<count {
            var pos = simd_float2.zero
            
            let lhsx = Float(i % particlesPerRow)
            let lhsy = Float(i / particlesPerRow)
            
            let rhsx = Float(Double(particlesPerRow) / 2.0 + 0.5)
            let rhsy = Float(Double(particlesPerColumn) / 2.0 + 0.5)
            
            let xp = lhsx - rhsx
            let yp = lhsy - rhsy
            
            pos.x = xp * spacing
            pos.y = yp * spacing
            
            pos = simd_float2(.random(in: -simSettings.bounds.x / 2...simSettings.bounds.x / 2), .random(in: -simSettings.bounds.y / 2...simSettings.bounds.y / 2))
            
            particles.append(Particle(position: pos))
        }
        
        //self.particles = particles
        self.particlesBuffer = Engine.device.makeBuffer(bytes: particles, length: MemoryLayout<Particle>.stride * particles.count)!
        self.spacialLookupBuffer = Engine.device.makeBuffer(bytes: Array(repeating: Entry(cellKey: 0, particleIndex: 0), count: simSettings.intNumberOfParticles), length: MemoryLayout<Entry>.stride * simSettings.intNumberOfParticles, options: [])!
        self.startIndiciesBuffer = Engine.device.makeBuffer(bytes: Array(repeating: UInt32.max, count: simSettings.intNumberOfParticles), length: MemoryLayout<UInt32>.stride * simSettings.intNumberOfParticles)!
        
        logger.log("Created a new simulation with \(count) particles size of \(MemoryLayout<Particle>.stride * particles.count) bytes")
    }
    
    //MARK: Render
    func render(_ commandEncoder: MTLRenderCommandEncoder) {
        controller.updateViewMatrix()
        sceneConstants.viewMatrix = controller.viewMatrix
        
        commandEncoder.setSceneConstants(sceneConstants)
        
        let halfSize = simSettings.bounds / 2
        
        var boundsVertices: [Vertex] = []
        boundsVertices.reserveCapacity(4)
        //Top left
        boundsVertices.append(Vertex(position: simd_float3(-halfSize.x, halfSize.y, -5), texcoords: simd_float2(-halfSize.x, halfSize.y)))
        //Bottem left
        boundsVertices.append(Vertex(position: simd_float3(-halfSize.x, -halfSize.y, -5), texcoords: simd_float2(-halfSize.x, -halfSize.y)))
        //Top right
        boundsVertices.append(Vertex(position: simd_float3(halfSize.x, halfSize.y, -5), texcoords: simd_float2(halfSize.x, halfSize.y)))
        //Bottem right
        boundsVertices.append(Vertex(position: simd_float3(halfSize.x, -halfSize.y, -5), texcoords: simd_float2(halfSize.x, -halfSize.y)))
        
        commandEncoder.setSimSettings(simSettings)
        
        //Render density
        if simSettings.showDensity.bool {
            commandEncoder.setRenderPipelineState(RenderPipelineStates.density3dRenderPipelineState)
            commandEncoder.setDepthStencilState(DepthStencilStates.less)
            
            commandEncoder.setVertexBytes(&boundsVertices, length: MemoryLayout<Vertex>.stride * 4, index: 0)
            commandEncoder.resetModelConstants()
            commandEncoder.setFragmentBuffer(particlesBuffer, offset: 0, index: ParticlesIndex.rawValue)
            
            commandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        }
        
        //Render grid
        if simSettings.renderGrid.bool {
            commandEncoder.setRenderPipelineState(RenderPipelineStates.grid3dRenderPipelineState)
            commandEncoder.setDepthStencilState(DepthStencilStates.less)
            
            commandEncoder.setVertexBytes(&boundsVertices, length: MemoryLayout<Vertex>.stride * 4, index: 0)
            commandEncoder.resetModelConstants()
            
            commandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        }
        
        //Render outline
        commandEncoder.setRenderPipelineState(RenderPipelineStates.basic3dRenderPipelineState)
        commandEncoder.setDepthStencilState(DepthStencilStates.less)
        
        commandEncoder.setVertexBytes(&boundsVertices, length: MemoryLayout<Vertex>.stride * 4, index: 0)
        commandEncoder.resetModelConstants()
        
        commandEncoder.drawIndexedPrimitives(type: .line, indexCount: 8, indexType: .uint16, indexBuffer: indexBuffer, indexBufferOffset: 0)
        
        //Render particles
        if simSettings.renderParticles.bool {
            commandEncoder.setRenderPipelineState(RenderPipelineStates.particle3dRenderPipelineState)
            commandEncoder.setDepthStencilState(DepthStencilStates.always)
            
            commandEncoder.setVertexBuffer(quadVertexBuffer, offset: 0, index: 0)
            
            commandEncoder.setVertexBuffer(particlesBuffer, offset: 0, index: ParticlesIndex.rawValue)
            
            commandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4, instanceCount: Int(simSettings.numOfParticles))
        }
        
        //Render smoothing radius
        if simSettings.renderSmoothingRadius.bool {
            let pointer = particlesBuffer.contents().bindMemory(to: Particle.self, capacity: Int(simSettings.numOfParticles))
            circle.position.x = pointer.advanced(by: Int(simSettings.observedParticleIndex)).pointee.position.x
            circle.position.y = pointer.advanced(by: Int(simSettings.observedParticleIndex)).pointee.position.y
            circle.position.z = -5
            circle.radius = simSettings.smoothRadius
            circle.render(commandEncoder)
        }
    }
    
    //MARK: Update
    //Main update loop
    func update(_ computeCommandEncoder: MTLComputeCommandEncoder) {
        if simSettings.simState == pause.rawValue {
            return
        }
        
        let simSettings = self.simSettings
        
        //Update particle array
        for _ in 0..<simSettings.stepsPerFrame {
            updatePredictedPositions(computeCommandEncoder)
            
            updateSpacialLookup(computeCommandEncoder)
            
            sortSpacialLookup(computeCommandEncoder)
            
            updateStartIndicies(computeCommandEncoder)
            
            updateDensities(computeCommandEncoder)
            
            applyPressureForces(computeCommandEncoder)
            
            updatePositionsAndConstraints(computeCommandEncoder)
        }
        
        if simSettings.simState == step.rawValue {
            logger.log("Simulation stepped")
            self.simSettings.simState = pause.rawValue
        }
    }
    
    func updateSpacialLookup(_ computeEncoder: MTLComputeCommandEncoder) {
        computeEncoder.setComputePipelineState(ComputePipelineStates.spacialLookupUpdate)
        computeEncoder.setBuffer(spacialLookupBuffer, offset: 0, index: SpacialLookupIndex.rawValue)
        computeEncoder.setBuffer(particlesBuffer, offset: 0, index: ParticlesIndex.rawValue)
        computeEncoder.setSimSettings(simSettings)
        computeEncoder.dispatchThreadgroups(MTLSize(width: simSettings.intNumberOfParticles, height: 1, depth: 1), threadsPerThreadgroup: .one)
    }
    
    func sortSpacialLookup(_ computeEncoder: MTLComputeCommandEncoder) {
        computeEncoder.setComputePipelineState(ComputePipelineStates.sortSpacialLookup)
        computeEncoder.setBuffer(spacialLookupBuffer, offset: 0, index: SpacialLookupIndex.rawValue)
        computeEncoder.setSimSettings(simSettings)
        computeEncoder.dispatchThreadgroups(.one, threadsPerThreadgroup: .one)
    }
    
    func updateStartIndicies(_ computeEncoder: MTLComputeCommandEncoder) {
        computeEncoder.setComputePipelineState(ComputePipelineStates.startIndiciesUpdate)
        computeEncoder.setBuffer(spacialLookupBuffer, offset: 0, index: SpacialLookupIndex.rawValue)
        computeEncoder.setSimSettings(simSettings)
        computeEncoder.setBuffer(startIndiciesBuffer, offset: 0, index: StartIndiciesIndex.rawValue)
        computeEncoder.dispatchThreadgroups(.one, threadsPerThreadgroup: .one)
        
        //let readOnlySpacialLookup = self.spacialLookup
        //
        //for i: UInt32 in 0..<simSettings.numOfParticles {
        //    let key = readOnlySpacialLookup[i].cellKey
        //    let prevKey = i == 0 ? .max : readOnlySpacialLookup[i - 1].cellKey
        //    if key != prevKey {
        //        startIndicies[Int(key)] = i
        //    }
        //}
        //
        //for i in startIndicies {
        //
        //}
    }
    
    //Applies gravity and calculates the predicted position based only on the current velocity
    func updatePredictedPositions(_ computeEncoder: MTLComputeCommandEncoder) {
        computeEncoder.setComputePipelineState(ComputePipelineStates.gravityAndPredictedPositionUpdate)
        computeEncoder.setBuffer(particlesBuffer, offset: 0, index: ParticlesIndex.rawValue)
        computeEncoder.setSimSettings(simSettings)
        computeEncoder.dispatchThreads(MTLSize(width: simSettings.intNumberOfParticles, height: 1, depth: 1), threadsPerThreadgroup: .one)
    }
    
    //Calculates the density at each particle and updates it in the array
    func updateDensities(_ computeEncoder: MTLComputeCommandEncoder) {
        computeEncoder.setComputePipelineState(ComputePipelineStates.densityUpdate)
        computeEncoder.setBuffer(particlesBuffer, offset: 0, index: ParticlesIndex.rawValue)
        computeEncoder.setBuffer(spacialLookupBuffer, offset: 0, index: SpacialLookupIndex.rawValue)
        computeEncoder.setBuffer(startIndiciesBuffer, offset: 0, index: StartIndiciesIndex.rawValue)
        computeEncoder.setSimSettings(simSettings)
        computeEncoder.dispatchThreadgroups(MTLSize(width: simSettings.intNumberOfParticles, height: 1, depth: 1), threadsPerThreadgroup: .one)
    }
    
    //Calculates the pressure force that is applied to each particles velocity
    func applyPressureForces(_ computeEncoder: MTLComputeCommandEncoder) {
        computeEncoder.setComputePipelineState(ComputePipelineStates.pressureForceAndVelocityUpdate)
        computeEncoder.setBuffer(particlesBuffer, offset: 0, index: ParticlesIndex.rawValue)
        computeEncoder.setBuffer(spacialLookupBuffer, offset: 0, index: SpacialLookupIndex.rawValue)
        computeEncoder.setBuffer(startIndiciesBuffer, offset: 0, index: StartIndiciesIndex.rawValue)
        computeEncoder.setSimSettings(simSettings)
        computeEncoder.dispatchThreadgroups(MTLSize(width: simSettings.intNumberOfParticles, height: 1, depth: 1), threadsPerThreadgroup: .one)
    }
    
    //Updates each particle's position by adding on its velocity and than constrains its position and velocity
    func updatePositionsAndConstraints(_ computeEncoder: MTLComputeCommandEncoder) {
        computeEncoder.setComputePipelineState(ComputePipelineStates.positionAndConstraintsUpdate)
        computeEncoder.setBuffer(particlesBuffer, offset: 0, index: ParticlesIndex.rawValue)
        computeEncoder.setSimSettings(simSettings)
        computeEncoder.dispatchThreadgroups(MTLSize(width: simSettings.intNumberOfParticles, height: 1, depth: 1), threadsPerThreadgroup: .one)
    }
    
    //MARK: Helper functions
    func printParticle() {
        let pointer = particlesBuffer.contents().bindMemory(to: Particle.self, capacity: simSettings.intNumberOfParticles)
        logger.log("Particle \(self.simSettings.observedParticleIndex): \(pointer.advanced(by: Int(self.simSettings.observedParticleIndex)).pointee)")
    }
    
    func resetParticlePositions() {
        logger.log("Resetting particle positions...")
        var particles: [Particle] = []
        let count = Int(simSettings.numOfParticles)
        
        let particleSpacing: Float = 0.6
        
        let particlesPerRow = Int(sqrt(Float(count)))
        let particlesPerColumn = Int((count - 1) / particlesPerRow + 1)
        let spacing: Float = 0.01 * 2 + particleSpacing
        
        for i in 0..<count {
            var pos = simd_float2.zero
            
            let lhsx = Float(i % particlesPerRow)
            let lhsy = Float(i / particlesPerRow)
            
            let rhsx = Float(Double(particlesPerRow) / 2.0 + 0.5)
            let rhsy = Float(Double(particlesPerColumn) / 2.0 + 0.5)
            
            let xp = lhsx - rhsx
            let yp = lhsy - rhsy
            
            pos.x = xp * spacing
            pos.y = yp * spacing
            
            particles.append(Particle(position: pos))
        }
        
        self.particlesBuffer = Engine.device.makeBuffer(bytes: particles, length: MemoryLayout<Particle>.stride * particles.count)!
    }
}
