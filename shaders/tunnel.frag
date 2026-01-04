#version 460 core

#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform float uTime;

out vec4 fragColor;

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = (fragCoord - uResolution * 0.5) / min(uResolution.x, uResolution.y);
    
    float t = uTime;
    
    // Polar coordinates
    float angle = atan(uv.y, uv.x);
    float radius = length(uv);
    
    // Tunnel effect
    float z = 1.0 / (radius + 0.1);
    float a = angle / 3.14159;
    
    // Texture coordinates moving through tunnel
    vec2 tc = vec2(z + t * 0.5, a);
    
    // Create pattern
    float pattern = sin(tc.x * 10.0) * cos(tc.y * 10.0 * 3.14159);
    pattern += sin(tc.x * 5.0 + t) * 0.5;
    
    // Colors
    vec3 col1 = vec3(0.1, 0.3, 0.5);
    vec3 col2 = vec3(0.9, 0.6, 0.3);
    vec3 col = mix(col1, col2, pattern * 0.5 + 0.5);
    
    // Depth fade
    col *= z * 0.3;
    col = clamp(col, 0.0, 1.0);
    
    // Center glow
    col += vec3(0.3, 0.5, 0.8) * (1.0 - smoothstep(0.0, 0.3, radius));
    
    fragColor = vec4(col, 1.0);
}
