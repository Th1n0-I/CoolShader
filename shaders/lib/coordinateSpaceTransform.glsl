uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferProjection;

uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferModelView;

uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform mat4 shadowModelViewInverse;
uniform mat4 shadowProjectionInverse;

uniform vec3 cameraPosition;

vec3 clipToWorld(vec4 clipPos){
    vec3 viewPos = (gbufferProjectionInverse * clipPos).xyz;
    vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
    vec3 worldPos = feetPlayerPos + cameraPosition;
    return worldPos;
}

vec4 worldToClip(vec3 worldPos){
    vec3 feetPlayerPos = worldPos - cameraPosition;
    vec3 viewPos = (gbufferModelView * vec4(feetPlayerPos, 1.0)).xyz;
    vec4 clipPos = gbufferProjection * vec4(viewPos, 1.0);
    return clipPos;
}

vec3 shadowClipToWorld(vec4 shadowClipPos){
    vec3 shadowViewPos = (shadowProjectionInverse * shadowClipPos).xyz;
    vec3 feetPlayerPos = (shadowModelViewInverse * vec4(shadowViewPos, 1.0)).xyz;
    vec3 worldPos = feetPlayerPos + cameraPosition;
    return worldPos;
}

vec4 worldToShadowClip(vec3 worldPos){
    vec3 feetPlayerPos = worldPos - cameraPosition;
    vec3 shadowViewPos = (shadowModelView * vec4(feetPlayerPos, 1.0)).xyz;
    vec4 shadowClipPos = shadowProjection * vec4(shadowViewPos, 1.0);
    return shadowClipPos;
}

float distance(vec3 modelPos, mat4 ModelViewMatrix){
    vec3 viewPos = (ModelViewMatrix * vec4(modelPos, 1.0)).xyz;
    vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
    float dist = length(feetPlayerPos);
    return dist;
}

float shadowDistance(vec4 clipPos){
    vec3 shadowViewPos = (shadowProjectionInverse * clipPos).xyz;
    float dist = length(shadowViewPos);
    return dist;
}