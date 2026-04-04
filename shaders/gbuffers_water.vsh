#version 330 compatibility

#include "lib/coordinateSpaceTransform.glsl"
#include "lib/noise.glsl"

#define Waves // Turn on water waves, can be turned off for better performance
#define waveHeight 1 // [0.5 0.6 0.7 0.8 0.9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 3 4 5 6 7 8 9 10 100] Change the height of the waves, WARNING: values above 1 can cause visual glitches, use with caution
#define waveSpeed 1 // [0.5 0.6 0.7 0.8 0.9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 3 4 5 6 7 8 9 10 100] Change the speed of the waves, use with caution as high values can cause visual glitches
#define waveQuality 1024 // [64 128 256 512 1024 2048 4096 8192]
#define waveRenderDistance 8// [2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32]

in vec2 mc_Entity;

 out vec2 lmcoord;
 out vec2 texcoord;
 out vec4 glcolor;
 out vec3 normal;

 uniform int worldTime;

void main() {
	vec4 clipPos = ftransform();
	gl_Position = clipPos;

  	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
  	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
  	glcolor = gl_Color;

  	normal = gl_NormalMatrix * gl_Normal;
   	normal = mat3(gbufferModelViewInverse) * normal;
	if(distance(ftransform().xyz, gl_ModelViewMatrix) > waveRenderDistance * 16) return;
	#ifdef Waves
		if(mc_Entity.y == 1.0){
			vec3 worldPos = clipToWorld(clipPos);
			worldPos.y += min(pNoise(worldPos.xz * 100 + vec2(worldTime*waveSpeed, worldTime*waveSpeed),waveQuality)*waveHeight,0.1);
			clipPos = worldToClip(worldPos);
		}
		gl_Position = clipPos;
	#endif
}