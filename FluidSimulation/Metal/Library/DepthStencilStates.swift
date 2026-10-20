//
//  DepthStencilStates.swift
//  FluidSimulation
//
//  Created by Gabriel Thomson on 2/10/25.
//
import Metal

@MainActor
class DepthStencilStates {
    
    private(set) static var less: MTLDepthStencilState!
    private(set) static var always: MTLDepthStencilState!
    private(set) static var never: MTLDepthStencilState!
    
    static func initialize() {
        let defaultDepthStencilDescriptor = MTLDepthStencilDescriptor()
        defaultDepthStencilDescriptor.depthCompareFunction = .less
        defaultDepthStencilDescriptor.isDepthWriteEnabled = true
        less = Engine.device.makeDepthStencilState(descriptor: defaultDepthStencilDescriptor)!
        
        let alwaysDepthStencilDescriptor = MTLDepthStencilDescriptor()
        alwaysDepthStencilDescriptor.depthCompareFunction = .always
        alwaysDepthStencilDescriptor.isDepthWriteEnabled = true
        always = Engine.device.makeDepthStencilState(descriptor: alwaysDepthStencilDescriptor)!
        
        let neverDepthStencilDescriptor = MTLDepthStencilDescriptor()
        neverDepthStencilDescriptor.depthCompareFunction = .never
        neverDepthStencilDescriptor.isDepthWriteEnabled = true
        never = Engine.device.makeDepthStencilState(descriptor: neverDepthStencilDescriptor)!
        
        logger.log("Initialized depth stencil states.")
    }
}
