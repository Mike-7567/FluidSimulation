//
//  Render.metal
//  FluidSimulation
//
//  Created by Gabriel Thomson on 12/15/24.
//

#include <metal_stdlib>
using namespace metal;
#include "../CStuff/Shared.h"
#include "../CStuff/MetalOnly.h"

//MARK: Logger
constant os_log logger(/*subsystem=*/"FluidSimulation", /*category=*/"RenderShaders");

//MARK: Structs
struct Vertex {
    float3 position [[ attribute(MyPosAttribute) ]];
    float2 texcoords [[ attribute(MyTexCoordAttribute) ]];
    float3 normal [[ attribute(MyNormalAttribute) ]];
};

struct RasterizerData {
    float4 position [[ position ]];
    float2 texcoords;
    float speed;
    float density;
    float3 normal;
    uint8_t masks;
};

//MARK: Rendering
vertex RasterizerData basic3dRenderVsh(Vertex vertIn [[ stage_in ]], constant SceneConstants &sceneConstants [[ buffer(SceneConstantsIndex) ]], constant ModelConstants &modelConstants [[ buffer(ModelConstantsIndex) ]]) {
    RasterizerData rd;
    
    rd.position = sceneConstants.projectionMatrix * sceneConstants.viewMatrix * modelConstants.modelMatrix * float4(vertIn.position, 1);
    rd.texcoords = vertIn.texcoords;
    
    return rd;
}

fragment half4 basic3dRenderFsh(RasterizerData rd [[ stage_in ]]) {
    return half4(rd.texcoords.x, rd.texcoords.y, 1., 1.);
}

vertex RasterizerData instanced3dRenderVsh(Vertex vertIn [[ stage_in ]], constant SceneConstants &sceneConstants [[ buffer(SceneConstantsIndex) ]], constant ModelConstants *modelConstants [[ buffer(ModelConstantsIndex) ]], uint instance [[ instance_id ]]) {
    RasterizerData rd;
    
    rd.position = sceneConstants.projectionMatrix * sceneConstants.viewMatrix * modelConstants[instance].modelMatrix * float4(vertIn.position.x, vertIn.position.y, vertIn.position.z , 1);
    rd.texcoords = vertIn.texcoords;
    
    return rd;
}

vertex RasterizerData particle3dRenderVsh(Vertex vertIn [[ stage_in ]], constant SceneConstants &sceneConstants [[ buffer(SceneConstantsIndex) ]], constant Particle *particles [[ buffer(ParticlesIndex) ]], uint instance [[ instance_id ]]) {
    RasterizerData rd;
    
    //Fix magic number -5 with float3 particle pos
    rd.position = sceneConstants.projectionMatrix * sceneConstants.viewMatrix * float4(vertIn.position.x + particles[instance].position.x, vertIn.position.y + particles[instance].position.y, vertIn.position.z - 5, 1);
    rd.texcoords = vertIn.texcoords;
    
    rd.masks = particles[instance].isSelected;
    
    return rd;
}

fragment half4 particle3dRenderFsh(RasterizerData rd [[ stage_in ]], constant SimSettings &simSettings [[ buffer(SimSettingsIndex) ]]) {
    float size = .5;
    
    if (length(rd.texcoords - .5) - size > 0) {
        discard_fragment();
    }
    
    //return half4(rd.density * 2, 0., 0., 1.);
    
    //float p = rd.speed / constants.terminalVelocity;
    
    //return half4(p, 0., 1. - p, 1.);
    
    if (rd.masks == 1) {
        return half4(1., 1., 0., 1.);
    }
    
    return half4(simSettings.particleColor);
}

fragment half4 grid3dRenderFsh(RasterizerData rd [[ stage_in ]], constant SimSettings &simSettings [[ buffer(SimSettingsIndex) ]]) {
    //TODO: Scale this with the distance to the camera to account for precision errors
    float lineThickness = 0.02;
    
    if (abs(fmod(rd.texcoords.x, simSettings.smoothRadius)) <= lineThickness) {
        return half4(rd.texcoords.x, rd.texcoords.y, 1., 1.);
    }
    
    if (abs(fmod(rd.texcoords.y, simSettings.smoothRadius)) <= lineThickness) {
        return half4(rd.texcoords.x, rd.texcoords.y, 1., 1.);
    }
    
    discard_fragment();
    
    return 0.;
}

fragment half4 density3dRenderFsh(RasterizerData rd [[ stage_in ]], constant Particle *particles [[buffer(ParticlesIndex)]], constant SimSettings &simSettings [[ buffer(SimSettingsIndex) ]]) {
    float densitySum = 0;
    const float2 pos = rd.texcoords;
    
    //return half4(pos.x, pos.y, 0., 1.);
    
    for (uint i = 0; i < simSettings.numOfParticles; i++) {
        float2 n = float2(particles[i].position - pos);
        float dis = sqrt(n.x * n.x + n.y * n.y);
        
        densitySum += cSmoothingKernal(dis, simSettings.smoothRadius) * simSettings.particleMass;
    }
    
    //if (densitySum == 0) return half4(0.5, 0.5, 0., 1.);
    float value = smoothstep(-1, 1, densitySum - simSettings.targetDensity);
    
    float height = saturate(densitySum - simSettings.targetDensity);
    
    // transition between 1 and 2 smoothly when height is between 0.2 and 0.4
    float interpolate_1_to_2 = smoothstep(0.2,0.4,height);
    // transition between 2 and 3 smoothly when height is between 0.6 and 0.8
    float interpolate_2_to_3 = smoothstep(0.6,0.8,height);

    float4 color = mix(simSettings.lowDensityColor,mix(simSettings.idealDensityColor,simSettings.highDensityColor,interpolate_2_to_3),interpolate_1_to_2);

    //float3 normal = normalize(mix(normal1,mix(normal2,normal3,interpolate_2_to_3),interpolate_1_to_2));
    return half4(color);
    
    return half4(value, 0, 0, 1);
    
    if (densitySum < simSettings.targetDensity) {
        float4 color;
        color = mix(simSettings.idealDensityColor, simSettings.lowDensityColor, (simSettings.targetDensity - densitySum));
        return half4(simSettings.lowDensityColor);
    }
    
    if (densitySum > simSettings.targetDensity) {
        float4 color;
        color = mix(simSettings.idealDensityColor, simSettings.highDensityColor, -(simSettings.targetDensity - densitySum));
        return half4(simSettings.highDensityColor);
    }
    
    return half4(simSettings.idealDensityColor);
}

fragment half4 circle3dRenderFsh(RasterizerData rd [[ stage_in ]]) {
    float size = .5;
    float lineThickness = 0.01;
    
    if (length(rd.texcoords - .5) - size > 0) {
        discard_fragment();
    }
    
    if (length(rd.texcoords - .5) - size + lineThickness < 0) {
        discard_fragment();
    }
    
    return half4(0., 1., 0., 1.);
}

//MARK: Computation
kernel void updateParticlePositions(device Particle *particles [[ buffer(ParticlesIndex) ]], constant SimSettings &simSettings [[ buffer(SimSettingsIndex) ]], uint id [[ thread_position_in_grid ]]) {
    
    particles[id].velocity.y -= simSettings.gravity;
    particles[id].predictedPosition = particles[id].position + particles[id].velocity;
}

kernel void updateSpacialLookup(device Entry *entries [[ buffer(SpacialLookupIndex) ]], constant Particle *particles [[ buffer(ParticlesIndex) ]], constant SimSettings &simSettings [[ buffer(SimSettingsIndex) ]], uint id [[ thread_position_in_grid ]]) {
    
    simd_int2 cellPos = positionToCellCoords(particles[id].predictedPosition, simSettings);
    
    int cellKey = cellKeyFromHash(hashCell(cellPos), simSettings.numOfParticles);
    Entry entry;
    entry.cellKey = cellKey;
    entry.particleIndex = id;
    
    entries[id] = entry;
    //logger.log("Cell key: %u, Particle Index %u", entries[id].cellKey, entries[id].particleIndex);
}

kernel void updateStartIndicies(device uint *startIndicies [[ buffer(StartIndiciesIndex) ]], constant Entry *entries [[ buffer(SpacialLookupIndex) ]], constant SimSettings &simSettings [[ buffer(SimSettingsIndex) ]], uint id [[ thread_position_in_grid ]]) {
    
    uint max = ~(0 | 0);
    
    for (uint i = 0; i < simSettings.numOfParticles; i++) {
        uint key = entries[i].cellKey;
        uint prevKey = i == 0 ? max : entries[i - 1].cellKey;
        if (key != prevKey) {
            startIndicies[key] = i;
        }
    }
}

kernel void sortSpacialLookup(device Entry *entries [[ buffer(SpacialLookupIndex) ]], constant SimSettings &simSettings [[ buffer(SimSettingsIndex) ]], uint id [[ thread_position_in_grid ]]) {
    //TODO: research parallel sorting
    uint i = 0;
    while (i < simSettings.numOfParticles - 1) {
        Entry e1 = entries[i];
        Entry e2 = entries[i + 1];
        
        if (e1.cellKey > e2.cellKey) {
            entries[i] = e2;
            entries[i + 1] = e1;
            i = 0;
            continue;
        }
        
        i += 1;
    }
    
    for (uint j = 0; j < simSettings.numOfParticles; j++) {
        logger.log("Entry %u: cell key %u, particle index %u", j, entries[j].cellKey, entries[j].particleIndex);
    }
}

kernel void updateDensities(device Particle *particles [[ buffer(ParticlesIndex) ]], constant Entry *entries [[ buffer(SpacialLookupIndex) ]], constant uint *startIndicies [[ buffer(StartIndiciesIndex) ]], constant SimSettings &simSettings [[ buffer(SimSettingsIndex) ]], uint id [[ thread_position_in_grid ]]) {
    
    simd_float2 calculation = calculateDensity(particles[id], particles, simSettings, startIndicies, entries);
    
    float density = calculation.x;
    
    if (density <= 0) {
        logger.log("Particle %u's density was calculated to be %f with %f iterations", id, density, calculation.y);
    }
    
    particles[id].density = density;
}

kernel void updateAndApplyPressureForce(device Particle *particles [[ buffer(ParticlesIndex) ]], constant Entry *entries [[ buffer(SpacialLookupIndex) ]], constant uint *startIndicies [[ buffer(StartIndiciesIndex) ]], constant SimSettings &simSettings [[ buffer(SimSettingsIndex) ]], uint id [[ thread_position_in_grid ]]) {
    
    simd_float2 pressureForce = calculatePressureForce(id, particles, simSettings, startIndicies, entries);
    
    simd_float2 pressureAcceleration = pressureForce / particles[id].density;
    if (pressureAcceleration.x == 0 && pressureAcceleration.y == 0) {
        logger.log("Particle %u has no pressure acceleration", id);
    }
    
    particles[id].velocity += pressureAcceleration;
}

kernel void updatePositionsAndConstrait(device Particle *particles [[ buffer(ParticlesIndex) ]], constant SimSettings &simSettings [[ buffer(SimSettingsIndex) ]], uint id [[ thread_position_in_grid ]]) {
    
    particles[id].position += particles[id].velocity;
    
    simd_float2 halfSize = (simSettings.bounds / 2).xy;
    
    if (abs(particles[id].position.x) > halfSize.x) {
        particles[id].velocity.x *= -1 * simSettings.dampingFactor;
        
        particles[id].position.x = halfSize.x * sign(particles[id].position.x);
    }
    
    if (abs(particles[id].position.y) > halfSize.y) {
        particles[id].velocity.y *= -1 * simSettings.dampingFactor;
        
        particles[id].position.y = halfSize.y * sign(particles[id].position.y);
    }
    
    //TODO: Implement terminal velocity
}
