#version 330 compatibility

#include "lib/coordinateSpaceTransform.glsl"

in vec2 mc_Entity;

 out vec2 lmcoord;
 out vec2 texcoord;
 out vec4 glcolor;
 out vec3 normal;

 uniform int worldTime;

void main() {
	vec4 clipPos = ftransform();
	if (mc_Entity.y == 1.0){
		vec3 worldPos = clipToWorld(ftransform());
		worldPos.y += (sin(worldPos.x*0.1 + worldTime*0.06) + sin(worldPos.z*0.2 + worldTime*0.04))*0.02;
		clipPos = worldToClip(worldPos);
	}

	gl_Position = clipPos;

  	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
  	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
  	glcolor = gl_Color;

  	normal = gl_NormalMatrix * gl_Normal;
   	normal = mat3(gbufferModelViewInverse) * normal;
}