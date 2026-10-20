//
//  FluidSimulationApp.swift
//  FluidSimulation
//
//  Created by Gabriel Thomson on 12/15/24.
//

import SwiftUI

@main
struct FluidSimulationApp: App {
    @State private var simSettings = SimSettings()
    
    var body: some Scene {
        WindowGroup {
            ContentView(simSettings: $simSettings)
        }
        Settings {
            SettingsView(simSettings: $simSettings)
        }
        #if DEBUG
        UtilityWindow("CLI", id: "cli") {
            CLIView(simSettings: $simSettings)
        }
        #endif
    }
    
    init() {
        logger.log("Size of SimSettings: \(MemoryLayout<SimSettings>.stride) bytes")
        
        Textures.initialize()
        RenderPipelineStates.initialize()
        DepthStencilStates.initialize()
        ComputePipelineStates.initialize()
    }
}

let defaultSimSettings = getDefaultSimSettings()

fileprivate func getDefaultSimSettings() -> SimSettings {
    do {
        guard let url = Bundle.main.url(forResource: "DefaultSettings", withExtension: ".json") else {
            fatalError(#function + ": Could not find DefaultSettings.json")
        }
        let data = try Data(contentsOf: url)
        let s = try JSONDecoder().decode(SimSettings.self, from: data)
        return s
    } catch {
        fatalError(error.localizedDescription)
    }
}
