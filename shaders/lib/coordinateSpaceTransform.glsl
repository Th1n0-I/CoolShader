uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferProjection;

uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferModelView;

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