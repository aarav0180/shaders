#version 460 core

#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform float uTime;

out vec4 fragColor;

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = (fragCoord - uResolution * 0.5) / min(uResolution.x, uResolution.y);
    
    float t = uTime;
    
    // Classic plasma
    float v1 = sin(uv.x * 10.0 + t);
    float v2 = sin(10.0 * (uv.x * sin(t * 0.5) + uv.y * cos(t * 0.3)) + t);
    float v3 = sin(sqrt(100.0 * (uv.x * uv.x + uv.y * uv.y)) + t);
    float v4 = sin(sqrt(100.0 * (uv.x * uv.x + uv.y * uv.y + 1.0)) + t * 1.5);
    
    float v = (v1 + v2 + v3 + v4) * 0.25;
    
    vec3 col = vec3(
        sin(v * 3.14159) * 0.5 + 0.5,
        sin(v * 3.14159 + 2.094) * 0.5 + 0.5,
        sin(v * 3.14159 + 4.188) * 0.5 + 0.5
    );
    
    fragColor = vec4(col, 1.0);
}
