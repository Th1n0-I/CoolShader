

#include "/lib/common.glsl"

#ifdef VERTEX_SHADER

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;
out vec3 normal;
out vec3 tangent;
out vec3 bitangent;


uniform vec4 at_tangent;


in vec2 mc_midTexCoord;

#include "/lib/coordinateSpaceTransform.glsl"


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
}

#endif

#ifdef FRAGMENT_SHADER

uniform sampler2D gtexture;
uniform sampler2D normals;
uniform sampler2D specular;
uniform float alphaTestRef = 0.1;



in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;
in vec3 normal;
in vec3 tangent;
in vec3 bitangent;


/* RENDERTARGETS: 0,1,2,3 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 lightLevelData;
layout(location = 2) out vec4 encodedNormal;
layout(location = 3) out vec4 Specular;

void main() {
    color = texture(gtexture, texcoord) * glcolor;

    lightLevelData = vec4(lmcoord, 0.0, 1.0);

    #ifdef UseNormalMaps
        vec3 mapNormal = texture(normals, texcoord).rgb * 2.0 -1.0;
        mapNormal = normalize(mapNormal);
        mat3 TBN = mat3(tangent, bitangent, normal);
        vec3 worldNormal = normalize(TBN * mapNormal);
    #else
        vec3 worldNormal = normal;
    #endif
    encodedNormal = vec4(worldNormal * 0.5 + 0.5, 1.0);

    Specular = texture(specular, texcoord);

    if (color.a < alphaTestRef) {
        discard;
    }
 }

#endif