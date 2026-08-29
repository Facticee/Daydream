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

		float wave = 0.0;
		wave += sin(wavePos.x * 1.2 + frameTimeCounter * 1.6) * 0.07;
		wave += sin(wavePos.z * 1.4 + frameTimeCounter * 1.9) * 0.05;
		wave += sin((wavePos.x + wavePos.z) * 1.0 + frameTimeCounter * 1.1) * 0.04;
		wave += cos((wavePos.x - wavePos.z) * 1.1 + frameTimeCounter * 1.3) * 0.045;
		viewPos.y += wave;
		worldPos.y += wave;
	}

	gl_Position = gl_ProjectionMatrix * viewPos;
}