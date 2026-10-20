//
//  ContentView.swift
//  FluidSimulation
//
//  Created by Gabriel Thomson on 1/17/25.
//

import SwiftUI

struct ContentView: View {
    @Binding var simSettings: SimSettings
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                SimulationView(simSettings: $simSettings)
            }
        }
        .aspectRatio(CGFloat(Preferences.aspectRatio), contentMode: .fit)
        .frame(minWidth: 1920, idealWidth: 1920, maxWidth: .infinity, minHeight: 1080, idealHeight: 1080, maxHeight: .infinity)
        .onAppear() {
            simSettings = defaultSimSettings
        }
        .focusable()
        .onKeyPress(.space) {
            if Simulation.main.simSettings.simState == pause.rawValue {
                Simulation.main.simSettings.simState = step.rawValue
                return .handled
            } else {
                return .ignored
            }
        }
    }
}
