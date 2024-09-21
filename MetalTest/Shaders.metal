//
//  Shaders.metal
//  MetalTest
//
//  Created by Evan Rinehart on 9/14/24.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

vertex VertexOut vertex_main(uint vertexID [[vertex_id]],
                             const device float3* vertexArray,
                             const device float2* texCoordArray) {
    VertexOut out;
    out.position = float4(vertexArray[vertexID], 1.0);
    out.texCoord = texCoordArray[vertexID];
    return out;
}

fragment float4 fragment_main(VertexOut in [[stage_in]],
                              texture2d<float> tex [[texture(0)]]) {
    constexpr sampler textureSampler;
    return tex.sample(textureSampler, in.texCoord);
}
