#version 330 compatibility

#include "/lib/common.glsl"

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex4;

in vec2 texcoord;

layout(location = 0) out vec4 color;

void main() {
    #ifdef HDR
        vec3 hdrColor = texture(colortex0, texcoord).rgb;
        #ifdef Bloom
            vec3 bloomColor = texture(colortex4, texcoord).rgb;
            hdrColor += bloomColor;
        #endif
        vec3 mapped = vec3(1.0) - exp(-hdrColor * 0.5);
        mapped = pow(mapped, vec3(1/2.2));
        color = vec4(mapped, 1.0);
    #else
        color = texture(colortex0, texcoord);
        color.rgb = pow(color.rgb, vec3(1/2.2));
    #endif
}