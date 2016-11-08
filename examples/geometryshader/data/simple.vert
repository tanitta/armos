// simple.vert
#version 330
 
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform mat4 modelViewProjectionMatrix;
uniform mat4 textureMatrix;

in vec4 vertex;
in vec4 texCoord0;

out vec2 outtexCoord0;

void main(void)
{
    gl_Position = modelViewProjectionMatrix * vertex;
    outtexCoord0 = texCoord0.xy;
}
