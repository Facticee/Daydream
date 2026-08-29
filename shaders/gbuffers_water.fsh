#version 330 compatibility

uniform sampler2D lightmap;
uniform sampler2D gtexture;
uniform sampler2D shadowtex0;

uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;
in vec4 shadowCoord;
in float isWater;

out vec4 fragColor;

void main() {
	vec4 albedo = texture(gtexture, texcoord) * glcolor;

	if (isWater > 0.5) {

		albedo.rgb = texture(gtexture, texcoord).rgb * glcolor.rgb;

		float shadow = 1.0;
		shadow = texture(shadowtex0, shadowCoord.st).r;
		albedo.rgb *=mix(0.5, 1.0, shadow);

		albedo.a = 0.75;
	}
	fragColor = albedo;
}