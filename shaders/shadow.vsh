#version 330 compatibility
#include "libs/distort.glsl"

out vec2 texcoord;
out vec4 glcolor;

void main() {
    gl_Position = ftransform();
    gl_Position.xyz = warpShadowClipPos(gl_Position.xyz);
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    glcolor = gl_Color;
}
