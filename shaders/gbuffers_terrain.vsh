#version 330 compatibility

out vec2 texcoord;
out vec2 lmcoord;
out vec4 glcolor;
out vec3 normal;

uniform mat4 gbufferModelViewInverse;

void main() {
	texcoord = gl_MultiTexCoord0.st;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).st;
	glcolor = gl_Color;
	normal = mat3(gbufferModelViewInverse) * (gl_NormalMatrix * gl_Normal);
	gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
}
