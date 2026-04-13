#version 330 compatibility

#include "/lib/common.glsl"

uniform sampler2D colortex0;
uniform sampler2D colortex4;
uniform sampler2D depthtex0;
uniform sampler2D normals;

uniform mat4 gbufferProjectionInverse;
uniform vec3 fogColor;
uniform float far;

uniform float viewHeight;
uniform float viewWidth;

in vec2 texcoord;

/* RENDERTARGETS: 0,4 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 brightColor;

void main() {
  color = texture(colortex0, texcoord);

  float depth = texture(depthtex0, texcoord).r;
  if (depth == 1.0){
    return;
  }
  #ifdef Fog
    #include "/programs/Fog.glsl"
  #endif

  #ifdef Bloom
        bool horizontal = true;
        #include "/programs/GaussianBlur.glsl"
        brightColor = vec4(result, 1.0);
    #else
        brightColor = vec4(texture(colortex4, texcoord).rgb, 1.0);
    #endif
}