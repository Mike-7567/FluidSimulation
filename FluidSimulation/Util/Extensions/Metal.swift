//
//  RenderCommandEncoder.swift
//  FluidSimulation
//
//  Created by Gabriel Thomson on 2/20/25.
//
import Metal

extension MTLVertexAttributeDescriptorArray {
    subscript(index: UInt32) -> MTLVertexAttributeDescriptor! {
        return self[Int(index)]
    }
}

extension MTLComputeCommandEncoder {
    func setBytes(_ bytes: UnsafeRawPointer, length: Int, index: UInt32) {
        self.setBytes(bytes, length: length, index: Int(index))
    }
    
    func setBuffer(_ buffer: (any MTLBuffer)?, offset: Int, index: UInt32) {
        self.setBuffer(buffer, offset: offset, index: Int(index))
    }
    
    func setSimSettings(_ settings: SimSettings) {
        var settings = settings
        self.setBytes(&settings, length: MemoryLayout<SimSettings>.size, index: SimSettingsIndex.rawValue)
    }
}

extension MTLRenderCommandEncoder {
    func setFragmentBytes(_ bytes: UnsafeRawPointer, length: Int, index: UInt32) {
        self.setFragmentBytes(bytes, length: length, index: Int(index))
    }
    
    func setVertexBuffer(_ buffer: (any MTLBuffer)?, offset: Int, index: UInt32) {
        self.setVertexBuffer(buffer, offset: offset, index: Int(index))
    }
    
    func setFragmentBuffer(_ buffer: (any MTLBuffer)?, offset: Int, index: UInt32) {
        self.setFragmentBuffer(buffer, offset: offset, index: Int(index))
    }
    
    func setVertexBytes(_ bytes: UnsafeRawPointer, length: Int, index: UInt32) {
        self.setVertexBytes(bytes, length: length, index: Int(index))
    }
    
    func setVertexModelConstants(_ modelConstants: ModelConstants) {
        var constants = modelConstants
        self.setVertexBytes(&constants, length: MemoryLayout<ModelConstants>.stride, index: ModelConstantsIndex.rawValue)
    }
    
    func setFragmentModelConstants(_ modelConstants: ModelConstants) {
        var constants = modelConstants
        self.setFragmentBytes(&constants, length: MemoryLayout<ModelConstants>.stride, index: ModelConstantsIndex.rawValue)
    }
    
    func resetModelConstants() {
        let constants = ModelConstants(modelMatrix: .identity)
        self.setVertexModelConstants(constants)
        self.setFragmentModelConstants(constants)
    }
    
    func setSceneConstants(_ sceneConstants: SceneConstants) {
        var constants = sceneConstants
        self.setVertexBytes(&constants, length: MemoryLayout<SceneConstants>.stride, index: SceneConstantsIndex.rawValue)
        self.setFragmentBytes(&constants, length: MemoryLayout<SceneConstants>.stride, index: SceneConstantsIndex.rawValue)
    }
    
    func setSimSettings(_ simSettings: SimSettings) {
        var constants = simSettings
        self.setVertexBytes(&constants, length: MemoryLayout<SimSettings>.stride, index: SimSettingsIndex.rawValue)
        self.setFragmentBytes(&constants, length: MemoryLayout<SimSettings>.stride, index: SimSettingsIndex.rawValue)
    }
}
