#include <metal_stdlib>
#include <simd/simd.h>
using namespace metal;

//NOTE: a channel represents wetness

//How much water is the "Max water" cap
constant float cap = 4.0;

//Holds a color and a position
typedef struct
{
    float4 position [[position]];
    float2 texCoord;
} ColorInOut;

//Main vertex for all full screen things
vertex ColorInOut main_vertex(uint vid [[vertex_id]]) {
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

//Sets the texture passed in to white with 0 wetness
fragment float4 clear(ColorInOut texCoord [[stage_in]]) {
    
    constexpr sampler colorSampler(mip_filter::linear,
                                   mag_filter::linear,
                                   min_filter::linear,
                                   s_address::mirrored_repeat,
                                   t_address::mirrored_repeat,
                                   r_address::mirrored_repeat);
    return float4(1.0, 1.0, 1.0, 0.0);
}

//Steps the simulation by one frame
fragment float4 step(texture2d<float> current [[texture(0)]],
                     ColorInOut texCoord [[stage_in]]) {
    constexpr sampler colorSampler(mip_filter::linear,
                                   mag_filter::linear,
                                   min_filter::linear,
                                   s_address::mirrored_repeat,
                                   t_address::mirrored_repeat,
                                   r_address::mirrored_repeat);
    
    //Get the current color at the current location in the canvas
    float4 curr = current.sample(colorSampler, texCoord.texCoord);
    
    //How far we look for adjacent things in the water
    float2 scalar = float2(3.0 * (1.0 / 800.0));
    
    //The texture coordinate of the water
    float2 tc = texCoord.texCoord;
    
    //Colors from current location and things around it
    float4 col = current.sample(colorSampler, tc);
    float4 l = current.sample(colorSampler, tc + float2(-1.0, 0.0) * scalar);
    float4 r = current.sample(colorSampler, tc + float2(1.0, 0.0) * scalar);
    float4 u = current.sample(colorSampler, tc + float2(0.0, 1.0) * scalar);
    float4 d = current.sample(colorSampler, tc + float2(0.0, -1.0) * scalar);
    
    //Adjust all of the alpha values to consider the caps of water levels to alpha
    l.a *= (cap / 1.0);
    col.a *= (cap / 1.0);
    r.a *= (cap / 1.0);
    u.a *= (cap / 1.0);
    d.a *= (cap / 1.0);
    
    //Clamp the wentess that travels to adjacent cells
    float wetnessClamp = 0.2;
    float il = clamp(l.a - col.a,0.0,wetnessClamp);
    float ir = clamp(r.a - col.a,0.0,wetnessClamp);
    float iu = clamp(u.a - col.a,0.0,wetnessClamp);
    float id = clamp(d.a - col.a,0.0,wetnessClamp);
    
    //Calculate the contribution of all the colors based on their wetness
    float myContrib = (1.0-(il+id+ir+iu));
    col.xyz = (il*l.xyz)+(ir*r.xyz)+(iu*u.xyz)+(id*d.xyz)+myContrib*col.rgb;
    
    //Average all the surronding pigments
    float4 avg = (l + d + r + u) * 0.25;
    
    //Decide how much of our color mixes with the outside colors
    float porous = min(1.0, min(0.5,(col.a+avg.a)*0.9)*3.0);
    col.xyz = mix(col.xyz,avg.xyz,porous*0.05);
    col.w = mix(col.w,avg.w,porous) * (1.0 / cap);
    
    //The paint dries gradually
    col.w /= (1.0 + (0.03));
    return col;
}

//Paints the input texture onto the canvas texture
fragment float4 paint(texture2d<float> current [[texture(0)]],
                      texture2d<float> splat [[texture(1)]],
                      constant float3 &color [[ buffer(0) ]],
                      ColorInOut texCoord [[stage_in]]) {
    constexpr sampler colorSampler(mip_filter::linear,
                                   mag_filter::linear,
                                   min_filter::linear,
                                   s_address::mirrored_repeat,
                                   t_address::mirrored_repeat,
                                   r_address::mirrored_repeat);
    
    float4 curr = current.sample(colorSampler, texCoord.texCoord);
    float strength = splat.sample(colorSampler, texCoord.texCoord).r;
    float3 paint = strength * color;
    
    float adj = strength;
    float3 mi = sqrt(mix(curr.xyz * curr.xyz, paint * paint, 1.0 - smoothstep(0.8, 1.0, curr.a) * 0.2));
    return float4(float3(mi * adj + (1.0 - adj) * curr.xyz), adj * 10.0 * (1.0 / cap) + curr.a);
}
