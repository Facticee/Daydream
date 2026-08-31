#version 330 compatibility

varying vec2 texcoord;

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D depthtex0;
uniform sampler2D shadowtex0;

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;


uniform vec3 shadowLightPosition;
uniform vec3 sunPosition;
uniform float worldTime;


uniform float shadowDistance = 128.0;
const bool isWater = false;

// settingss

const int	shadowMapResolution = 2048;
const float	sunPathRotation		= -40.0;

float shadowSample(vec3 playerPos, vec3 normal) {

	vec3 offNormal = isWater ? vec3(0.0, 1.0, 0.0) : normal;
	vec3 offset    = isWater ? vec3(0.0) : offNormal * 0.05;

	vec4 sc = shadowProjection * shadowModelView * vec4(playerPos + offset, 1.0);
	sc.xy /= sc.w;
	sc.z -= 0.0004;
	vec3 sp = sc.xyz * 0.5 + 0.5;

	float edge = clamp(min(min(sp.x, 1.0 - sp.x), min(sp.y, 1.0 - sp.y)) * 8.0, 0.0, 1.0);
	if (edge <= 0.0) return 1.0;

	float r = 1.0 / float(shadowMapResolution);
	float shadow = step(sp.z, texture2D(shadowtex0, sp.xy).r) * 0.4
	+ step(sp.z, texture2D(shadowtex0, sp.xy + vec2( r,  r)).r) * 0.15
	+ step(sp.z, texture2D(shadowtex0, sp.xy + vec2(-r,  r)).r) * 0.15
	+ step(sp.z, texture2D(shadowtex0, sp.xy + vec2( r, -r)).r) * 0.15
	+ step(sp.z, texture2D(shadowtex0, sp.xy + vec2(-r, -r)).r) * 0.15;

	float distFade = clamp(1.0 - length(playerPos.xz) / shadowDistance, 0.0, 1.0);
	return mix(1.0, shadow, edge * distFade);
}


void main() {
	vec3 albedo = texture2D(colortex0, texcoord).rgb;
	vec4 data = texture2D(colortex1, texcoord);
	float depth = texture2D(depthtex0, texcoord).r;

	vec4 clip = vec4(texcoord * 2.0 - 1.0, depth * 2.0 - 1.0, 1.0);

	vec4 viewPos = gbufferProjectionInverse * clip;
	viewPos /= viewPos.w;

	vec2 nxy = data.rg * 2.0 - 1.0;
	vec3 normal = normalize(vec3(nxy, sqrt(max(0.0, 1.0 - dot(nxy, nxy)))));
	vec2 lm = data.ba;
	vec3 playerPos = (gbufferModelViewInverse * viewPos).xyz;

	float shadow = shadowSample(playerPos, normal);

	vec3 sunLight = vec3(1.0, 0.92, 0.78) * shadow * lm.y;
	vec3 skyAmbient = vec3(0.3, 0.42, 0.55) * lm.y;
	vec3 blocklight = vec3(1.0, 0.6, 0.3) * lm.x * lm.x;
	vec3 lighting = sunLight + skyAmbient + blocklight + 0.03;

	if (isWater) lighting += vec3(0.02);

	gl_FragData[0] = vec4(albedo * lighting, 1.0);
}