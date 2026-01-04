#version 460 core

#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform float uTime;

out vec4 fragColor;

// Warp function from Shadertoy
vec2 W(vec2 p) {
    p = (p + 3.0) * 4.0;
    float t = uTime / 2.0;
    
    for (int i = 0; i < 3; i++) {
        p += cos(p.yx * 3.0 + vec2(t, 1.57)) / 3.0;
        p += sin(p.yx + t + vec2(1.57, 0.0)) / 2.0;
        p *= 1.3;
    }
    
    p += fract(sin(p + vec2(13.0, 7.0)) * 5e5) * 0.03 - 0.015;
    return mod(p, 2.0) - 1.0;
}

// Bump function
float bumpFunc(vec2 p) {
    return length(W(p)) * 0.7071;
}

vec3 smoothFract(vec3 x) { 
    x = fract(x); 
    return min(x, x * (1.0 - x) * 12.0); 
}

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = (fragCoord - uResolution * 0.5) / uResolution.y;
    
    // Surface position and vectors
    vec3 sp = vec3(uv, 0.0);
    vec3 rd = normalize(vec3(uv, 1.0));
    vec3 lp = vec3(cos(uTime) * 0.5, sin(uTime) * 0.2, -1.0);
    vec3 sn = vec3(0.0, 0.0, -1.0);
    
    // Bump mapping
    vec2 eps = vec2(4.0 / uResolution.y, 0.0);
    float f = bumpFunc(sp.xy);
    float fx = bumpFunc(sp.xy - eps.xy);
    float fy = bumpFunc(sp.xy - eps.yx);
    
    const float bumpFactor = 0.05;
    fx = (fx - f) / eps.x;
    fy = (fy - f) / eps.x;
    sn = normalize(sn + vec3(fx, fy, 0.0) * bumpFactor);
    
    // Lighting
    vec3 ld = lp - sp;
    float lDist = max(length(ld), 0.0001);
    ld /= lDist;
    
    float atten = 1.0 / (1.0 + lDist * lDist * 0.15);
    atten *= f * 0.9 + 0.1;
    
    float diff = max(dot(sn, ld), 0.0);
    diff = pow(diff, 4.0) * 0.66 + pow(diff, 8.0) * 0.34;
    float spec = pow(max(dot(reflect(-ld, sn), -rd), 0.0), 12.0);
    
    // Texture color (procedural)
    vec3 texCol = smoothFract(W(sp.xy).xyy) * 0.1 + 0.2;
    texCol = smoothstep(0.05, 0.75, pow(texCol, vec3(0.75, 0.8, 0.85)));
    
    // Final color
    vec3 col = (texCol * (diff * vec3(1.0, 0.97, 0.92) * 2.0 + 0.5) + vec3(1.0, 0.6, 0.2) * spec * 2.0) * atten;
    
    // Environment reflection
    float ref = max(dot(reflect(rd, sn), vec3(1.0)), 0.0);
    col += col * pow(ref, 4.0) * vec3(0.25, 0.5, 1.0) * 3.0;
    
    // Gamma correction
    fragColor = vec4(sqrt(clamp(col, 0.0, 1.0)), 1.0);
}
