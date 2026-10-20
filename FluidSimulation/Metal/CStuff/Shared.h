//
//  CStuff.h
//  FluidSimulation
//
//  Created by Gabriel Thomson on 1/27/25.
//

#include <simd/simd.h>

#ifndef CStuff_h
#define CStuff_h

struct SimSettings {
    float gravity;
    simd_float4 particleColor;
    float dampingFactor;
    float terminalVelocity;
    float targetDensity;
    uint32_t numOfParticles;
    float smoothRadius;
    uint32_t stepsPerFrame;
    simd_float4 lowDensityColor;
    simd_float4 highDensityColor;
    simd_float4 idealDensityColor;
    uint8_t simState;
    uint8_t showDensity;
    simd_float3 bounds;
    uint8_t renderParticles;
    uint8_t renderSmoothingRadius;
    float particleMass;
    float pressureMultiplier;
    uint8_t renderGrid;
    uint32_t observedParticleIndex;
};

struct Particle {
    simd_float2 position;
    simd_float2 velocity;
    float density;
    simd_float2 predictedPosition;
    uint8_t isSelected;
};

struct SceneConstants {
    simd_float4x4 projectionMatrix;
    simd_float4x4 viewMatrix;
};

struct ModelConstants {
    simd_float4x4 modelMatrix;
};

struct Entry {
    uint32_t cellKey;
    uint32_t particleIndex;
};

enum BufferPositions {
    ParticlesIndex = 1,
    SimSettingsIndex = 2,
    SceneConstantsIndex = 3,
    ModelConstantsIndex = 4,
    SpacialLookupIndex = 5,
    StartIndiciesIndex = 6
};

enum VertexDescriptorAttributes {
    MyPosAttribute = 0,
    MyTexCoordAttribute = 1,
    MyNormalAttribute = 2
};

enum SimState: uint8_t {
    pause = 1,
    play = 0,
    step = 2
};

float cSmoothingKernal(float distance, float radius) {
    if (distance >= radius) {
        return 0.;
    }
    
    const float pi = 3.14159265f;
    const float volume = pi * (radius * radius * radius * radius * radius) / 10.;
    
    const float v = radius - distance;
    
    return v * v * v / volume;
}

float cSmoothingKernalDerivative(float distance, float radius) {
    if (distance >= radius) {
        return 0.;
    }
    
    return -3.f * (radius * radius) + 6.f * radius * (distance) - 3.f * ((distance) * (distance));
}

float cDensityToPressure(float density, struct SimSettings simSettings) {
    float densityError = density - simSettings.targetDensity;
    float pressure = densityError * simSettings.pressureMultiplier;
    return pressure;
}

float cSharedPressure(float densityA, float densityB, struct SimSettings simSettings) {
    float pressureA = cDensityToPressure(densityA, simSettings);
    float pressureB = cDensityToPressure(densityB, simSettings);
    return (pressureA + pressureB) / 2;
}

float cAbs(float value) {
    if (value < 0) {
        return -value;
    } else {
        return value;
    }
}

//TODO: Implement better solution for dealing with negitive coords
simd_int2 positionToCellCoords(simd_float2 coords, struct SimSettings simSettings) {
    uint32_t cellX = (uint32_t)cAbs(coords.x / simSettings.smoothRadius);
    uint32_t cellY = (uint32_t)cAbs(coords.y / simSettings.smoothRadius);
    
    simd_int2 toReturn;
    
    toReturn.x = cellX;
    toReturn.y = cellY;
    
    return toReturn;
}

uint32_t hashCell(simd_int2 pos) {
    uint32_t a = pos.x * 15823;
    uint32_t b = pos.y * 9737333;
    
    return a + b;
}

uint32_t cellKeyFromHash(uint32_t hash, uint32_t length) {
    return hash % length;
}

#endif /* CStuff_h */
