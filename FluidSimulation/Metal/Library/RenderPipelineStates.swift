//
//  PipelineStates.swift
//  FluidSimulation
//
//  Created by Gabriel Thomson on 12/15/24.
//

import Metal

@MainActor
class RenderPipelineStates {
    
    private(set) static var density3dRenderPipelineState: MTLRenderPipelineState!
    private(set) static var basic3dRenderPipelineState: MTLRenderPipelineState!
    private(set) static var particle3dRenderPipelineState: MTLRenderPipelineState!
    private(set) static var circle3dRenderPipelineState: MTLRenderPipelineState!
    private(set) static var cube3dRenderPipelineState: MTLRenderPipelineState!
    private(set) static var grid3dRenderPipelineState: MTLRenderPipelineState!
    
    static func initialize() {
        let densityRenderPipelineDescriptor = MTLRenderPipelineDescriptor()
        densityRenderPipelineDescriptor.vertexFunction = Engine.library.makeFunction(name: "basic3dRenderVsh")
        densityRenderPipelineDescriptor.fragmentFunction = Engine.library.makeFunction(name: "density3dRenderFsh")
        densityRenderPipelineDescriptor.colorAttachments[0].pixelFormat = Preferences.mainPixelFormat
        densityRenderPipelineDescriptor.depthAttachmentPixelFormat = Preferences.mainDepthFormat
        densityRenderPipelineDescriptor.vertexDescriptor = Vertex.vertexDescriptor
        densityRenderPipelineDescriptor.label = "DensityRenderPipelineState"
        
        density3dRenderPipelineState = try! Engine.device.makeRenderPipelineState(descriptor: densityRenderPipelineDescriptor)
        
        let basic3dRenderPipelineDescriptor = MTLRenderPipelineDescriptor()
        basic3dRenderPipelineDescriptor.vertexFunction = Engine.library.makeFunction(name: "basic3dRenderVsh")
        basic3dRenderPipelineDescriptor.fragmentFunction = Engine.library.makeFunction(name: "basic3dRenderFsh")
        basic3dRenderPipelineDescriptor.colorAttachments[0].pixelFormat = Preferences.mainPixelFormat
        basic3dRenderPipelineDescriptor.depthAttachmentPixelFormat = Preferences.mainDepthFormat
        basic3dRenderPipelineDescriptor.vertexDescriptor = Vertex.vertexDescriptor
        basic3dRenderPipelineDescriptor.label = "Basic3dRenderPipelineState"
        
        basic3dRenderPipelineState = try! Engine.device.makeRenderPipelineState(descriptor: basic3dRenderPipelineDescriptor)
        
        let particle3dRenderPipelineDescriptor = MTLRenderPipelineDescriptor()
        particle3dRenderPipelineDescriptor.vertexFunction = Engine.library.makeFunction(name: "particle3dRenderVsh")
        particle3dRenderPipelineDescriptor.fragmentFunction = Engine.library.makeFunction(name: "particle3dRenderFsh")
        particle3dRenderPipelineDescriptor.colorAttachments[0].pixelFormat = Preferences.mainPixelFormat
        particle3dRenderPipelineDescriptor.depthAttachmentPixelFormat = Preferences.mainDepthFormat
        particle3dRenderPipelineDescriptor.vertexDescriptor = Vertex.vertexDescriptor
        particle3dRenderPipelineDescriptor.label = "Particle3dRenderPipelineState"
        
        particle3dRenderPipelineState = try! Engine.device.makeRenderPipelineState(descriptor: particle3dRenderPipelineDescriptor)
        
        let circle3dRenderPipelineDescriptor = MTLRenderPipelineDescriptor()
        circle3dRenderPipelineDescriptor.vertexFunction = Engine.library.makeFunction(name: "basic3dRenderVsh")
        circle3dRenderPipelineDescriptor.fragmentFunction = Engine.library.makeFunction(name: "circle3dRenderFsh")
        circle3dRenderPipelineDescriptor.colorAttachments[0].pixelFormat = Preferences.mainPixelFormat
        circle3dRenderPipelineDescriptor.depthAttachmentPixelFormat = Preferences.mainDepthFormat
        circle3dRenderPipelineDescriptor.vertexDescriptor = Vertex.vertexDescriptor
        circle3dRenderPipelineDescriptor.label = "Particle3dRenderPipelineState"
        
        circle3dRenderPipelineState = try! Engine.device.makeRenderPipelineState(descriptor: circle3dRenderPipelineDescriptor)
        
        let cube3dRenderPipelineDescriptor = MTLRenderPipelineDescriptor()
        cube3dRenderPipelineDescriptor.vertexFunction = Engine.library.makeFunction(name: "instanced3dRenderVsh")
        cube3dRenderPipelineDescriptor.fragmentFunction = Engine.library.makeFunction(name: "basic3dRenderFsh")
        cube3dRenderPipelineDescriptor.colorAttachments[0].pixelFormat = Preferences.mainPixelFormat
        cube3dRenderPipelineDescriptor.depthAttachmentPixelFormat = Preferences.mainDepthFormat
        cube3dRenderPipelineDescriptor.vertexDescriptor = Vertex.vertexDescriptor
        cube3dRenderPipelineDescriptor.label = "Particle3dRenderPipelineState"
        
        cube3dRenderPipelineState = try! Engine.device.makeRenderPipelineState(descriptor: cube3dRenderPipelineDescriptor)
        
        let grid3dRenderPipelineDescriptor = MTLRenderPipelineDescriptor()
        grid3dRenderPipelineDescriptor.vertexFunction = Engine.library.makeFunction(name: "basic3dRenderVsh")
        grid3dRenderPipelineDescriptor.fragmentFunction = Engine.library.makeFunction(name: "grid3dRenderFsh")
        grid3dRenderPipelineDescriptor.colorAttachments[0].pixelFormat = Preferences.mainPixelFormat
        grid3dRenderPipelineDescriptor.depthAttachmentPixelFormat = Preferences.mainDepthFormat
        grid3dRenderPipelineDescriptor.vertexDescriptor = Vertex.vertexDescriptor
        grid3dRenderPipelineDescriptor.label = "Grid3dRenderPipelineState"
        
        grid3dRenderPipelineState = try! Engine.device.makeRenderPipelineState(descriptor: grid3dRenderPipelineDescriptor)
        
        logger.log("Initialized pipeline states")
    }
}
