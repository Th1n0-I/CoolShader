const float weights[5] = float[](0.227, 0.194, 0.122, 0.054, 0.016);

vec2 pixel;
if(horizontal == true) pixel = vec2(1.0/viewWidth, 0.0);
else pixel = vec2(0.0, 1.0/viewHeight);

vec3 result = texture(colortex4, texcoord).rgb * weights[0];

for(int i = 1; i < 5; i++){
    result += texture(colortex4, texcoord + pixel * i).rgb * weights[i];
    result += texture(colortex4, texcoord - pixel * i).rgb * weights[i];
}
