//
//  Cube.swift
//  FluidSimulation
//
//  Created by Gabriel Thomson on 2/8/25.
//
import simd
import Metal

@MainActor
class Cube: Shape {
    
    init() {
        let scale: Float = 0.1
        let vertices = [
                    //Left
            Vertex(position: simd_float3(-1.0 * scale,-1.0 * scale,-1.0 * scale), texcoords: simd_float2(0, 1), normal: .zero),
            Vertex(position: simd_float3(-1.0 * scale,-1.0 * scale, 1.0 * scale), texcoords: simd_float2(1, 1), normal: .zero),
            Vertex(position: simd_float3(-1.0 * scale, 1.0 * scale, 1.0 * scale), texcoords: simd_float2(1, 0), normal: .zero),
            Vertex(position: simd_float3(-1.0 * scale,-1.0 * scale,-1.0 * scale), texcoords: simd_float2(0, 1), normal: .zero),
            Vertex(position: simd_float3(-1.0 * scale, 1.0 * scale, 1.0 * scale), texcoords: simd_float2(1, 0), normal: .zero),
            Vertex(position: simd_float3(-1.0 * scale, 1.0 * scale,-1.0 * scale), texcoords: simd_float2(0, 0), normal: .zero),
                    
                    //RIGHT
            Vertex(position: simd_float3( 1.0 * scale, 1.0 * scale, 1.0 * scale), texcoords: simd_float2(0, 1), normal: .zero),
            Vertex(position: simd_float3( 1.0 * scale,-1.0 * scale,-1.0 * scale), texcoords: simd_float2(1, 0), normal: .zero),
            Vertex(position: simd_float3( 1.0 * scale, 1.0 * scale,-1.0 * scale), texcoords: simd_float2(1, 1), normal: .zero),
            Vertex(position: simd_float3( 1.0 * scale,-1.0 * scale,-1.0 * scale), texcoords: simd_float2(1, 0), normal: .zero),
            Vertex(position: simd_float3( 1.0 * scale, 1.0 * scale, 1.0 * scale), texcoords: simd_float2(0, 1), normal: .zero),
            Vertex(position: simd_float3( 1.0 * scale,-1.0 * scale, 1.0 * scale), texcoords: simd_float2(0, 0), normal: .zero),
                    
                    //TOP
            Vertex(position: simd_float3( 1.0 * scale, 1.0 * scale, 1.0 * scale), texcoords: simd_float2(1, 0), normal: .zero),
            Vertex(position: simd_float3( 1.0 * scale, 1.0 * scale,-1.0 * scale), texcoords: simd_float2(0, 0), normal: .zero),
            Vertex(position: simd_float3(-1.0 * scale, 1.0 * scale,-1.0 * scale), texcoords: simd_float2(0, 1), normal: .zero),
            Vertex(position: simd_float3( 1.0 * scale, 1.0 * scale, 1.0 * scale), texcoords: simd_float2(1, 0), normal: .zero),
            Vertex(position: simd_float3(-1.0 * scale, 1.0 * scale,-1.0 * scale), texcoords: simd_float2(0, 1), normal: .zero),
            Vertex(position: simd_float3(-1.0 * scale, 1.0 * scale, 1.0 * scale), texcoords: simd_float2(1, 1), normal: .zero),
                    
                    //BOTTOM
            Vertex(position: simd_float3( 1.0 * scale,-1.0 * scale, 1.0 * scale), texcoords: simd_float2(1, 0), normal: .zero),
            Vertex(position: simd_float3(-1.0 * scale,-1.0 * scale,-1.0 * scale), texcoords: simd_float2(0, 1), normal: .zero),
            Vertex(position: simd_float3( 1.0 * scale,-1.0 * scale,-1.0 * scale), texcoords: simd_float2(1, 1), normal: .zero),
            Vertex(position: simd_float3( 1.0 * scale,-1.0 * scale, 1.0 * scale), texcoords: simd_float2(1, 0), normal: .zero),
            Vertex(position: simd_float3(-1.0 * scale,-1.0 * scale, 1.0 * scale), texcoords: simd_float2(0, 0), normal: .zero),
            Vertex(position: simd_float3(-1.0 * scale,-1.0 * scale,-1.0 * scale), texcoords: simd_float2(0, 1), normal: .zero),
                    
                    //BACK
            Vertex(position: simd_float3( 1.0 * scale, 1.0 * scale,-1.0 * scale), texcoords: simd_float2(0, 1), normal: .zero),
            Vertex(position: simd_float3(-1.0 * scale,-1.0 * scale,-1.0 * scale), texcoords: simd_float2(1, 0), normal: .zero),
            Vertex(position: simd_float3(-1.0 * scale, 1.0 * scale,-1.0 * scale), texcoords: simd_float2(1, 1), normal: .zero),
            Vertex(position: simd_float3( 1.0 * scale, 1.0 * scale,-1.0 * scale), texcoords: simd_float2(0, 1), normal: .zero),
            Vertex(position: simd_float3( 1.0 * scale,-1.0 * scale,-1.0 * scale), texcoords: simd_float2(0, 0), normal: .zero),
            Vertex(position: simd_float3(-1.0 * scale,-1.0 * scale,-1.0 * scale), texcoords: simd_float2(1, 0), normal: .zero),
                    
                    //FRONT
            Vertex(position: simd_float3(-1.0 * scale, 1.0 * scale, 1.0 * scale), texcoords: simd_float2(1, 0), normal: .zero),
            Vertex(position: simd_float3(-1.0 * scale,-1.0 * scale, 1.0 * scale), texcoords: simd_float2(1, 1), normal: .zero),
            Vertex(position: simd_float3( 1.0 * scale,-1.0 * scale, 1.0 * scale), texcoords: simd_float2(0, 1), normal: .zero),
            Vertex(position: simd_float3( 1.0 * scale, 1.0 * scale, 1.0 * scale), texcoords: simd_float2(0, 0), normal: .zero),
            Vertex(position: simd_float3(-1.0 * scale, 1.0 * scale, 1.0 * scale), texcoords: simd_float2(1, 0), normal: .zero),
            Vertex(position: simd_float3( 1.0 * scale,-1.0 * scale, 1.0 * scale), texcoords: simd_float2(0, 1), normal: .zero)
            ]
        super.init(vertices: vertices)
    }
    
    override func render(_ commandEncoder: MTLRenderCommandEncoder) {
        rotation.x += 0.01
        rotation.y += 0.02
        scale = simd_float3(repeating: 0.1)
        position.z = 2.5
        
        commandEncoder.setDepthStencilState(DepthStencilStates.less)
        commandEncoder.setRenderPipelineState(RenderPipelineStates.basic3dRenderPipelineState)
        commandEncoder.setVertexBuffer(vertices, offset: 0, index: 0)
        
        commandEncoder.setVertexModelConstants(modelConstants)
        
        commandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount)
    }
}
