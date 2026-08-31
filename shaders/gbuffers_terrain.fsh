#version 330 compatibility

uniform sampler2D lightmap;
uniform sampler2D gtexture;
uniform sampler2DShadow shadowtex0;

uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;
in vec4 shadowCoord;

out vec4 fragColor;

void main() {
	vec4 albedo = texture(gtexture, texcoord) * glcolor;
	if (albedo.a < 0.1) discard;

	float shadow = texture(shadowtex0, shadowCoord.xyz);
	float shade = mix(0.68, 1.0, shadow);
	vec3 light = texture(lightmap, lmcoord).rgb; // dark fix

	fragColor = vec4(albedo.rgb * light * shade, albedo.a);
}