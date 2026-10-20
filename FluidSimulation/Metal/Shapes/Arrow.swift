//
//  Arrow.swift
//  FluidSimulation
//
//  Created by Gabriel Thomson on 2/22/25.
//

import Metal

class Arrow: Shape {
    
    init() {
        var vertices: [Vertex] = []
        //Rectangle
        //Top left
        vertices.append(Vertex(position: simd_float3(-2, 0.1, 0), texcoords: simd_float2(0, 1)))
        //Top right
        vertices.append(Vertex(position: simd_float3(2, 0.1, 0), texcoords: simd_float2(1, 1)))
        //Bottem left
        vertices.append(Vertex(position: simd_float3(-2, -0.1, 0), texcoords: simd_float2(0, 0)))
        //Top right
        vertices.append(Vertex(position: simd_float3(2, 0.1, 0), texcoords: simd_float2(1, 1)))
        //Bottem left
        vertices.append(Vertex(position: simd_float3(-2, -0.1, 0), texcoords: simd_float2(0, 0)))
        //Bottem right
        vertices.append(Vertex(position: simd_float3(2, -0.1, 0), texcoords: simd_float2(1, 0)))
        //Triangle
        //Top
        vertices.append(Vertex(position: simd_float3(2, 0.3, 0), texcoords: simd_float2(0, 1)))
        //Bottem
        vertices.append(Vertex(position: simd_float3(2, -0.3, 0), texcoords: simd_float2(0, -1)))
        //Middle
        vertices.append(Vertex(position: simd_float3(2.5, 0, 0), texcoords: simd_float2(1, 0.5)))
        
        super.init(vertices: vertices)
    }
    
    override func render(_ commandEncoder: any MTLRenderCommandEncoder) {
        commandEncoder.setRenderPipelineState(RenderPipelineStates.basic3dRenderPipelineState)
        commandEncoder.setDepthStencilState(DepthStencilStates.always)
        
        commandEncoder.setVertexModelConstants(self.modelConstants)
        commandEncoder.setVertexBuffer(self.vertices, offset: 0, index: 0)
        
        commandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 9)
    }
}
