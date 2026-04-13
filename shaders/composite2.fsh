#version 330 compatibility

#include "/lib/common.glsl"

uniform sampler2D colortex4;
uniform float viewWidth;
uniform float viewHeight;

in vec2 texcoord;

/* RENDERTARGETS: 4 */
layout(location = 0) out vec4 brightColor;

void main() {
    #ifdef Bloom
        bool horizontal = false;
        #include "/programs/GaussianBlur.glsl"
        brightColor = vec4(result, 1.0);
    #else
        brightColor = vec4(texture(colortex4, texcoord).rgb, 1.0);
    #endif
}