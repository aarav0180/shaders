#version 460 core

#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform float uTime;

out vec4 fragColor;

// Optimized: Reduced constants
#define INTENSITY 1.2
#define SPEED 1.2
#define ARCS 6.0
#define CHAOS 2.0

// Fast hash - no loops
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

// Simplified arc - no fractal noise, fewer calculations
vec3 electricArc(vec2 p, vec2 start, vec2 end, float time, float arcId) {
    vec2 dir = end - start;
    float len = length(dir);
    if (len < 0.001) return vec3(0.0);
    dir /= len;
    vec2 perp = vec2(-dir.y, dir.x);
    
    float t = clamp(dot(p - start, dir) / len, 0.0, 1.0);
    vec2 closest = start + t * dir * len;
    
    // Simple displacement - just sine waves, no fractal noise
    float displacement = sin(t * 20.0 + time * 4.0 + arcId) * CHAOS * 0.12;
    displacement += sin(t * 50.0 + time * 8.0) * CHAOS * 0.06;
    
    closest += perp * displacement;
    float dist = length(p - closest);
    
    // Intensity falloff
    float intensity = 1.0 / (1.0 + dist * 60.0);
    intensity = intensity * intensity;
    
    // Simple flicker
    intensity *= 0.7 + 0.3 * sin(time * 12.0 + arcId * 2.0);
    intensity *= 1.0 - t * 0.3;
    
    // Color gradient
    vec3 col = mix(vec3(0.3, 0.5, 1.0), vec3(0.8, 0.3, 1.0), t);
    col += vec3(0.2, 0.1, 0.2) * intensity;
    
    return col * intensity;
}

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = fragCoord / uResolution;
    vec2 p = (uv - 0.5) * 2.0;
    p.x *= uResolution.x / uResolution.y;
    
    float time = uTime * SPEED;
    vec2 center = vec2(0.0);
    float centerDist = length(p);
    
    // Central orb
    float sphere = 1.0 - smoothstep(0.1, 0.16, centerDist);
    sphere += (1.0 - smoothstep(0.0, 0.1, centerDist)) * 2.0;
    float sphereEdge = smoothstep(0.42, 0.44, centerDist) * smoothstep(0.48, 0.46, centerDist);
    
    // Electric arcs - simplified loop
    vec3 electricity = vec3(0.0);
    for (float i = 0.0; i < ARCS; i++) {
        float baseAngle = (i / ARCS) * 6.283;
        float angle1 = baseAngle + time * 0.3 + sin(time * 0.5 + i) * 0.8;
        float angle2 = baseAngle + time * 0.35 + sin(time * 0.7 + i) * 0.9;
        
        float startR = 0.12 + sin(time * 1.5 + i) * 0.06;
        float endR = 0.44;
        
        vec2 start = vec2(cos(angle1), sin(angle1)) * startR;
        vec2 end = vec2(cos(angle2), sin(angle2)) * endR;
        
        electricity += electricArc(p, start, end, time + i, i * 10.0);
    }
    
    // Final composition
    vec3 finalColor = vec3(0.0);
    finalColor += vec3(0.7, 0.3, 1.0) * sphere * INTENSITY;
    finalColor += electricity * 1.5;
    finalColor += vec3(0.4, 0.2, 0.6) * sphereEdge * 0.3;
    
    // Outer glow
    float glow = (1.0 - smoothstep(0.4, 1.0, centerDist)) * 0.1;
    finalColor += vec3(0.3, 0.1, 0.5) * glow;
    
    // Gamma and vignette
    finalColor = pow(finalColor, vec3(0.9));
    finalColor *= 1.0 - centerDist * 0.3;
    
    fragColor = vec4(finalColor, 1.0);
}
