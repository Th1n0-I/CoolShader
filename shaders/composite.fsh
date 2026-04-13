#version 330 compatibility

#include "/lib/common.glsl"

#include "/lib/shadowDistort.glsl"
#include "/lib/coordinateSpaceTransform.glsl"

#define FRAGMENT_SHADER



uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D depthtex0;
uniform sampler2D colortex3;

uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;
uniform sampler2D noisetex;

uniform sampler2D normals;

// const int colortex0Format = RGB16F;
// const int colortex4Format = RGB16F;

uniform vec3 shadowLightPosition;


uniform int worldTime;
uniform int blockEntityId;

uniform float viewWidth;
uniform float viewHeight;
uniform float sunAngle;

uniform float far;

const int noiseTextureResolution = 256;

const vec3 blocklightColor = vec3(1.0, 0.5, 0.08);
const vec3 skylightColor = vec3(0.05, 0.15, 0.3);
const vec3 sunlightColor = vec3(4.0, 2.5, 0);
const vec3 moonlightColor = vec3(0.1, 0.12, 0.2);
const vec3 ambientColor = vec3(0.1);


#define SHADOW_RADIUS 2
#define SHADOW_RANGE 6

in vec2 texcoord;

/* RENDERTARGETS: 0,4 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 brightColor;

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
	float depth = texture(depthtex0, texcoord).r;
	vec3 ndcPos = vec3(texcoord.xy, depth) * 2.0 - 1.0;
	vec3 viewPos = projectAndDivide(gbufferProjectionInverse, ndcPos);
	vec3 viewDir = normalize(viewPos);
	vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
	vec3 feetDir = normalize(feetPlayerPos);
	vec3 worldPos = feetPlayerPos + cameraPosition;

	vec2 lightmap = texture(colortex1, texcoord).xy;
   	vec3 encodedNormal = texture(colortex2, texcoord).rgb;
  	vec3 normal = normalize((encodedNormal - 0.5) * 2.0);
	vec3 viewNormal = normalize(mat3(gbufferModelView) * normal);
	vec3 lightVector = normalize(shadowLightPosition);
	vec3 worldLightVector = mat3(gbufferModelViewInverse) * lightVector;

	vec3 reflectedViewDir = reflect(viewDir, viewNormal);
	vec3 reflectedFeetDir = reflect(feetDir, normal);

	color = texture(colortex0, texcoord);
	color.rgb = pow(color.rgb, vec3(2.2));

	if(depth == 1.0) {
		return;
	}

	float arcAmount;
	if(worldTime >= 23725 || worldTime <= 12785) {
    	float sunTime = float(worldTime) - 23725.0;
    if(sunTime < 0.0) sunTime += 24000.0;
    	arcAmount = sin(sunTime / 13060.0 * 3.14159) * 0.5;
	} else {
    	float moonTime = float(worldTime) - 12785.0;
    	arcAmount = sin(moonTime / 10940.0 * 3.14159) * 0.5;
	}
	vec3 dir = normalize(worldLightVector);
	dir.z -= arcAmount;
	worldLightVector = normalize(dir);

	arcAmount;
	if(worldTime >= 23725 || worldTime <= 12785) {
    float sunTime = float(worldTime) - 23725.0;
    if(sunTime < 0.0) sunTime += 24000.0;
    	arcAmount = sin(sunTime / 13060.0 * 3.14159) * 0.5; // 0.5 = arc strength
	} else {
    	float moonTime = float(worldTime) - 12785.0;
    	arcAmount = sin(moonTime / 10940.0 * 3.14159) * 0.5;
	}
	float len = length(worldPos);
	dir = normalize(worldPos);
	dir.z += arcAmount;
	dir = normalize(dir);
	vec3 sunWorldPos = dir * len;

	vec3 sunFeetPlayerPos = sunWorldPos - cameraPosition;
 	vec3 shadowViewPos = (shadowModelView * vec4(sunFeetPlayerPos, 1.0)).xyz;
 	vec4 shadowClipPos = shadowProjection * vec4(shadowViewPos, 1.0);

	vec3 shadow = getSoftShadow(shadowClipPos);


	vec3 blocklight = lightmap.x * blocklightColor;
	vec3 skylight = lightmap.y * skylightColor;
	vec3 ambient = ambientColor;
	vec3 sunlight = getSunlightColor() * clamp(dot(worldLightVector, normal), 0.0, 1.0) * shadow;
	color.rgb *= blocklight + skylight + ambient + sunlight;
	#ifdef UseSpecularMaps
		vec3 spec = texture(colortex3, texcoord).rgb;
		float sunReflectionScore = pow(max(dot(reflectedFeetDir, worldLightVector),0), 20.0);
		color.rgb += spec.r * getSunlightColor() * shadow * sunReflectionScore * 0.5;
		#ifdef ScreenSpaceReflections
			if(distance((gbufferProjection * vec4(viewPos.xyz, 1.0)).xyz, gl_ModelViewMatrix) < 16 && spec.g >= 1){
				#include "/programs/SCSSR.glsl"
			}
		#endif
	#endif



	if (DebugMode == 1) color.rgb = viewNormal;
	else if (DebugMode == 2) color.rgb = shadow;
	else if (DebugMode == 3) {
		#ifdef UseSpecularMaps
			color.rgb = spec;
		#endif
	}
	else if (DebugMode == 4) color.rgb = viewPos;
	else if (DebugMode == 5) color.rgb = viewDir;
	else if (DebugMode == 6) color.rgb = reflectedViewDir;
	float brightness = dot(color.rgb, vec3(0.216, 0.715, 0.0722));
	if (brightness > 1.0){
		brightColor = vec4(color.rgb, 1.0);
	} else {
		brightColor = vec4(0);
	}

}