#version 330 compatibility

uniform sampler2D gtexture;
in vec2 texcoord;

void main() {

    if (texture(gtexture, texcoord).a < 0.10) discard;
}
