#version 460 core

#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform float uTime;

out vec4 fragColor;

vec2 hash2(vec2 p) {
    return fract(sin(vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)))) * 43758.5453);
}

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = fragCoord / uResolution;
    uv.x *= uResolution.x / uResolution.y;
    
    float t = uTime * 0.5;
    float scale = 8.0;
    
    uv *= scale;
    
    vec2 i_uv = floor(uv);
    vec2 f_uv = fract(uv);
    
    float minDist = 1.0;
    vec2 minPoint = vec2(0.0);
    
    // Check neighboring cells
    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            vec2 neighbor = vec2(float(x), float(y));
            vec2 point = hash2(i_uv + neighbor);
            
            // Animate points
            point = 0.5 + 0.5 * sin(t + 6.2831 * point);
            
            vec2 diff = neighbor + point - f_uv;
            float dist = length(diff);
            
            if (dist < minDist) {
                minDist = dist;
                minPoint = point;
            }
        }
    }
    
    // Color based on distance and cell
    vec3 col = vec3(0.0);
    col += 0.5 + 0.5 * sin(hash2(i_uv).x * 6.28 + vec3(0.0, 2.0, 4.0));
    col *= 1.0 - minDist;
    
    // Edge highlighting
    col += vec3(1.0) * smoothstep(0.02, 0.0, minDist - 0.4);
    
    fragColor = vec4(col, 1.0);
}
