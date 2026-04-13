#version 330 compatibility

#include "/lib/common.glsl"

#include "lib/coordinateSpaceTransform.glsl"
#include "/programs/wavingBlocks.glsl"


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
	if(distance(clipPos.xyz, gl_ModelViewMatrix) > waveRenderDistance * 16) return;
	#ifdef Waves
		if(mc_Entity.y == 1.0){
			vec3 worldPos = clipToWorld(clipPos);
			worldPos.y = getWindOffset(worldPos, 50.0).y;
			clipPos = worldToClip(worldPos);
		}
		gl_Position = clipPos;
	#endif
}