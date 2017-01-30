// simple.frag
#version 330
    
in vec4 f_color;

out vec4 fragColor;

uniform vec4 diffuse;

void main(void) {
    fragColor = diffuse;
}
