#include <metal_stdlib>
#include "ShaderTypes.h"
using namespace metal;

struct RasterizerData {
    float4 position [[position]];
    float2 textureCoordinate;
};

vertex RasterizerData vertexShader(uint vertexId [[vertex_id]],
                                   constant Vertex *vertices [[buffer(0)]],
                                   constant vector_uint2 *viewportSizePointer [[buffer(1)]],
                                   constant float *scaleFactor [[buffer(2)]]) {
    RasterizerData out;
    
    float2 pixelSpacePosition = vertices[vertexId].position.xy;
    vector_float2 viewportSize = vector_float2(*viewportSizePointer);
    
    out.position = vector_float4(0.0, 0.0, 0.0, 1.0);
    out.position.xy = pixelSpacePosition / (viewportSize / *scaleFactor);
    
    out.textureCoordinate = vertices[vertexId].textureCoordinate;
    
    return out;
}

fragment float4 fragmentShader(RasterizerData in [[stage_in]],
                               texture2d<half> colorTexture [[texture(0)]]) {
    constexpr sampler textureSampler (filter::nearest);
    
    const half4 colorSample = colorTexture.sample(textureSampler, in.textureCoordinate);
    
    return float4(colorSample);
}
