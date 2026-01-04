#version 460 core

#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform float uTime;

out vec4 fragColor;

const float PI = 3.14159265359;

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = (fragCoord - uResolution * 0.5) / min(uResolution.x, uResolution.y);
    
    float t = uTime * 0.5;
    float segments = 8.0;
    
    // Convert to polar
    float angle = atan(uv.y, uv.x);
    float radius = length(uv);
    
    // Mirror across segments
    angle = abs(mod(angle, 2.0 * PI / segments) - PI / segments);
    
    // Back to cartesian with animation
    vec2 p = vec2(cos(angle), sin(angle)) * radius;
    p += vec2(sin(t), cos(t * 0.7)) * 0.3;
    
    // Create pattern
    float pattern = sin(p.x * 10.0 + t) * cos(p.y * 10.0 - t);
    pattern += sin(length(p) * 15.0 - t * 2.0);
    pattern *= 0.5;
    
    vec3 col = vec3(
        sin(pattern * PI + t) * 0.5 + 0.5,
        sin(pattern * PI + t + 2.094) * 0.5 + 0.5,
        sin(pattern * PI + t + 4.188) * 0.5 + 0.5
    );
    
    // Vignette
    col *= 1.0 - radius * 0.5;
    
    fragColor = vec4(col, 1.0);
}
