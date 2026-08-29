#version 330 compatibility

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;

uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform mat4 gbufferModelViewInverse;

void main() {
	texcoord = gl_MultiTexCoord0.st;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).st;
	glcolor = gl_Color;

	gl_Position = ftransform();
	vec4 viewPos = gl_ModelViewMatrix * gl_Vertex;
	shadowCoord = shadowProjection * shadowModelView * gbufferModelViewInverse * viewPos;
	shadowCoord.xyz = shadowCoord.xyz * 0.5 + 0.5;
}