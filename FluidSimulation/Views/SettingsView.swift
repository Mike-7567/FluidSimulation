//
//  SettingsView.swift
//  FluidSimulation
//
//  Created by Gabriel Thomson on 1/11/25.
//

import SwiftUI

struct SettingsView: View {
    @State var particleColor = defaultSimSettings.particleColor.toCGColor()
    @State var lowDensityColor = defaultSimSettings.lowDensityColor.toCGColor()
    @State var highDensityColor = defaultSimSettings.highDensityColor.toCGColor()
    @State var idealDensityColor = defaultSimSettings.idealDensityColor.toCGColor()
    @State var isPlaying = defaultSimSettings.simState == 0 ? true : false
    @State var showDensity = defaultSimSettings.showDensity == 1 ? true : false
    @State var renderParticles = defaultSimSettings.renderParticles == 1 ? true : false
    @State var renderSmoothingRadius = defaultSimSettings.renderSmoothingRadius == 1 ? true : false
    @State var renderGrid = defaultSimSettings.renderGrid == 1 ? true : false
    
    @State var updater = false
    
    @Binding var simSettings: SimSettings
    
    var body: some View {
        TabView {
            Tab("Colors", systemImage: "paintpalette") {
                ColorPicker("Particle color", selection: $particleColor)
                ColorPicker("Low density", selection: $lowDensityColor)
                ColorPicker("High density", selection: $highDensityColor)
                ColorPicker("Ideal Density", selection: $idealDensityColor)
            }
            
            Tab("Physics", systemImage: "gear") {
                Grid(alignment: .leading) {
                    GridRow {
                        VStack {
                            Slider(value: $simSettings.dampingFactor, in: 0.0...1) {
                                Text("Dampening factor \(simSettings.dampingFactor)")
                            }
                            Slider(value: $simSettings.terminalVelocity, in: 0.000001...0.1) {
                                Text("Terminal velocity \(simSettings.terminalVelocity)")
                            }
                            Slider(value: $simSettings.gravity, in: -0.04...0.04) {
                                Text("Gravity \(simSettings.gravity)")
                            }
                            Slider(value: $simSettings.bounds.x, in: 1...50) {
                                Text("Width \(simSettings.bounds.x)")
                            }
                            Slider(value: $simSettings.bounds.y, in: 1...35) {
                                Text("Hight \(simSettings.bounds.y)")
                            }
                            Slider(value: $simSettings.particleMass, in: 0...2) {
                                Text("Particle mass \(simSettings.particleMass)")
                            }
                            Slider(value: $simSettings.pressureMultiplier, in: 0...1) {
                                Text("Pressure multiplier \(simSettings.pressureMultiplier)")
                            }
                            //Slider(value: $simSettings.observedParticleIndex, in: 0...simSettings.numberOfParticles - 1) {
                            //    Text("Observed Particle Index \(simSettings.observedParticleIndex)")
                            //}
                        }
                    }
                    
                    Divider()
                    
                    GridRow {
                        Stepper(value: $simSettings.stepsPerFrame, in: 1...5) {
                            Text("Steps per frame \(simSettings.stepsPerFrame)")
                        }
                        
                        Stepper(value: $simSettings.observedParticleIndex) {
                            Text("Observed Particle Index \(simSettings.observedParticleIndex)")
                        }
                    }
                    
                    Divider()
                    
                    GridRow {
                        HStack {
                            Toggle("Play", isOn: $isPlaying)
                                .toggleStyle(.switch)
                            Toggle("Show Density", isOn: $showDensity)
                                .toggleStyle(.switch)
                            Toggle("Render Particles", isOn: $renderParticles)
                                .toggleStyle(.switch)
                            Toggle("Render Smoothing Radius", isOn: $renderSmoothingRadius)
                                .toggleStyle(.switch)
                            Toggle("Show Grid", isOn: $renderGrid)
                                .toggleStyle(.switch)
                        }
                    }
                    
                    Divider()
                }
            }
            
            Tab("SPH", systemImage: "drop") {
                Slider(value: $simSettings.targetDensity, in: 0...5) {
                    Text("Target density \(simSettings.targetDensity)")
                }
                Slider(value: $simSettings.smoothRadius, in: 0.001...2) {
                    Text("Smooth radius \(simSettings.smoothRadius)")
                }
            }
            
            Tab("Particles", systemImage: "smallcircle.fill.circle.fill") {
                let pointer = Simulation.main.particlesBuffer.contents().bindMemory(to: Particle.self, capacity: simSettings.intNumberOfParticles)
                ScrollView {
                    ForEach(0..<10) { i in
                        if i >= simSettings.intNumberOfParticles {
                            return Text("")
                        } else {
                            return Text("\(pointer.advanced(by: i).pointee)")
                        }
                    }
                }
                
                Toggle(isOn: $updater) {
                    Text("Update")
                }
            }
        }
        .padding()
        .frame(minWidth: 400, idealWidth: 400, maxWidth: .infinity, minHeight: 200, idealHeight: 200, maxHeight: .infinity, alignment: .center)
        .windowResizeBehavior(.enabled)
        .onChange(of: particleColor) {
            simSettings.particleColor = particleColor.toSimdColor()
        }
        .onChange(of: lowDensityColor) {
            simSettings.lowDensityColor = lowDensityColor.toSimdColor()
        }
        .onChange(of: highDensityColor) {
            simSettings.highDensityColor = highDensityColor.toSimdColor()
        }
        .onChange(of: idealDensityColor) {
            simSettings.idealDensityColor = idealDensityColor.toSimdColor()
        }
        .onChange(of: isPlaying) {
            simSettings.simState = isPlaying ? 0 : 1
        }
        .onChange(of: showDensity) {
            simSettings.showDensity = showDensity ? 1 : 0
        }
        .onChange(of: renderParticles) {
            simSettings.renderParticles = renderParticles ? 1 : 0
        }
        .onChange(of: renderSmoothingRadius) {
            simSettings.renderSmoothingRadius = renderSmoothingRadius ? 1 : 0
        }
        .onChange(of: renderGrid) {
            simSettings.renderGrid = renderGrid ? 1 : 0
        }
    }
}
