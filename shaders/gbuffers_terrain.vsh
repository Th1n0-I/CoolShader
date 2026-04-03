#version 330 compatibility

#define wind //foliage wawing in the wind
#define windSpeed 1 // [0.5 0.6 0.7 0.8 0.9 1 1.1 1.2 1.3 1.4 1.5 1.75 2.0 3.0 4.0 5.0 10 100] How fast the wind blows
#define windStrength 1// [0.5 0.6 0.7 0.8 0.9 1 1.1 1.2 1.3 1.4 1.5 1.75 2.0 3.0 4.0 5.0 10 100] How strong the wind is

 out vec2 lmcoord;
 out vec2 texcoord;
 out vec4 glcolor;
 out vec3 normal;

 uniform int worldTime;
 in vec2 mc_Entity;
 in vec2 mc_midTexCoord;

 #include "lib/coordinateSpaceTransform.glsl"
 #include "lib/noise.glsl"


void main() {
  vec4 clipPos = ftransform();
  texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
  lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
  glcolor = gl_Color;
  #ifdef wind
  if(mc_Entity.x == 10001 || (mc_Entity.x == 10002 && mc_midTexCoord.y > texcoord.y)|| (mc_Entity.x == 10003 && mc_midTexCoord.y < texcoord.y) || (mc_Entity.x == 10005 && mc_midTexCoord.y > texcoord.y)){
    vec3 worldPos = clipToWorld(clipPos);
	  worldPos.x += NPNoise(worldPos.xy * 10 + vec2(worldTime * windSpeed, worldTime * windSpeed),512) * windStrength*0.5;
    worldPos.z += NPNoise(worldPos.zy * 10 + vec2(worldTime * windSpeed, worldTime * windSpeed),512) * windStrength*0.5;
    worldPos.y += NPNoise(worldPos.xz * 10 + vec2(worldTime * windSpeed, worldTime * windSpeed),512) * windStrength * 0.1;
    clipPos = worldToClip(worldPos);
  } else if ((mc_Entity.x == 10004 && mc_midTexCoord.y > texcoord.y) || (mc_Entity.x == 10005 && mc_midTexCoord.y < texcoord.y)){
    vec3 worldPos = clipToWorld(clipPos);
	  worldPos.x += NPNoise(worldPos.xy * 10 + vec2(worldTime * windSpeed, worldTime * windSpeed),512) * windStrength*0.25;
    worldPos.z += NPNoise(worldPos.zy * 10 + vec2(worldTime * windSpeed, worldTime * windSpeed),512) * windStrength*0.25;
    worldPos.y += NPNoise(worldPos.xz * 10 + vec2(worldTime * windSpeed, worldTime * windSpeed),512) * windStrength * 0.05;
    clipPos = worldToClip(worldPos);
  }
  #endif
	gl_Position = clipPos;

  normal = gl_NormalMatrix * gl_Normal; // this gives us the normal in view space
  normal = mat3(gbufferModelViewInverse) * normal; // this converts the normal to world/player space
}