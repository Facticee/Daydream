#version 330 compatibility

out vec2 texcoord;
out vec2 lmcoord;
out vec4 glcolor;
out vec4 shadowCoord;

uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform mat4 gbufferModelViewInverse;

void main() {
	texcoord = gl_MultiTexCoord0.st;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).st;
	glcolor = gl_Color;
	vec4 viewPos = gl_ModelViewMatrix * gl_Vertex;
	gl_Position = gl_ProjectionMatrix * viewPos;
	shadowCoord = shadowProjection * shadowModelView * gbufferModelViewInverse * viewPos;
	shadowCoord.xyz = shadowCoord.xyz * 0.5 + 0.5;
}
