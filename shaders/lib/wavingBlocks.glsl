uniform float frameTimeCounter;


vec3 getWindOffset(vec3 worldPos, float wind){
    float time = frameTimeCounter * wind;

    float mag = sin(time * 0.0012) * 0.02 + 0.02;

    float d1 = sin(time * 0.0023);
    float d2 = sin(time * 0.0126);
    float d3 = sin(time * 0.0185);

    worldPos.x += sin(time * 0.0093 + d2 + d3 + worldPos.x - worldPos.z + worldPos.y) * mag;
    worldPos.y += sin(time * 0.0184 + d3 + d1 + worldPos.x - worldPos.z) * mag;
    worldPos.z += sin(time * 0.0234 + d1 + d2 - worldPos.x + worldPos.z + worldPos.y) * mag;

    return worldPos;
}