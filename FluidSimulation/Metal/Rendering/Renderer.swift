//
//  Renderer.swift
//  FluidSimulation
//
//  Created by Gabriel Thomson on 12/15/24.
//

import MetalKit

@MainActor
class Renderer: NSObject, MTKViewDelegate {
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        if view.currentDrawable != nil && view.currentRenderPassDescriptor != nil {
            
            guard let commandBuffer = Engine.commandQueue.makeCommandBuffer() else { fatalError("Could not make command buffer") }
            commandBuffer.label = "Render Command Buffer"
            
            guard let computeCommandEncoder = commandBuffer.makeComputeCommandEncoder() else { fatalError("Could not make compute command encoder") }
            
            Simulation.main.update(computeCommandEncoder)
            
            computeCommandEncoder.endEncoding()
            
            guard let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: view.currentRenderPassDescriptor!) else { fatalError("Could not make render command encoder") }
            
            renderCommandEncoder.label = "Render Encoder"
            
            Simulation.main.render(renderCommandEncoder)
            
            renderCommandEncoder.endEncoding()
            
            commandBuffer.present(view.currentDrawable!)
            commandBuffer.commit()
        }
    }
}
