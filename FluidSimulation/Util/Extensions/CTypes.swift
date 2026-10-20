//
//  SimSettings.swift
//  FluidSimulation
//
//  Created by Gabriel Thomson on 2/20/25.
//

extension SimSettings: Codable {
    
    var intNumberOfParticles: Int { Int(numOfParticles) }
    
    //TODO: account for strings for colors in json and not just simd_float4
    public init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: SimSettingsCodingKeys.self)
        let gravity = try values.decode(Float.self, forKey: .gravity)
        let particleColor = try values.decode(simd_float4.self, forKey: .particleColor)
        let dampingFactor = try values.decode(Float.self, forKey: .dampingFactor)
        let terminalVelocity = try values.decode(Float.self, forKey: .terminalVelocity)
        let targetDensity = try values.decode(Float.self, forKey: .targetDensity)
        let numOfParticles = try values.decode(UInt32.self, forKey: .numOfParticles)
        let smoothRadius = try values.decode(Float.self, forKey: .smoothRadius)
        let stepsPerFrame = try values.decode(UInt32.self, forKey: .stepsPerFrame)
        let lowDensityColor = try values.decode(simd_float4.self, forKey: .lowDensityColor)
        let highDensityColor = try values.decode(simd_float4.self, forKey: .highDensityColor)
        let idealDensityColor = try values.decode(simd_float4.self, forKey: .idealDensityColor)
        let simState = try values.decode(UInt8.self, forKey: .simState)
        let showDensity = try values.decode(UInt8.self, forKey: .showDensity)
        let bounds = try values.decode(simd_float3.self, forKey: .bounds)
        let renderParticles = try values.decode(UInt8.self, forKey: .renderParticles)
        let renderSmoothingRadius = try values.decode(UInt8.self, forKey: .renderSmoothingRadius)
        let particleMass = try values.decode(Float.self, forKey: .particleMass)
        let pressureMultiplier = try values.decode(Float.self, forKey: .pressureMultiplier)
        let renderGrid = try values.decode(UInt8.self, forKey: .renderGrid)
        let observedParticleIndex = try values.decode(UInt32.self, forKey: .observedParticleIndex)
        
        self.init(gravity: gravity, particleColor: particleColor, dampingFactor: dampingFactor, terminalVelocity: terminalVelocity, targetDensity: targetDensity, numOfParticles: numOfParticles, smoothRadius: smoothRadius, stepsPerFrame: stepsPerFrame, lowDensityColor: lowDensityColor, highDensityColor: highDensityColor, idealDensityColor: idealDensityColor, simState: simState, showDensity: showDensity, bounds: bounds, renderParticles: renderParticles, renderSmoothingRadius: renderSmoothingRadius, particleMass: particleMass, pressureMultiplier: pressureMultiplier, renderGrid: renderGrid, observedParticleIndex: observedParticleIndex)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: SimSettingsCodingKeys.self)
        try container.encode(gravity, forKey: .gravity)
        try container.encode(particleColor, forKey: .particleColor)
        try container.encode(dampingFactor, forKey: .dampingFactor)
        try container.encode(terminalVelocity, forKey: .terminalVelocity)
        try container.encode(targetDensity, forKey: .targetDensity)
        try container.encode(numOfParticles, forKey: .numOfParticles)
        try container.encode(smoothRadius, forKey: .smoothRadius)
        try container.encode(stepsPerFrame, forKey: .stepsPerFrame)
        try container.encode(lowDensityColor, forKey: .lowDensityColor)
        try container.encode(highDensityColor, forKey: .highDensityColor)
        try container.encode(idealDensityColor, forKey: .idealDensityColor)
        try container.encode(simState, forKey: .simState)
        try container.encode(showDensity, forKey: .showDensity)
        try container.encode(bounds, forKey: .bounds)
        try container.encode(renderParticles, forKey: .renderParticles)
        try container.encode(renderSmoothingRadius, forKey: .renderSmoothingRadius)
        try container.encode(particleMass, forKey: .particleMass)
        try container.encode(pressureMultiplier, forKey: .pressureMultiplier)
        try container.encode(renderGrid, forKey: .renderGrid)
        try container.encode(observedParticleIndex, forKey: .observedParticleIndex)
    }
}

enum SimSettingsCodingKeys: String, CodingKey {
    case gravity
    case particleColor = "particle_color"
    case dampingFactor = "damping_factor"
    case terminalVelocity = "terminal_velocity"
    case targetDensity = "target_density"
    case numOfParticles = "num_of_particles"
    case smoothRadius = "smooth_radius"
    case stepsPerFrame = "steps_per_frame"
    case lowDensityColor = "low_density_color"
    case highDensityColor = "high_density_color"
    case idealDensityColor = "ideal_density_color"
    case simState = "sim_state"
    case showDensity = "show_density"
    case bounds = "bounds"
    case renderParticles = "render_particles"
    case renderSmoothingRadius = "render_smoothing_radius"
    case particleMass = "particle_mass"
    case pressureMultiplier = "pressure_multiplier"
    case renderGrid = "render_grid"
    case observedParticleIndex = "observed_particle_index"
}

extension Entry: Comparable, CustomStringConvertible {
    public var description: String {
        return "Cell Key: \(cellKey), Particle Index: \(particleIndex)"
    }
    
    public static func == (lhs: Entry, rhs: Entry) -> Bool {
        return lhs.cellKey == rhs.cellKey
    }
    
    public static func < (lhs: Entry, rhs: Entry) -> Bool {
        return lhs.cellKey < rhs.cellKey
    }
}
