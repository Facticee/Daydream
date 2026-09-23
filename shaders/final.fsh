#version 330 compatibility

uniform sampler2D colortex0;
uniform float frameTimeCounter;

varying vec2 texcoord;

const float VIBRANCY = 1.5;
const float CONTRAST = 1.1;

float lumaF(vec3 c) {
    return dot(c, vec3(0.2126, 0.7152, 0.0722));
}

float hashF(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void main() {
    vec3 color = texture2D(colortex0, texcoord).rgb;
    color = mix(vec3(lumaF(color)), color, VIBRANCY);
    color = (color - 0.5) * CONTRAST + 0.5;
    vec2 v = texcoord - 0.5;
    color *= 1.0 - dot(v, v) * 0.35;
    color += (hashF(texcoord + fract(frameTimeCounter)) - 0.5) / 255.0;
    gl_FragColor = vec4(color, 1.0);
}