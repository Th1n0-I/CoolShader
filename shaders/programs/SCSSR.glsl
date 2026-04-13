//////////////////////////////////////////////
//!Super Cool Screen Space Reflection by Thino
//////////////////////////////////////////////
#ifdef FRAGMENT_SHADER

//? Settings
const float maxDistance = 100; //? The furthest distance the ray is allowed to travel. Increasing the value can improve the quality but may decrease performance.
const float stepSize = 10; //? The amount of pixels to travel between each depth check. Increasing the value can improve the performance but may decrease quality.
const int maxSteps = 10; //? The highest amount of steps / loops the program is allowed to make.

//! Getting Variables

vec2 screenSize = vec2(viewWidth, viewHeight); //? The size of the screen in pixels.

//? The rays start and end position in viewspace.
vec3 startViewPos = viewPos;
vec3 endViewPos = viewPos + reflectedViewDir * maxDistance;

//? The rays start and end position in pixel coordinates.
vec3 startFragPos = vec3(texcoord * screenSize, texture(depthtex0, texcoord).r);
vec3 endFragPos = (projectAndDivide(gbufferProjection, endViewPos) * 0.5 + 0.5);
endFragPos.xy *= screenSize;

vec3 delta = vec3(endFragPos.x - startFragPos.x, endFragPos.y - startFragPos.y, endFragPos.z - startFragPos.z); //? The change in pixel position between the two positions.
float biggerDelta = max(abs(delta.x), abs(delta.y)); //? Seeing which delta is bigger to use that for calculations.
delta /= biggerDelta; //? making the biggest delta 1 so it can be used pixel by pixel in a loop.

vec3 currentFragPos = startFragPos;
vec3 currentUV = vec3(startFragPos.xy / screenSize, startFragPos.z);

//! Calculations :(

for(int i = 0; i < min(int(biggerDelta), maxSteps * stepSize); i + stepSize){
    //? Getting the pixel and UV position of the ray.
    currentFragPos.xyz += delta * stepSize;
    currentUV = vec3(currentFragPos.xy / screenSize, currentFragPos.z);

    //? Out of bound check.
    if(currentUV.x < 0.0 || currentUV.x > 1.0 || currentUV.y < 0.0 || currentUV.y > 1.0) break;

    //? Getting the depth of the ray.
    vec3 rayNdcPos = currentUV * 2.0 - 1.0;
    vec3 rayViewPos = projectAndDivide(gbufferProjectionInverse, rayNdcPos);

    //? Getting the depth of the block on screen
    vec3 blockNdcPos = vec3(currentUV.xy, texture(depthtex0, currentUV.xy).r) * 2.0 - 1.0;
    vec3 blockViewPos = projectAndDivide(gbufferProjectionInverse, blockNdcPos);

    //? Check if the ray has collided with the block, and if it has, set the color of the feagment to the color of the block the ray hit.
    if(rayViewPos.z < blockViewPos.z && blockViewPos.z - rayViewPos.z < 0.1){
        color = texture(colortex0, currentUV.xy);
        break;
    }
}

#endif

