//
//  Shape.swift
//  FluidSimulation
//
//  Created by Gabriel Thomson on 2/22/25.
//

import Metal

@MainActor
class Shape {
    var position: simd_float3 = .zero { didSet { updateMatrix() } }
    var rotation: simd_float3 = .zero { didSet { updateMatrix() } }
    var scale: simd_float3 = .one { didSet { updateMatrix() } }
    var modelConstants: ModelConstants
    var vertices: MTLBuffer
    let vertexCount: Int
    
    init(vertices: [Vertex]) {
        self.vertices = Engine.device.makeBuffer(bytes: vertices, length: MemoryLayout<Vertex>.stride * vertices.count, options: [])!
        self.vertexCount = vertices.count
        
        modelConstants = ModelConstants(modelMatrix: .identity)
    }
    
    func render(_ commandEncoder: MTLRenderCommandEncoder) {
        commandEncoder.setDepthStencilState(DepthStencilStates.less)
        commandEncoder.setRenderPipelineState(RenderPipelineStates.basic3dRenderPipelineState)
        commandEncoder.setVertexBuffer(vertices, offset: 0, index: 0)
        
        commandEncoder.setVertexModelConstants(modelConstants)
        
        commandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount)
    }
    
    private func updateMatrix() {
        var matrix: simd_float4x4 = .identity
        
        matrix.translate(direction: position)
        matrix.rotate(angle: rotation.x, axis: simd_float3(1, 0, 0))
        matrix.rotate(angle: rotation.y, axis: simd_float3(0, 1, 0))
        matrix.rotate(angle: rotation.z, axis: simd_float3(0, 0, 1))
        matrix.scale(axis: scale)
        
        modelConstants.modelMatrix = matrix
    }
}
