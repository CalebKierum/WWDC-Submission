//
//  Shaders.metal
//  MTKView
//
//  Created by Caleb on 3/22/18.
//  Copyright © 2018 Caleb. All rights reserved.
//

// File for Metal kernel and shader functions

#include <metal_stdlib>
#include <simd/simd.h>
using namespace metal;

/*
 Whenever [[]] is put it is an attribute qualifier that links it to it
 -position shows the position coord used for clipping etc
 -buffer(n) links the data to a buffer index from setVertexBuffer function
 -vertex_id links it to the vertex id of the vertex shader
 -stage_in says it is per fragment data
 */

//This vertex will be used to interpret the input of the vertex shader and
//the output of the vertex shader
struct Vertex
{
    float4 position [[position]];
    float4 color;
};

//Create a vertex shader
vertex Vertex vertexShader(device Vertex *vertices [[buffer(0)]], uint vid [[vertex_id]]) {
    //Simply grab the verticie from the buffer at the index vid
    return vertices[vid];
}
fragment float4 fragmentShader(Vertex inVertex [[stage_in]]) {
    //Get the color of the invertex it will be interpolated
    return inVertex.color;
}

typedef struct
{
    float4 position [[position]];
    float2 texCoord;
} ColorInOut;

vertex ColorInOut vertex_copy(uint vid [[vertex_id]]) {
    const float2 coords[] = {float2(-1.0, -1.0),
        float2(1.0, -1.0),
        float2(-1.0, 1.0),
        float2(1.0, 1.0)};
    const float2 texc[] = {float2(0.0, 1.0),
        float2(1.0, 1.0),
        float2(0.0, 0.0),
        float2(1.0, 0.0)};
    
    const int lu[] = {0, 1, 2, 2, 1, 3};
    
    ColorInOut out;
    out.texCoord = texc[lu[vid]];
    out.position = float4(coords[lu[vid]], 0.0, 1.0);
    return out;
}

fragment float4 fragment_copy(texture2d<float> texture1 [[texture(0)]],
                              texture2d<float> texture2 [[texture(1)]],
                               constant float &w1 [[ buffer(0) ]],
                               constant float &w2 [[ buffer(1) ]],
                              constant float3 &color [[ buffer(2) ]],
                              ColorInOut texCoord [[stage_in]]) {
    
    float w1i = w1;
    if (w1i == 0.0) {
        w1i = 1.0;
    }
    float w2i = w2;
    if (w2i == 0.0) {
        w2i = 1.0;
    }
    float3 wcolor = color;
    if (length(wcolor) == 0) {
        wcolor = float3(1.0, 1.0, 1.0);
    }
    
    constexpr sampler colorSampler(mip_filter::linear,
                                   mag_filter::linear,
                                   min_filter::linear,
                                   s_address::mirrored_repeat,
                                   t_address::mirrored_repeat,
                                   r_address::mirrored_repeat);
    
    return float4(clamp(0.0, 1.0, texture1.sample(colorSampler, texCoord.texCoord).rgb * w1i + texture2.sample(colorSampler, texCoord.texCoord * 0.5).r * w2i * wcolor), 1.0);
}
vertex ColorInOut vertex_alpha(uint vid [[vertex_id]]) {
    const float2 coords[] = {float2(-1.0, -1.0),
        float2(1.0, -1.0),
        float2(-1.0, 1.0),
        float2(1.0, 1.0)};
    const float2 texc[] = {float2(0.0, 1.0),
        float2(1.0, 1.0),
        float2(0.0, 0.0),
        float2(1.0, 0.0)};
    
    const int lu[] = {0, 1, 2, 2, 1, 3};
    
    ColorInOut out;
    out.texCoord = texc[lu[vid]];
    out.position = float4(coords[lu[vid]], 0.0, 1.0);
    return out;
}
fragment float4 fragment_alpha(texture2d<float> texture1 [[texture(0)]],
                              ColorInOut texCoord [[stage_in]]) {
    
    constexpr sampler colorSampler(mip_filter::linear,
                                   mag_filter::linear,
                                   min_filter::linear,
                                   s_address::mirrored_repeat,
                                   t_address::mirrored_repeat,
                                   r_address::mirrored_repeat);
    //float alpha = texture1.sample(colorSampler, texCoord.texCoord).a;
    return float4(float3(texture1.sample(colorSampler, texCoord.texCoord).a), 1.0);
}
vertex ColorInOut vertex_clamp(uint vid [[vertex_id]]) {
    const float2 coords[] = {float2(-1.0, -1.0),
        float2(1.0, -1.0),
        float2(-1.0, 1.0),
        float2(1.0, 1.0)};
    const float2 texc[] = {float2(0.0, 1.0),
        float2(1.0, 1.0),
        float2(0.0, 0.0),
        float2(1.0, 0.0)};
    
    const int lu[] = {0, 1, 2, 2, 1, 3};
    
    ColorInOut out;
    out.texCoord = texc[lu[vid]];
    out.position = float4(coords[lu[vid]], 0.0, 1.0);
    return out;
}

fragment float4 fragment_clamp(texture2d<float> texture1 [[texture(0)]],
                               constant float &wall [[ buffer(0) ]],
                               constant float &tolerance [[ buffer(1) ]],
                              ColorInOut texCoord [[stage_in]]) {
    
    float wallc = wall;
    if (wallc == 0) {
        wallc = 0.9;
    }
    float tolerancec = tolerance;
    if (tolerancec == 0) {
        tolerancec = 0.01;
    }
    
    constexpr sampler colorSampler(mip_filter::linear,
                                   mag_filter::linear,
                                   min_filter::linear,
                                   s_address::mirrored_repeat,
                                   t_address::mirrored_repeat,
                                   r_address::mirrored_repeat);
    float4 col = texture1.sample(colorSampler, texCoord.texCoord);
    float mag = length(col.rgb);
    float fxn = smoothstep(wallc - tolerancec, wallc + tolerancec, mag);
    return float4(float3(fxn), fxn);
}

