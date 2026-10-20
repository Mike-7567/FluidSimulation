//
//  Vertex.swift
//  FluidSimulation
//
//  Created by Gabriel Thomson on 11/16/14.
//

import Metal

@MainActor
struct Vertex {
    let position: SIMD3<Float>
    let texcoords: SIMD2<Float>
    let normal: SIMD3<Float>
    
    init(position: SIMD3<Float>, texcoords: SIMD2<Float>, normal: SIMD3<Float> = .zero) {
        self.position = position
        self.texcoords = texcoords
        self.normal = normal
    }
    
    static let vertexDescriptor: MTLVertexDescriptor = Vertex.makeVertexDescriptor()
    
    static func makeVertexDescriptor() -> MTLVertexDescriptor {
        let descriptor = MTLVertexDescriptor()
        descriptor.attributes[MyPosAttribute.rawValue].format = .float3
        descriptor.attributes[MyPosAttribute.rawValue].bufferIndex = 0
        descriptor.attributes[MyPosAttribute.rawValue].offset = 0
        
        descriptor.attributes[MyTexCoordAttribute.rawValue].format = .float2
        descriptor.attributes[MyTexCoordAttribute.rawValue].bufferIndex = 0
        descriptor.attributes[MyTexCoordAttribute.rawValue].offset = MemoryLayout<Vertex>.offset(of: \.texcoords)!
        
        descriptor.attributes[MyNormalAttribute.rawValue].format = .float3
        descriptor.attributes[MyNormalAttribute.rawValue].bufferIndex = 0
        descriptor.attributes[MyNormalAttribute.rawValue].offset = MemoryLayout<Vertex>.offset(of: \.normal)!
        
        descriptor.layouts[0].stride = MemoryLayout<Vertex>.stride
        
        return descriptor
    }
    
    static func quadBuffer(halfSize: Float) -> MTLBuffer {
        var vertexData: [Vertex] = []
        
        vertexData.append(Vertex(position: [halfSize, halfSize, 0], texcoords: [1, 1], normal: .zero))
        vertexData.append(Vertex(position: [-halfSize, halfSize, 0], texcoords: [0, 1], normal: .zero))
        vertexData.append(Vertex(position: [halfSize, -halfSize, 0], texcoords: [1, 0], normal: .zero))
        vertexData.append(Vertex(position: [-halfSize, -halfSize, 0], texcoords: [0, 0], normal: .zero))
        
        let buffer = Engine.device.makeBuffer(bytes: vertexData, length: MemoryLayout<Vertex>.stride * vertexData.count, options: [])!
        buffer.label = "Quad vertices with size of \(halfSize * 2)"
        return buffer
    }
}
