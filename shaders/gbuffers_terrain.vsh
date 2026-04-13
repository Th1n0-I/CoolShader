#version 330 compatibility

#include "/lib/common.glsl"


out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;
out vec3 normal;
out vec3 tangent;
out vec3 bitangent;

uniform int worldTime;
uniform vec4 at_tangent;

in vec2 mc_Entity;
in vec2 mc_midTexCoord;

#include "/lib/coordinateSpaceTransform.glsl"
#include "/programs/wavingBlocks.glsl"


void main() {
  gl_Position = ftransform();
  vec4 clipPos = ftransform();
  texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
  lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
  glcolor = gl_Color;
  normal = (gl_NormalMatrix * gl_Normal); // this gives us the normal in view space
  normal = mat3(gbufferModelViewInverse) * normal; // this converts the normal to world/player space
  tangent = normalize(gl_NormalMatrix * at_tangent.xyz);
  tangent = mat3(gbufferModelViewInverse) * tangent;
  bitangent = cross(normal, tangent) * at_tangent.w;

  if(distance(ftransform().xyz, gl_ModelViewMatrix) > windRenderDistance * 16) return;
  #ifdef doWind
  if(mc_Entity.x == 10001 || (mc_Entity.x == 10002 && mc_midTexCoord.y > texcoord.y)|| (mc_Entity.x == 10003 && mc_midTexCoord.y < texcoord.y) || (mc_Entity.x == 10005 && mc_midTexCoord.y > texcoord.y)){
    vec3 worldPos = clipToWorld(clipPos);
	  worldPos = getWindOffset(worldPos, 50.0);
    clipPos = worldToClip(worldPos);
  } else if ((mc_Entity.x == 10004 && mc_midTexCoord.y > texcoord.y) || (mc_Entity.x == 10005 && mc_midTexCoord.y < texcoord.y)){
    vec3 worldPos = clipToWorld(clipPos);
	  worldPos = getWindOffset(worldPos, 50.0);
    clipPos = worldToClip(worldPos);
  }
  #endif
	gl_Position = clipPos;
}