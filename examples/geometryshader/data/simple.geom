#version 330 core

layout(triangles) in;
layout (triangle_strip, max_vertices = 3) out;

void main()
{
	vec4 center = (gl_in[0].gl_Position + gl_in[1].gl_Position + gl_in[2].gl_Position)/3.0;
	gl_Position = gl_in[0].gl_Position + center;
	EmitVertex();
	gl_Position = gl_in[1].gl_Position + center;
	EmitVertex();
	gl_Position = gl_in[2].gl_Position + center;
	EmitVertex();
	EndPrimitive();
}
