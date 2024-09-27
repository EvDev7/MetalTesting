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

struct Uniforms {
    float4x4 projectionMatrix;
};

vertex VertexOut vertex_main(uint vertexID [[vertex_id]],
                             const device float3* vertexArray,
                             const device float2* texCoordArray,
                             constant Uniforms& uniforms [[buffer(2)]]) {
    VertexOut out;
    float4 position = float4(vertexArray[vertexID], 1.0);
    out.position = uniforms.projectionMatrix * position;  // Apply ortho projection
    out.texCoord = texCoordArray[vertexID];
    return out;
}

fragment float4 fragment_main(VertexOut in [[stage_in]],
                              texture2d<float> tex [[texture(0)]]) {
    constexpr sampler textureSampler(filter::linear, mip_filter::nearest); // Enable linear filtering for both texture and mipmaps
    return tex.sample(textureSampler, in.texCoord);
}
