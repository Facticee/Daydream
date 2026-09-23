#version 330 compatibility
#include "libs/distort.glsl"

uniform float frameTimeCounter;
uniform vec3 cameraPosition;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform mat4 gbufferModelViewInverse;

in vec4 mc_Entity;
out vec2 texcoord;
out vec2 lmcoord;
out vec4 glcolor;
out float isWater;
out vec3 worldPos;
out vec4 shadowCoord;

void main() {
	texcoord = gl_MultiTexCoord0.st;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).st;
	glcolor = gl_Color;

	int blockID = int(mc_Entity.x + 0.5);
	isWater = (blockID == 10033 || blockID == 10034) ? 1.0 : 0.0;

	vec4 viewPos = gl_ModelViewMatrix * gl_Vertex;
	worldPos = viewPos.xyz + cameraPosition;

	if (isWater > 0.5) {
		vec3 p = gl_Vertex.xyz + cameraPosition;
		float wave = sin(p.x * 1.20 + frameTimeCounter * 2.50) * 0.05;
		wave += sin(p.z * 1.40 + frameTimeCounter * 2.90) * 0.045;
		wave += sin((p.x + p.z) + frameTimeCounter * 2.10) * 0.030;
		viewPos.y += wave;
		worldPos.y += wave;
	}

	gl_Position = gl_ProjectionMatrix * viewPos;
	shadowCoord = shadowProjection * shadowModelView * gbufferModelViewInverse * viewPos;

	shadowCoord.xyz = warpShadowClipPos(shadowCoord.xyz);
	shadowCoord.xyz = shadowCoord.xyz * 0.5 + 0.5;
}