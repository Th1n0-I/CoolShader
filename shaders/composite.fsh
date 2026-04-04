#version 330 compatibility

#include "/lib/shadowDistort.glsl"
#include "/lib/coordinateSpaceTransform.glsl"

//#define debugNormals  // For debugging: render normals instead of the final color
//#define debugShadow  // For debugging: visualize shadow factor
//#define debugSunPos // For debugging: visualize sun position
//#define debugShadowTex // For debugging: Visualize shadowTex
//#define debugNoisetex // For debugging: Visualize noisetex

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D depthtex0;
uniform sampler2D colortex3;

uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;
uniform sampler2D noisetex;

// const int colortex0Format = RGB16;

uniform vec3 shadowLightPosition;


uniform int worldTime;
uniform int blockEntityId;

uniform float viewWidth;
uniform float viewHeight;
uniform float sunAngle;

const int noiseTextureResolution =256;

const vec3 blocklightColor = vec3(1.0, 0.5, 0.08);
const vec3 skylightColor = vec3(0.05, 0.15, 0.3);
const vec3 sunlightColor = vec3(1.0, 0.95, 0.8);
const vec3 moonlightColor = vec3(0.1, 0.12, 0.2);
const vec3 ambientColor = vec3(0.1);


#define SHADOW_RADIUS 2
#define SHADOW_RANGE 6

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

vec3 projectAndDivide(mat4 projectionMatrix, vec3 position){
	vec4 homPos = projectionMatrix * vec4(position, 1.0);
	return homPos.xyz / homPos.w;
}

vec4 getNoise(vec2 coord){
	ivec2 screenCoord = ivec2(coord * vec2(viewWidth, viewHeight));
	ivec2 noiseCoord = screenCoord % noiseTextureResolution;
	return texelFetch(noisetex, noiseCoord, 0);
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

vec3 getSoftShadow(vec4 shadowClipPos){
	float noise = getNoise(texcoord).r;

	float theta = noise * radians(360);
	float cosTheta = cos(theta);
	float sinTheta = sin(theta);

	mat2 rotation = mat2(cosTheta, -sinTheta, sinTheta, cosTheta);

    vec3 shadowAccum = vec3(0.0);
    const int samples = SHADOW_RANGE * SHADOW_RANGE * 4;

    for (int x = -SHADOW_RANGE; x < SHADOW_RANGE; x++){
        for (int y = -SHADOW_RANGE; y < SHADOW_RANGE; y++){
            vec2 offset = vec2(x,y) * SHADOW_RADIUS / float(SHADOW_RANGE);
			offset = rotation * offset;
            offset /= shadowMapResolution;
            vec4 offsetShadowClipPos = shadowClipPos + vec4(offset, 0, 0);
            offsetShadowClipPos.z -= 0.001;
            offsetShadowClipPos.xyz = distortShadowClipPos(offsetShadowClipPos.xyz);
            vec3 shadowNDCPos = offsetShadowClipPos.xyz / offsetShadowClipPos.w;
            vec3 shadowScreenPos = shadowNDCPos * 0.5 + 0.5;
            shadowAccum += getShadow(shadowScreenPos);
        }
    }
    return shadowAccum / float(samples);
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
	vec3 worldPos = feetPlayerPos + cameraPosition;

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

	feetPlayerPos = worldPos - cameraPosition;
 	vec3 shadowViewPos = (shadowModelView * vec4(feetPlayerPos, 1.0)).xyz;
 	vec4 shadowClipPos = shadowProjection * vec4(shadowViewPos, 1.0);

	vec3 shadow = getSoftShadow(shadowClipPos);

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
	#ifdef debugSunPos
	color.rgb = worldLightVector;
	#endif
	#ifdef debugShadowTex
	color = vec4(texture(shadowtex0, texcoord).rgb, 1.0);
	#endif
	#ifdef debugNoisetex
	ivec2 screenCoord = ivec2(texcoord * vec2(viewWidth, viewHeight	));
	ivec2 noiseCoord = screenCoord % 256;
	color = texelFetch(noisetex, noiseCoord, 0);
	#endif
}