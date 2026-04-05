#version 330 compatibility

uniform sampler2D gtexture;
uniform sampler2D normals;
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

void main() {
  color = texture(gtexture, texcoord) * glcolor;

   lightLevelData = vec4(lmcoord, 0.0, 1.0);

   vec3 mapNormal = texture(normals, texcoord).rgb * 2.0 -1.0;
   mapNormal.xy *= 1000.0;
   mapNormal = normalize(mapNormal);
   mat3 TBN = mat3(tangent, bitangent, normal);
   vec3 worldNormal = normalize(TBN * mapNormal);
   encodedNormal = vec4(worldNormal * 0.5 + 0.5, 1.0);

    if (color.a < alphaTestRef) {
        discard;
    }
 }