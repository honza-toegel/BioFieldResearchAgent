//
//  OsciloscopeShader.metal
//  BioFieldResearchAgent
//
//  Created by Jan Toegel on 18.04.2025.
//
#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 uv;
};

vertex VertexOut vertex_osciloscope(const device float2* vertexArray [[buffer(0)]], uint vid [[vertex_id]]) {
    VertexOut out;
    out.position = float4(vertexArray[vid], 0, 1);
    out.uv = (vertexArray[vid] + float2(1.0)) * 0.5;
    return out;
}

struct SignalBuffer {
    //Float numbers representing amplitude [-1..1]
    constant float* buffer;
    uint bufferLength;
    
    //The gain of the signal amplitude
    //Ex: 0.5 means the signal values will be made 50% of original
    float signalGain;
};

// Fragment shader: render waveform
fragment float4 fragment_osciloscope_(VertexOut in [[stage_in]],
                              constant float *signalBuffer [[buffer(5)]],
                              constant uint &signalBufferLength [[buffer(6)]],
                              constant float &signalGain [[buffer(7)]])
                              //constant SignalBuffer& buffer [[buffer(8)]])
{
    float2 uv = in.uv;

    // Get signal index from input x
    uint signalIndex = uint(uv.x * (signalBufferLength - 1));
    signalIndex = clamp(signalIndex, (uint)0, (uint)signalBufferLength - 1);

    // Get the sample from the buffer
    float signalSampleAmplitude = signalBuffer[signalIndex]; // * signalGain;

    //Map signalSampleAmplitude min=0, max-1 to center of the screen negative part =[0.0 .. 0.5]  positive part [0.5 .. 1.1]
    float signalSampleAmplitudeCentered = 0.5 + signalSampleAmplitude * 0.5;

    // Line thickness
    float pointThickness = 0.01;

    // Create the color of the sample
    float colorOfSample = smoothstep(pointThickness, 0.0, abs(uv.y - signalSampleAmplitudeCentered));

    return float4(0.0, colorOfSample, 0.0, 1.0); // White waveform on black background
}

fragment float4 fragment_osciloscope(VertexOut in [[stage_in]],
                                     constant float *signalBuffer [[buffer(5)]],
                                     constant uint &signalBufferLength [[buffer(6)]],
                                     constant float &signalGain [[buffer(7)]]) {
    float2 uv = in.uv;
    uint signalIndex = uint(uv.x * (signalBufferLength - 1));
    signalIndex = clamp(signalIndex, 1u, signalBufferLength - 2); // Avoid out of bounds

    float sampleA = signalBuffer[signalIndex - 1]; // * signalGain;
    float sampleB = signalBuffer[signalIndex]; // * signalGain;

    float yA = 0.5 + sampleA * 0.5;
    float yB = 0.5 + sampleB * 0.5;

    // Compute the line between yA and yB
    float minY = min(yA, yB);
    float maxY = max(yA, yB);

    // Set a line thickness
    float thickness = 0.1;

    // Check if the current pixel's y (uv.y) lies within the vertical line span
    float color = smoothstep(thickness, 0.0, abs(uv.y - yA)) * step(uv.y, maxY) * step(minY, uv.y);

    return float4(0.0, color, 0.0, 1.0);
}
