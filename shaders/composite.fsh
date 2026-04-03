#version 330 compatibility

#include "/lib/shadowDistort.glsl"
#include "/lib/coordinateSpaceTransform.glsl"

//#define debugNormals  // For debugging: render normals instead of the final color
//#define debugShadow  // For debugging: visualize shadow factor

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D depthtex0;
uniform sampler2D colortex3;

uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;

// const int colortex0Format = RGB16;

uniform vec3 shadowLightPosition;

uniform int worldTime;
uniform int blockEntityId;

const vec3 blocklightColor = vec3(1.0, 0.5, 0.08);
const vec3 skylightColor = vec3(0.05, 0.15, 0.3);
const vec3 sunlightColor = vec3(1.0, 0.95, 0.8);
const vec3 moonlightColor = vec3(0.1, 0.12, 0.2);
const vec3 ambientColor = vec3(0.1);

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

vec3 projectAndDivide(mat4 projectionMatrix, vec3 position){
	vec4 homPos = projectionMatrix * vec4(position, 1.0);
	return homPos.xyz / homPos.w;
}

vec3 getShadow(vec3 shadowScreenPos){
   	float transparentShadow = step(shadowScreenPos.z, texture(shadowtex0, shadowScreenPos.xy).r);

   	if (transparentShadow == 1.0){
     	return vec3(1.0);
   	}

   	float opaqueShadow = step(shadowScreenPos.z, texture(shadowtex1, shadowScreenPos.xy).r);
   	if(opaqueShadow == 0.0){
     	return vec3(0.0);
   	}

   	vec4 shadowColor = texture(shadowcolor0, shadowScreenPos.xy);

   	return shadowColor.rgb * (1.0 - shadowColor.a);
}

vec3 getSunlightColor(){
	int blendRange = 250;
	int sunrise = 23725;
	int sunset = 12785;
	if (worldTime >= sunrise + blendRange || worldTime <= sunset - blendRange) {
		return sunlightColor;
	} else if (worldTime >= sunset + blendRange && worldTime <= sunrise - blendRange) {
		return moonlightColor;
	} else if (worldTime > sunrise - blendRange && worldTime < sunrise + blendRange) {
		float t = float(worldTime - (sunrise - blendRange)) / float(2 * blendRange);
		return mix(moonlightColor, sunlightColor, t);
	} else if (worldTime > sunset - blendRange && worldTime < sunset + blendRange) {
		float t = float(worldTime - (sunset - blendRange)) / float(2 * blendRange);
		return mix(sunlightColor, moonlightColor, t);
	}
}

void main() {
	vec2 lightmap = texture(colortex1, texcoord).xy;
   	vec3 encodedNormal = texture(colortex2, texcoord).rgb;
  	vec3 normal = normalize((encodedNormal - 0.5) * 2.0);
	vec3 lightVector = normalize(shadowLightPosition);
	vec3 worldLightVector = mat3(gbufferModelViewInverse) * lightVector;

	color = texture(colortex0, texcoord);
	color.rgb = pow(color.rgb, vec3(2.2));

	float depth = texture(depthtex0, texcoord).r;
	if(depth == 1.0) {
		return;
	}

	vec3 ndcPos = vec3(texcoord.xy, depth) * 2.0 - 1.0; // normalized device coordinates (NDC); [-1.0, 1.0]
 	vec3 viewPos = projectAndDivide(gbufferProjectionInverse, ndcPos); // position in view space
 	vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz; // position relative to the feet of the player
 	vec3 shadowViewPos = (shadowModelView * vec4(feetPlayerPos, 1.0)).xyz;
 	vec4 shadowClipPos = shadowProjection * vec4(shadowViewPos, 1.0);
	shadowClipPos.z -= 0.001;
	shadowClipPos.xyz = distortShadowClipPos(shadowClipPos.xyz);
 	vec3 shadowNdcPos = shadowClipPos.xyz / shadowClipPos.w;
 	vec3 shadowScreenPos = shadowNdcPos * 0.5 + 0.5;

	vec3 shadow = getShadow(shadowScreenPos);

	vec3 blocklight = lightmap.x * blocklightColor;
	vec3 skylight = lightmap.y * skylightColor;
	vec3 ambient = ambientColor;
	vec3 sunlight = getSunlightColor() * clamp(dot(worldLightVector, normal), 0.0, 1.0) * shadow;

	color.rgb *= blocklight + skylight + ambient + sunlight;

	#ifdef debugNormals
	color.rgb = abs(normal);
	#endif
	#ifdef debugShadow
	color.rgb = shadow;
	#endif
}