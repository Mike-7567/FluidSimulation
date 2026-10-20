//
//  CLIView.swift
//  FluidSimulation
//
//  Created by Gabriel Thomson on 4/24/25.
//

import SwiftUI

struct CLIView: View {
    @State private var input: String = ""
    @State private var outputs: [String] = []
    @Binding var simSettings: SimSettings
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                ForEach(outputs, id: \.self) { input in
                    Text(input)
                }
            }
            TextField("", text: $input)
                .onSubmit {
                    handleInput(input)
                }
        }
        .padding()
    }
    
    func handleInput(_ input: String) {
        var output: String = ""
        
        let splitInput = input.components(separatedBy: .whitespaces)
        
        switch SimSettingsCodingKeys(rawValue: splitInput.first ?? "") {
        case .bounds:
            if let x = Float(splitInput[1]), let y = Float(splitInput[2]), let z = Float(splitInput[3]) {
                simSettings.bounds = simd_float3(x, y, z)
                output = "Set bounds to \(x), \(y), \(z)"
            } else {
                output = "Invalid parameters"
            }
        case .dampingFactor:
            if let factor = Float(splitInput[1]) {
                simSettings.dampingFactor = factor
                output = "Set damping factor to \(factor)"
            } else {
                output = "Invalid parameters"
            }
        case .gravity:
            if let gravity = Float(splitInput[1]) {
                simSettings.gravity = gravity
                output = "Set gravity to \(gravity)"
            } else {
                output = "Invalid parameters"
            }
        case .observedParticleIndex:
            if let index = Int(splitInput[1]) {
                simSettings.observedParticleIndex = UInt32(index)
                output = "Set observed particle index to \(index)"
            } else {
                output = "Invalid parameters"
            }
        case .pressureMultiplier:
            if let multiplier = Float(splitInput[1]) {
                simSettings.pressureMultiplier = multiplier
                output = "Set pressure multiplier to \(multiplier)"
            } else {
                output = "Invalid parameters"
            }
        case .simState:
            if let state = UInt8(splitInput[1]) {
                switch state {
                case pause.rawValue:
                    simSettings.simState = state
                    output = "Simulation paused"
                case play.rawValue:
                    simSettings.simState = state
                    output = "Simulation resumed"
                case step.rawValue:
                    simSettings.simState = state
                    output = "Simulation stepped"
                default:
                    output = "Invalid parameters"
                }
            } else {
                output = "Invalid parameters"
            }
        case .smoothRadius:
            if let radius = Float(splitInput[1]) {
                simSettings.smoothRadius = radius
                output = "Set smooth radius to \(radius)"
            } else {
                output = "Invalid parameters"
            }
        default:
            output = "Unknown command"
        }
        
        outputs.append(output)
    }
}
