#version 330 compatibility

#define wind //foliage wawing in the wind
#define windSpeed 1 // [0.5 0.6 0.7 0.8 0.9 1 1.1 1.2 1.3 1.4 1.5 1.75 2.0 3.0 4.0 5.0 10 100] How fast the wind blows
#define windStrength 1// [0.5 0.6 0.7 0.8 0.9 1 1.1 1.2 1.3 1.4 1.5 1.75 2.0 3.0 4.0 5.0 10 100] How strong the wind is
#define windRenderDistance 8// [2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32]

#define Waves // Turn on water waves, can be turned off for better performance
#define waveHeight 1 // [0.5 0.6 0.7 0.8 0.9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 3 4 5 6 7 8 9 10 100] Change the height of the waves, WARNING: values above 1 can cause visual glitches, use with caution
#define waveSpeed 1 // [0.5 0.6 0.7 0.8 0.9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 3 4 5 6 7 8 9 10 100] Change the speed of the waves, use with caution as high values can cause visual glitches
#define waveQuality 1024 // [64 128 256 512 1024 2048 4096 8192]
#define waveRenderDistance 8// [2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32]

#include "/lib/shadowDistort.glsl"
#include "/lib/coordinateSpaceTransform.glsl"

out vec2 texcoord;
out vec4 glcolor;

uniform int worldTime;
in vec2 mc_Entity;
in vec2 mc_midTexCoord;

#include "lib/noise.glsl"

void main() {
  vec4 clipPos = ftransform();
  texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
  glcolor = gl_Color;
  #ifdef wind
  if(shadowDistance(ftransform()) < windRenderDistance * 16){
    if(mc_Entity.x == 10001 || (mc_Entity.x == 10002 && mc_midTexCoord.y > texcoord.y)|| (mc_Entity.x == 10003 && mc_midTexCoord.y < texcoord.y) || (mc_Entity.x == 10005 && mc_midTexCoord.y > texcoord.y)){
      vec3 worldPos = shadowClipToWorld(clipPos);
      worldPos.x += NPNoise(worldPos.xy * 100 + vec2(worldTime * windSpeed, worldTime * windSpeed),512) * windStrength*0.5;
      worldPos.z += NPNoise(worldPos.zy * 100 + vec2(worldTime * windSpeed, worldTime * windSpeed),512) * windStrength*0.5;
      worldPos.y += NPNoise(worldPos.xz * 100 + vec2(worldTime * windSpeed, worldTime * windSpeed),512) * windStrength * 0.1;
      clipPos = worldToShadowClip(worldPos);
    } else if ((mc_Entity.x == 10004 && mc_midTexCoord.y > texcoord.y) || (mc_Entity.x == 10005 && mc_midTexCoord.y < texcoord.y)){
      vec3 worldPos = shadowClipToWorld(clipPos);
      worldPos.x += NPNoise(worldPos.xy * 100 + vec2(worldTime * windSpeed, worldTime * windSpeed),512) * windStrength*0.25;
      worldPos.z += NPNoise(worldPos.zy * 100 + vec2(worldTime * windSpeed, worldTime * windSpeed),512) * windStrength*0.25;
      worldPos.y += NPNoise(worldPos.xz * 100 + vec2(worldTime * windSpeed, worldTime * windSpeed),512) * windStrength * 0.05;
    clipPos = worldToShadowClip(worldPos);
    }
  }
  #endif
  #ifdef Waves
    if(shadowDistance(ftransform()) < waveRenderDistance * 16){
      if(mc_Entity.y == 1.0){
        vec3 worldPos = shadowClipToWorld(clipPos);
        worldPos.y += min(pNoise(worldPos.xz * 100 + vec2(worldTime*waveSpeed, worldTime*waveSpeed),waveQuality)*waveHeight,0.1);
        clipPos = worldToShadowClip(worldPos);
		  }
    }
	#endif
	gl_Position = clipPos;
  gl_Position.xyz = distortShadowClipPos(gl_Position.xyz);
}