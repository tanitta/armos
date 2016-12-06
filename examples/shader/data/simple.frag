// simple.frag
#version 330

const float PI = 3.14159265;

uniform float time;
uniform vec2 shift;
uniform sampler2D tex;

in vec2 outtexCoord0;

out vec4 fragColor;

void main(void) {
    float d = distance(shift/512.0, outtexCoord0);
    float r = texture(tex, outtexCoord0 + 0.05*d*vec2(cos(time+d*64.0), sin(time+d*64.0))).r;
    float g = texture(tex, outtexCoord0 + 0.05*d*vec2(cos(time+d*64.0+PI*1.0/3.0), sin(time+d*64.0+PI*1.0/3.0))).g;
    float b = texture(tex, outtexCoord0 + 0.05*d*vec2(cos(time+d*64.0+PI*2.0/3.0), sin(time+d*64.0+PI*2.0/3.0))).b;
    fragColor = vec4(r-d*0.5, g-d*0.5, b-d*0.5, 1);
}
