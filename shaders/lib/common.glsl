#define UseNormalMaps // Use normal maps to give blocks fake depthtex0
//#define debugNormals  // For debugging: render normals instead of the final color

#define UseSpecularMaps // Use specular maps to give blocks different lighting properties
//#define debugSpecular // For debugging: visualize specular maps

#define doWind //foliage wawing in the wind
#define windSpeed 1 // [0.5 0.6 0.7 0.8 0.9 1 1.1 1.2 1.3 1.4 1.5 1.75 2.0 3.0 4.0 5.0 10 100] How fast the wind blows
#define windStrength 1// [0.5 0.6 0.7 0.8 0.9 1 1.1 1.2 1.3 1.4 1.5 1.75 2.0 3.0 4.0 5.0 10 100] How strong the wind is
#define windRenderDistance 8// [2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32]

#define Waves // Turn on water waves, can be turned off for better performance
#define waveHeight 1 // [0.5 0.6 0.7 0.8 0.9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 3 4 5 6 7 8 9 10 100] Change the height of the waves, WARNING: values above 1 can cause visual glitches, use with caution
#define waveSpeed 1 // [0.5 0.6 0.7 0.8 0.9 1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 3 4 5 6 7 8 9 10 100] Change the speed of the waves, use with caution as high values can cause visual glitches
#define waveRenderDistance 8// [2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32]

#define DebugMode 0// [0 1 2 3 4 5 6]

#define HDR
#define Bloom
#define ScreenSpaceReflections

#define Fog
#define FogDistance 5// [1 2 3 4 5 6 7 8 9 10]


vec3 projectAndDivide(mat4 projectionMatrix, vec3 position){
	vec4 homPos = projectionMatrix * vec4(position, 1.0);
	return homPos.xyz / homPos.w;
}

vec3 reflectAroundPoint(vec3 vector, vec3 worldPos, vec3 normal){
    vec3 reflection = (2 * ((vector - worldPos) * normal) * normal - (vector - worldPos)) + worldPos;
    return reflection;
}
