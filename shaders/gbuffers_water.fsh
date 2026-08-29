#version 330 compatibility

uniform sampler2D lightmap;
uniform sampler2D gtexture;

uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;

in float isWater;

out vec4 fragColor;

void main() {
	vec4 albedo = texture(gtexture, texcoord) * glcolor;

	if (isWater > 0.5) {
		albedo.rgb = mix(albedo.rgb, vec3(0.1, 0.4, 0.8), 0.6);
		albedo.a = 0.75;
	}
	fragColor = albedo;
}