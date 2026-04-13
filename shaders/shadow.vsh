#version 330 compatibility

#include "/lib/common.glsl"

#include "/lib/shadowDistort.glsl"
#include "/lib/coordinateSpaceTransform.glsl"
#include "/programs/wavingBlocks.glsl"

out vec2 texcoord;
out vec4 glcolor;

uniform int worldTime;
uniform float sunAngle;

in vec2 mc_Entity;
in vec2 mc_midTexCoord;

void main() {
  vec4 clipPos = ftransform();
  vec3 worldPos = shadowClipToWorld(clipPos);

  float arcAmount;
	if(worldTime >= 23725 || worldTime <= 12785) {
    float sunTime = float(worldTime) - 23725.0;
    if(sunTime < 0.0) sunTime += 24000.0;
    	arcAmount = sin(sunTime / 13060.0 * 3.14159) * 0.5; // 0.5 = arc strength
	} else {
    	float moonTime = float(worldTime) - 12785.0;
    	arcAmount = sin(moonTime / 10940.0 * 3.14159) * 0.5;
	}
	float len = length(worldPos);
	vec3 dir = normalize(worldPos);
	dir.z += arcAmount;
	dir = normalize(dir);
	worldPos = dir * len;

  texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
  glcolor = gl_Color;
  #ifdef wind
  if(shadowDistance(ftransform()) < windRenderDistance * 16){
    if(mc_Entity.x == 10001 || (mc_Entity.x == 10002 && mc_midTexCoord.y > texcoord.y)|| (mc_Entity.x == 10003 && mc_midTexCoord.y < texcoord.y) || (mc_Entity.x == 10005 && mc_midTexCoord.y > texcoord.y)){
      worldPos = getWindOffset(worldPos, 50.0);
    } else if ((mc_Entity.x == 10004 && mc_midTexCoord.y > texcoord.y) || (mc_Entity.x == 10005 && mc_midTexCoord.y < texcoord.y)){
      worldPos = getWindOffset(worldPos, 50.0);
    }
  }
  #endif
  #ifdef Waves
    if(shadowDistance(ftransform()) < waveRenderDistance * 16){
      if(mc_Entity.y == 1.0){
        worldPos.y = getWindOffset(worldPos, 50.0).y;
		  }
    }
	#endif
  clipPos = worldToShadowClip(worldPos);

	gl_Position = clipPos;
  gl_Position.xyz = distortShadowClipPos(gl_Position.xyz);
}