#version 330 compatibility

uniform sampler2D gtexture;

in vec2 texcoord;
in vec4 glcolor;

const int shadowMapResolution = 2048; // [1024 2048 4096 8192 16384 32768]

layout(location = 0) out vec4 color;

void main() {
  color = texture(gtexture, texcoord) * glcolor;
  if (color.a < 0.1){
    discard;
  }
}