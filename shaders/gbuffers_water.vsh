#version 330 compatibility

uniform float frameTimeCounter;
uniform vec3 cameraPosition;

in vec4 mc_Entity;

out vec2 texcoord;
out vec4 glcolor;
out float isWater;
out vec3 worldPos;
out vec4 shadowCoord;

void main() {
	texcoord = gl_MultiTexCoord0.st;
	glcolor = gl_Color;

	int blockID = int(mc_Entity.x + 0.5);
	isWater = (blockID == 10033 || blockID == 10034) ? 1.0 : 0.0;

	vec4 viewPos = gl_ModelViewMatrix * gl_Vertex;
	worldPos = viewPos.xyz + cameraPosition;

	if (isWater > 0.5) {

		vec3 wavePos = gl_Vertex.xyz + cameraPosition;
		wavePos = floor(wavePos * 16.0) / 16.0;
		float wave = sin(wavePos.x * 1.5 + frameTimeCounter * 2.0) * 0.08 +
		cos(wavePos.z * 1.5 + frameTimeCounter * 1.8) * 0.08;

		viewPos.y += wave;
		worldPos.y += wave;
	}

	gl_Position = gl_ProjectionMatrix * viewPos;
}