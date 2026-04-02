#version 330 compatibility

#define wind //foliage wawing in the wind, can be disabled for better performance
#define windSpeed 1 // [0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.75 2.0 3.0 4.0 5.0 10 100] How fast the wind blows
#define windStrength 1// [0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.75 2.0 3.0 4.0 5.0 10 100] How strong the wind is

 out vec2 lmcoord;
 out vec2 texcoord;
 out vec4 glcolor;
 out vec3 normal;

 uniform int worldTime;
 in vec2 mc_Entity;

 #include "lib/coordinateSpaceTransform.glsl"
 #include "lib/noise.glsl"

 // Remember uniforms from before? This is calculated on the CPU, and available for any program!
 // We just tell GLSL we want to use this uniform. It always exists, no matter if we define it here.


void main() {
  vec4 clipPos = ftransform();
  #ifdef wind
  if(mc_Entity.x == 10005.0){
	    vec3 worldPos = clipToWorld(clipPos);
	    worldPos.x += pNoise(worldPos.xy + vec2(worldTime * windSpeed, worldTime * windSpeed),512) * windStrength;
      worldPos.z += pNoise(worldPos.zy + vec2(worldTime * windSpeed, worldTime * windSpeed),512) * windStrength;
      clipPos = worldToClip(worldPos);
  }
  #endif
	gl_Position = clipPos;
  texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
  lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
  glcolor = gl_Color;

   normal = gl_NormalMatrix * gl_Normal; // this gives us the normal in view space
   normal = mat3(gbufferModelViewInverse) * normal; // this converts the normal to world/player space
}