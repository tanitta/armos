// simple.frag
#version 330

uniform float userVar;
uniform sampler2D tex;

in vec2 outtexCoord0;

void main(void) {
    gl_FragColor = texture(tex, outtexCoord0)*userVar;
}
