//
//  ComputePipelineStates.swift
//  FluidSimulation
//
//  Created by Gabriel Thomson on 5/1/25.
//

import Metal

@MainActor
class ComputePipelineStates {
    private(set) static var gravityAndPredictedPositionUpdate: MTLComputePipelineState!
    private(set) static var densityUpdate: MTLComputePipelineState!
    private(set) static var spacialLookupUpdate: MTLComputePipelineState!
    private(set) static var pressureForceAndVelocityUpdate: MTLComputePipelineState!
    private(set) static var positionAndConstraintsUpdate: MTLComputePipelineState!
    private(set) static var sortSpacialLookup: MTLComputePipelineState!
    private(set) static var startIndiciesUpdate: MTLComputePipelineState!
    
    static func initialize() {
        let gravityAndPredictedPositionUpdateDescriptor = MTLComputePipelineDescriptor()
        gravityAndPredictedPositionUpdateDescriptor.label = "GravityAndPredictedPositionUpdate"
        gravityAndPredictedPositionUpdateDescriptor.computeFunction = Engine.library.makeFunction(name: "updateParticlePositions")
        gravityAndPredictedPositionUpdateDescriptor.maxTotalThreadsPerThreadgroup = 1024
        
        gravityAndPredictedPositionUpdate = try! Engine.device.makeComputePipelineState(descriptor: gravityAndPredictedPositionUpdateDescriptor, options: []).0
        
        let densityUpdateDescriptor = MTLComputePipelineDescriptor()
        densityUpdateDescriptor.label = "DensityUpdate"
        densityUpdateDescriptor.computeFunction = Engine.library.makeFunction(name: "updateDensities")
        densityUpdateDescriptor.maxTotalThreadsPerThreadgroup = 1024
        densityUpdateDescriptor.maxCallStackDepth
        
        densityUpdate = try! Engine.device.makeComputePipelineState(descriptor: densityUpdateDescriptor, options: []).0
        
        let spatialLookupUpdateDescriptor = MTLComputePipelineDescriptor()
        spatialLookupUpdateDescriptor.label = "SpatialLookupUpdate"
        spatialLookupUpdateDescriptor.computeFunction = Engine.library.makeFunction(name: "updateSpacialLookup")
        spatialLookupUpdateDescriptor.maxTotalThreadsPerThreadgroup = 1024
        
        spacialLookupUpdate = try! Engine.device.makeComputePipelineState(descriptor: spatialLookupUpdateDescriptor, options: []).0
        
        let pressureUpdateDescriptor = MTLComputePipelineDescriptor()
        pressureUpdateDescriptor.label = "PressureAndVelocityUpdate"
        pressureUpdateDescriptor.computeFunction = Engine.library.makeFunction(name: "updateAndApplyPressureForce")
        pressureUpdateDescriptor.maxTotalThreadsPerThreadgroup = 1024
        
        pressureForceAndVelocityUpdate = try! Engine.device.makeComputePipelineState(descriptor: pressureUpdateDescriptor, options: []).0
        
        let positionAndConstraintUpdateDescriptor = MTLComputePipelineDescriptor()
        positionAndConstraintUpdateDescriptor.label = "PositionAndConstraintUpdate"
        positionAndConstraintUpdateDescriptor.computeFunction = Engine.library.makeFunction(name: "updatePositionsAndConstrait")
        positionAndConstraintUpdateDescriptor.maxTotalThreadsPerThreadgroup = 1024
        
        positionAndConstraintsUpdate = try! Engine.device.makeComputePipelineState(descriptor: positionAndConstraintUpdateDescriptor, options: []).0
        
        let sortSpacialLookupDescriptor = MTLComputePipelineDescriptor()
        sortSpacialLookupDescriptor.label = "SortSpacialLookup"
        sortSpacialLookupDescriptor.computeFunction = Engine.library.makeFunction(name: "sortSpacialLookup")
        sortSpacialLookupDescriptor.maxTotalThreadsPerThreadgroup = 1024
        
        sortSpacialLookup = try! Engine.device.makeComputePipelineState(descriptor: sortSpacialLookupDescriptor, options: []).0
        
        let startIndiciesUpdateDescriptor = MTLComputePipelineDescriptor()
        startIndiciesUpdateDescriptor.label = "StartIndiciesUpdate"
        startIndiciesUpdateDescriptor.computeFunction = Engine.library.makeFunction(name: "updateStartIndicies")
        startIndiciesUpdateDescriptor.maxTotalThreadsPerThreadgroup = 1024
        
        startIndiciesUpdate = try! Engine.device.makeComputePipelineState(descriptor: startIndiciesUpdateDescriptor, options: []).0
        
        logger.log("Initialized compute pipeline states")
    }
}
