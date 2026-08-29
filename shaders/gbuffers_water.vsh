#version 330 compatibility

uniform float frameTimeCounter;

in vec4 mc_Entity;

out vec2 texcoord;
out vec4 glcolor;
out float isWater;


void main() {
	texcoord = gl_MultiTexCoord0.st;
	glcolor = gl_Color;

	int blockID = int(mc_Entity.x + 0.5);
	isWater = (blockID == 10033 || blockID == 10034) ? 1.0 : 0.0;

	vec4 position = gl_ModelViewMatrix * gl_Vertex;

	if (isWater > 0.5) {
		position.y += (sin(position.x * 2.0 + frameTimeCounter * 1.6) + cos(position.z * 2.0 + frameTimeCounter * 1.5)) * 0.05;
	}
	gl_Position = gl_ProjectionMatrix * position;
}