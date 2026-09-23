#version 330 compatibility
#include "libs/distort.glsl"

in vec2 texcoord;

uniform sampler2D colortex0, colortex1, colortex2;
uniform sampler2D depthtex0, depthtex1, depthtex2;
uniform sampler2D shadowtex0, shadowtex1, shadowcolor0, noisetex;

uniform vec3 shadowLightPosition;
uniform mat4 gbufferModelViewInverse, gbufferProjectionInverse;
uniform mat4 shadowModelView, shadowProjection;
uniform int worldTime;
uniform float viewWidth, viewHeight;

const float shadowDistance = 144.0;
const int PCF_RANGE = 2;
const float PCF_RADIUS = 0.6;

layout(location = 0) out vec4 color;

vec3 sh(vec3 p) {
	if (p.z <= texture(shadowtex0, p.xy).r) return vec3(1.0);
	if (p.z > texture(shadowtex1, p.xy).r) return vec3(0.0);
	vec4 c = texture(shadowcolor0, p.xy);
	return c.rgb * (1.0 - c.a);
}

vec3 pcf(vec4 clip) {
	ivec2 s = ivec2(texcoord * vec2(viewWidth, viewHeight)) % 64;
	float a = texelFetch(noisetex, s, 0).r * 6.2831853;
	mat2 r = mat2(cos(a), -sin(a), sin(a), cos(a));
	vec3 sum = vec3(0.0);
	float n = 0.0;

	for (int x = -PCF_RANGE; x <= PCF_RANGE; x++) {
		for (int y = -PCF_RANGE; y <= PCF_RANGE; y++) {
			vec4 p = clip + vec4(r * (vec2(x, y) * (PCF_RADIUS / 8092.0)), -0.004, 0.0);
			p.xyz = warpShadowClipPos(p.xyz);
			p.xyz = p.xyz / p.w * 0.5 + 0.5;
			if (all(greaterThanEqual(p.xy, vec2(0.0))) && all(lessThanEqual(p.xy, vec2(1.0)))) {
				sum += sh(p.xyz);
				n += 1.0;
			}
		}
	}

	return n > 0.0 ? sum / n : vec3(1.0);
}

vec3 shadow(vec3 pos) {
	vec4 clip = shadowProjection * shadowModelView * vec4(pos, 1.0);
	vec3 p = warpShadowClipPos(clip.xyz) / clip.w * 0.5 + 0.5;
	float edge = clamp(min(min(p.x, 1.0 - p.x), min(p.y, 1.0 - p.y)) * 8.0, 0.0, 1.0);
	if (edge <= 0.0) return vec3(1.0);
	float fade = clamp(1.0 - length(pos.xz) / shadowDistance, 0.0, 1.0);
	return mix(vec3(1.0), pcf(clip), edge * fade);
}

void main() {
	vec4 albedo = texture(colortex0, texcoord);
	float d0 = texture(depthtex0, texcoord).r;
	float d1 = texture(depthtex1, texcoord).r;
	float d2 = texture(depthtex2, texcoord).r;

	// Hier wurde der Fix kompakt integriert:
	if (d0 == 1.0 || d0 != d2) {
		color = albedo;
		return;
	}
	if (d0 < min(d1, d2)) {
		color = vec4(albedo.rgb, 1.0);
		return;
	}

	vec2 lm = texture(colortex1, texcoord).rg;
	vec3 n = normalize(texture(colortex2, texcoord).rgb * 2.0 - 1.0);
	bool day = worldTime <= 12700 || worldTime >= 22900;
	vec3 lightDir = normalize(mat3(gbufferModelViewInverse) * shadowLightPosition);

	vec4 viewPos = gbufferProjectionInverse * vec4(vec3(texcoord, d0) * 2.0 - 1.0, 1.0);
	viewPos /= viewPos.w;
	vec3 pos = (gbufferModelViewInverse * viewPos).xyz;

	vec3 shadowCol = day ? shadow(pos) : vec3(1.0);
	float sun = day ? clamp(dot(lightDir, n), 0.0, 1.0) : 0.0;

	// Beleuchtung berechnen
	vec3 lighting = lm.y * (vec3(0.3, 0.42, 0.55) + vec3(1.0, 0.92, 0.78) * sun * shadowCol)
	+ vec3(1.0, 0.6, 0.3) * lm.x * lm.x + 0.03;

	color = vec4(albedo.rgb * lighting, 1.0);
}