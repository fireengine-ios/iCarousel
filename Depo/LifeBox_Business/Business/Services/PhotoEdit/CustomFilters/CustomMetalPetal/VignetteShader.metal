//
//  VignetteShader.metal
//  Depo
//
//  Created by Konstantin Studilin on 14.09.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include "MTIShaderLib.h"
using namespace metalpetal;

fragment float4 colorVignetteEffect (VertexOut vertexIn [[stage_in]],
                                texture2d<float, access::sample> sourceTexture [[texture(0)]],
                                sampler sourceSampler [[sampler(0)]],
                                constant float2 &vignetteCenter [[buffer(0)]],
                                constant float4 &vignetteColor [[buffer(1)]],
                                constant float &vignetteStart [[buffer(2)]],
                                constant float &vignetteEnd [[buffer(3)]]
                                )
{
    float4 sourceImageColor = sourceTexture.sample(sourceSampler, vertexIn.textureCoordinate);
    float d = distance(vertexIn.textureCoordinate, vignetteCenter);
    float percent = smoothstep(vignetteStart, vignetteEnd, d);
    return mix(sourceImageColor, vignetteColor, percent);
}

