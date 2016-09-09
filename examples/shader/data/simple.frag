// simple.frag
#version 330

const float PI = 3.14159265;

uniform float time;
uniform float shiftX;
uniform float shiftY;
uniform sampler2D tex;

in vec2 outtexCoord0;

void main(void) {
    float d = distance(vec2(shiftX, shiftY)/512.0, outtexCoord0);
    float r = texture(tex, outtexCoord0 + 0.05*d*vec2(cos(time+d*64.0), sin(time+d*64.0))).r;
    float g = texture(tex, outtexCoord0 + 0.05*d*vec2(cos(time+d*64.0+PI*1.0/3.0), sin(time+d*64.0+PI*1.0/3.0))).g;
    float b = texture(tex, outtexCoord0 + 0.05*d*vec2(cos(time+d*64.0+PI*2.0/3.0), sin(time+d*64.0+PI*2.0/3.0))).b;
    gl_FragColor = vec4(r-d*0.5, g-d*0.5, b-d*0.5, 1);
}
