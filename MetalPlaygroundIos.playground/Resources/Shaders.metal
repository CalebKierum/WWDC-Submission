#include <metal_stdlib>
using namespace metal;

kernel void green(texture2d<float, access::write> outputTexture [[texture(0)]],
                             uint2 position [[thread_position_in_grid]])
{
    if (position.x >= outputTexture.get_width() || position.y >= outputTexture.get_height()) {
        return;
    }
    outputTexture.write(float4(position.x / 100.0, 0.0, 0.0, 0.0), position);
}
