#version 460 core

#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform float uTime;

out vec4 fragColor;

// Hash function
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

// Value noise
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(
        mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
        mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x),
        f.y
    );
}

// Fractal Brownian Motion
float fbm(vec2 p) {
    float value = 0.0;
    float amp = 0.5;
    float freq = 1.0;
    for (int i = 0; i < 6; i++) {
        value += amp * noise(p * freq);
        freq *= 2.0;
        amp *= 0.5;
    }
    return value;
}

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = fragCoord / uResolution;
    
    float t = uTime * 0.3;
    
    // Warped FBM
    vec2 q = vec2(fbm(uv + t * 0.1), fbm(uv + vec2(1.0)));
    vec2 r = vec2(fbm(uv + q + vec2(1.7, 9.2) + 0.15 * t), fbm(uv + q + vec2(8.3, 2.8) + 0.126 * t));
    float f = fbm(uv + r);
    
    vec3 col = mix(vec3(0.1, 0.2, 0.4), vec3(0.9, 0.6, 0.2), clamp(f * f * 2.0, 0.0, 1.0));
    col = mix(col, vec3(0.0, 0.2, 0.4), clamp(length(q), 0.0, 1.0));
    col = mix(col, vec3(0.9, 0.8, 0.6), clamp(length(r.x), 0.0, 1.0));
    
    fragColor = vec4(col * (f * 0.6 + 0.4), 1.0);
}
