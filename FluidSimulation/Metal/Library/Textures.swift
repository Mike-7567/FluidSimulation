//
//  Textures.swift
//  FluidSimulation
//
//  Created by Gabriel Thomson on 1/21/25.
//

import MetalKit

@MainActor
class Textures {
    
    private(set) static var textureToRender: MTLTexture!
    private(set) static var clearTexture: MTLTexture!
    private(set) static var testTexture: MTLTexture!
    
    static func initialize() {
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: Preferences.mainPixelFormat, width: 1920, height: 1080, mipmapped: false)
        textureDescriptor.usage = [.renderTarget, .shaderRead]
        
        textureToRender = Engine.device.makeTexture(descriptor: textureDescriptor)!
        textureToRender.label = "Texture to render"
        
        let clearTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: Preferences.mainPixelFormat, width: 1920, height: 1080, mipmapped: false)
        textureDescriptor.usage = .shaderRead
        
        clearTexture = Engine.device.makeTexture(descriptor: clearTextureDescriptor)!
        clearTexture.label = "Clear texture"
        
        testTexture = try! MTKTextureLoader(device: Engine.device).newTexture(name: "test", scaleFactor: 1, bundle: .main)
        testTexture.label = "Test texture"
        
        logger.log("Initialized textures")
    }
}
