// simple.frag
#version 130

uniform vec4 color;
uniform sampler2D tex;

void main(void) {
	vec2 pos = gl_TexCoord[0].xy;
	float r = texture2D(tex, pos).r;
	float g = texture2D(tex, pos).g;
	float b = texture2D(tex, pos).b;
	float a = texture2D(tex, pos).a;
	
	gl_FragColor = vec4(r*color.r,g*color.r,b*color.b,a*color*a);
}
