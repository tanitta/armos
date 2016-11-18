#version 330
    
in vec4 f_color;
in vec2 outtexCoord0;
in vec2 outtexCoord1;

out vec4 fragColor;

uniform sampler2D colorTexture;
uniform sampler2D depthTexture;

void main(void) {
    float l = 0.01;
    float d = (pow(outtexCoord0.x-0.5, 2)+pow(outtexCoord0.y-0.5, 2));
    float r = texture(colorTexture, outtexCoord0+vec2(l, 0)).r;
    float g = texture(colorTexture, outtexCoord0+vec2(0, 0)).g;
    float b = texture(colorTexture, outtexCoord0+vec2(-l, 0)).b;
    fragColor = vec4(r, g, b, 1.0);
}
