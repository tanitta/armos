import std.stdio;
import std.math;
import derelict.opengl3.gl;

import armos.app: BaseApp,
                  run;
import armos.math: vec2f, vec4f;
import armos.graphics: Texture,
                       StandardMesh,
                       StandardVertex,
                       ColorFormat,
                       PrimitiveMode,
                       currentRenderer,
                       backgroundColor,
                       Camera,
                       ScreenCamera;

class TestApp : BaseApp{
    Texture _texture;
    StandardMesh _rect;
    Camera _camera;
    override void setup(){
        _texture = new Texture;
        uint i , j;
        uint textureSize = 512;
        ubyte[] bits = new ubyte[](textureSize*textureSize*4);
        for (i = 0 ; i < textureSize ; i++) {
            for (j = 0 ; j < textureSize ; j++) {
                bits[i*512*4 + j*4 + 0] = cast(ubyte)i;
                bits[i*512*4 + j*4 + 2] = cast(ubyte)j;
                bits[i*512*4 + j*4 + 3] = cast(ubyte)( j*i );
            }
        }

        _texture.allocate(bits, textureSize, textureSize, ColorFormat.RGBA);
        float x = 512;
        float y = 512;

        _camera = new ScreenCamera;
        _rect = (new StandardMesh).primitiveMode(PrimitiveMode.TriangleStrip)
                                  .indices([0, 1, 2, 2, 3, 0])
                                  .vertices([StandardVertex().position(vec4f(0f, 0f, 0f, 1f))
                                                             .texCoord0(vec4f(0f, 0f, 0f, 1f)), 
                                             StandardVertex().position(vec4f(0f, y,  0f, 1f))
                                                             .texCoord0(vec4f(0f, 1f, 0f, 1f)), 
                                             StandardVertex().position(vec4f(x,  y,  0f, 1f))
                                                             .texCoord0(vec4f(1f, 1f, 0f, 1f)), 
                                             StandardVertex().position(vec4f(x,  0f, 0f, 1f))
                                                             .texCoord0(vec4f(1f, 0f, 0f, 1f))]);

        // ar.graphics.currentMaterial._texture("tex0", _texture);
	}
	
	override void draw(){
        auto cr = currentRenderer;
        cr.backgroundColor(0.2, 0.2, 0.2, 1.).fillBackground;
	}
}

void main(){
    version(unittest){
    }else{
        run(new TestApp);
    }
}
