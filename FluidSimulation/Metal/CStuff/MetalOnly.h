//
//  MetalOnly.h
//  FluidSimulation
//
//  Created by Gabriel Thomson on 5/1/25.
//

#ifndef MetalOnly_h
#define MetalOnly_h

#include "Shared.h"

//NOTE: paramiters mark with 'device' should NEVER be modified in here to avoid potential data races

bool areEqual(simd_float2 f1, simd_float2 f2) {
    return f1.x == f2.x && f1.y == f2.y;
}

bool areEqual(simd_float3 f1, simd_float3 f2) {
    return f1.x == f2.x && f1.y == f2.y && f1.z == f2.z;
}

bool areEqual(simd_float4 f1, simd_float4 f2) {
    return f1.x == f2.x && f1.y == f2.y && f1.z == f2.z && f1.w == f2.w;
}

bool areEqual(Particle particle1, Particle particle2) {
    return areEqual(particle1.position, particle2.position) && areEqual(particle1.velocity, particle2.velocity) && areEqual(particle1.predictedPosition, particle2.predictedPosition) && particle1.isSelected == particle2.isSelected && particle1.density == particle2.density;
}

// Constants for Gold Noise
constant float PHI = 1.61803398874989484820459 * 0.0001; // Golden Ratio
constant float PI_FACTOR = 3.14159265358979323846264 * 0.0001; // PI
constant float SQ2 = 1.41421356237309504880169 * 10000.0; // Square Root of Two

// Gold Noise function: Returns a normalized random float [0.0, 1.0]
float goldNoise(float2 coordinate, float seed) {
    return fract(tan(distance(coordinate * (seed + PHI), float2(PHI, PI_FACTOR))) * SQ2);
}

simd_float4 sumOfValueForEachParticleInRadius(Particle particle, device Particle *particles, SimSettings simSettings, constant uint32_t *startIndicies, constant Entry *spacialLookup, simd_float3 (*calculation)(Particle, uint32_t, device Particle *particles, SimSettings)) {
    
    simd_float4 value = 0;
    
    simd_int2 cellCoords = positionToCellCoords(particle.position, simSettings);
    
    float squareRadius = simSettings.smoothRadius * simSettings.smoothRadius;
    
    for (int32_t xOffset = -1; xOffset <= 1; xOffset++) {
        for (int32_t yOffset = -1; yOffset <= 1; yOffset++) {
            simd_int2 cellPos;
            cellPos.x = cellCoords.x + xOffset;
            cellPos.y = cellCoords.y + yOffset;
            
            uint32_t key = cellKeyFromHash(hashCell(cellPos), simSettings.numOfParticles);
            
            uint32_t cellStartIndex = startIndicies[key];
            
            if (cellStartIndex >= simSettings.numOfParticles) {
                continue;
            }
            
            for (uint32_t i = cellStartIndex; i < simSettings.numOfParticles; i++) {
                if (spacialLookup[i].cellKey != key) {
                    break;
                }
                
                uint32_t particleIndex = spacialLookup[i].particleIndex;
                
                simd_float2 dif = (particles[particleIndex].predictedPosition - particle.position);
                
                float dis = metal::length_squared(dif);
                
                if (dis < squareRadius) {
                    value.xyz += calculation(particle, particleIndex, particles, simSettings);
                    value.w += 1;
                } else {
                    value.w -= 1;
                }
            }
        }
    }
    
    return value;
}

//TODO: Have the dif and dis calculations done once
simd_float3 partialDensityCalculation(Particle particle, uint32_t index, device Particle *particles, SimSettings simSettings) {
    simd_float2 dif = particle.predictedPosition - particles[index].predictedPosition;
    
    float dis = metal::length(dif);
    
    simd_float3 toReturn = 0;
    
    toReturn.x = cSmoothingKernal(dis, simSettings.smoothRadius) * simSettings.particleMass;
    
    return toReturn;
}

simd_float2 calculateDensity(Particle particle, device Particle *particles, SimSettings simSettings, constant uint32_t *startIndicies, constant Entry *spacialLookup) {
    
    simd_float4 calculation = sumOfValueForEachParticleInRadius(particle, particles, simSettings, startIndicies, spacialLookup, partialDensityCalculation);
    
    return calculation.xz;
}

simd_float3 partialPressureForceCalculation(Particle particle, uint32_t index, device Particle *particles, SimSettings simSettings) {
    if (areEqual(particle, particles[index])) {
        return 0.;
    }
    
    simd_float2 offset = particles[index].predictedPosition - particle.predictedPosition;
    
    float dis = metal::length(offset);
    
    simd_float2 dir = 0.;
    if (dis == 0) {
        return goldNoise(particle.position.xy, simSettings.gravity) * 2 - 1;
    } else {
        dir = offset / dis;
    }
    
    float slope = cSmoothingKernalDerivative(dis, simSettings.smoothRadius);
    
    float density = particle.density;
    float sharedPressure = cSharedPressure(particles[index].density, density, simSettings);
    simd_float2 calculation = dir * sharedPressure * slope * simSettings.particleMass / density;
    simd_float3 toReturn = 0.;
    toReturn.x = calculation.x;
    toReturn.y = calculation.y;
    return 1.;
}

simd_float2 calculatePressureForce(uint32_t particleIndex, device Particle *particles, SimSettings simSettings, constant uint32_t *startIndicies, constant Entry *spacialLoockup) {
    
    simd_float2 pressureForce = sumOfValueForEachParticleInRadius(particles[particleIndex], particles, simSettings, startIndicies, spacialLoockup, partialPressureForceCalculation).xy;
    
    return pressureForce;
}

#endif /* MetalOnly_h */
