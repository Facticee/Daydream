#version 330 compatibility

uniform sampler2D lightmap;
uniform sampler2D gtexture;
uniform vec4 entityColor;

uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;
in vec3 normal;

/* RENDERTARGETS: 0,1,2 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 lmdata;
layout(location = 2) out vec4 normalData;

void main() {
	color = texture(gtexture, texcoord) * glcolor;
	color.rgb = mix(color.rgb, entityColor.rgb, entityColor.a);
	if (color.a < alphaTestRef) {
		discard;
	}

	lmdata = vec4(lmcoord, 0.0, 0.0);
	normalData = vec4(normal * 0.5 + 0.5, 1.0);
}