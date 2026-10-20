//
//  SimulationView.swift
//  FluidSimulation
//
//  Created by Gabriel Thomson on 12/15/24.
//

import MetalKit
import SwiftUI

@MainActor
struct SimulationView: NSViewRepresentable {
    @State var renderer = Renderer()
    
    @Binding var simSettings: SimSettings
    
    func makeNSView(context: Context) -> MTKView {
        let view = MTKView()
        
        view.device = Engine.device
        view.preferredFramesPerSecond = 60
        view.delegate = renderer
        view.colorPixelFormat = Preferences.mainPixelFormat
        view.depthStencilPixelFormat = Preferences.mainDepthFormat
        
        return view
    }
    
    func updateNSView(_ nsView: MTKView, context: Context) {
        Simulation.main.simSettings = simSettings
    }
}
