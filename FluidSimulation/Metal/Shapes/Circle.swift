//
//  Circle.swift
//  FluidSimulation
//
//  Created by Gabriel Thomson on 2/15/25.
//

import Metal

@MainActor
class Circle: Shape {
    var radius: Float = 1
    
    init() {
        super.init(vertices: [Vertex(position: .zero, texcoords: .zero)])
    }
    
    override func render(_ commandEncoder: MTLRenderCommandEncoder) {
        var vertices: [Vertex] = []
        vertices.reserveCapacity(4)
        
        vertices.append(Vertex(position: simd_float3(radius, radius, 0), texcoords: simd_float2(1, 1)))
        vertices.append(Vertex(position: simd_float3(-radius, radius, 0), texcoords: simd_float2(0, 1)))
        vertices.append(Vertex(position: simd_float3(radius, -radius, 0), texcoords: simd_float2(1, 0)))
        vertices.append(Vertex(position: simd_float3(-radius, -radius, 0), texcoords: simd_float2(0, 0)))
        
        commandEncoder.setRenderPipelineState(RenderPipelineStates.circle3dRenderPipelineState)
        commandEncoder.setDepthStencilState(DepthStencilStates.always)
        
        commandEncoder.setVertexBytes(vertices, length: MemoryLayout<Vertex>.stride * vertices.count, index: 0)
        commandEncoder.setVertexModelConstants(modelConstants)
        
        commandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
    }
}
