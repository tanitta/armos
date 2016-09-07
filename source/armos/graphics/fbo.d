module armos.graphics.fbo;
import armos.graphics;
import armos.types;
import derelict.opengl3.gl;
import armos.math.vector;
// import armos.graphics.material;

/++
    Frame Buffer Objectを表すclassです．
+/
class Fbo{
    public{
        /++
        +/
        this(){
            static import armos.app;
            this(armos.app.currentWindow.size);
        }

        /++
        +/
        this(in armos.math.Vector2i size){
            this(size[0], size[1]);
        }

        /++
        +/
        this(in int width, in int height){
            glGenFramebuffers(1, cast(uint*)&_id);

            _colorTexture = new armos.graphics.Texture;
            _colorTexture.allocate(width, height, armos.graphics.ColorFormat.RGBA);

            _depthTexture= new armos.graphics.Texture;
            _depthTexture.allocate(width, height, armos.graphics.ColorFormat.Depth);

            float x = width;
            float y = height;
            
            rect = new Mesh;

            rect.vertices = [
                Vector4f(0.0, 0.0,  0.0, 1.0f),
                Vector4f(0.0, y,  0.0, 1.0f),
                Vector4f(x,  y,  0.0, 1.0f),
                Vector4f(x,  0.0,  0.0, 1.0f),
            ];
            
            rect.texCoords0= [
                Vector4f(0f, 0f,  0.0, 1.0f),
                Vector4f(0, 1f,  0.0, 1.0f),
                Vector4f(1,  1,  0.0, 1.0f),
                Vector4f(1.0,  0,  0.0, 1.0f),
            ];
            
            rect.indices = [
                0, 1, 2,
                2, 3, 0,
            ];

            glGetIntegerv(GL_FRAMEBUFFER_BINDING, &_savedId);
            glBindFramebuffer(GL_FRAMEBUFFER, _id);

            glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _colorTexture.id, 0);
            glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT,  GL_TEXTURE_2D, _depthTexture.id, 0);
            glBindFramebuffer(GL_FRAMEBUFFER, _savedId);
            
            _material = (new FboMaterial).texture("colorTexture", _colorTexture)
                                         .texture("depthTexture", _depthTexture);
        }

        /++
            FBOへの描画処理を開始します．
        +/
        Fbo begin(){
            glGetIntegerv(GL_FRAMEBUFFER_BINDING, &_savedId);
            glBindFramebuffer(GL_FRAMEBUFFER, _id);
            return this;
        }

        /++
            FBOへの描画処理を終了します．
        +/
        Fbo end(){
            glBindFramebuffer(GL_FRAMEBUFFER, _savedId);
            return this;
        }

        /++
            FBOのIDを返します．
        +/
        int id()const{
            return _id;
        }

        /++
            FBOを描画します．
        +/
        Fbo draw(){
            _material.begin;
            rect.drawFill();
            _material.end;
            return this;
        }

        /++
            FBOをリサイズします．
            Params:
            size = リサイズ後のサイズ
        +/
        Fbo resize(in armos.math.Vector2i size){
            size.print;
            begin;
            rect.vertices[1][1] = size[1];
            rect.vertices[2][0] = size[0];
            rect.vertices[2][1] = size[1];
            rect.vertices[3][0] = size[0];
            // _colorTexture.resize(size);
            _colorTexture.resize(Vector2i(size[0], size[1]));
            _depthTexture.resize(size);
            end;
            return this;
        }
        
        bool isFlip()const{return _isFlip;}
        
        Fbo isFlip(in bool f){
            _isFlip = f;
            if(_isFlip){
                rect.texCoords0 = [
                    Vector4f(0f, 1f,  0.0, 1.0f),
                    Vector4f(0, 0f,  0.0, 1.0f),
                    Vector4f(1,  0,  0.0, 1.0f),
                    Vector4f(1.0,  1,  0.0, 1.0f),
                ];
            }else{
                rect.texCoords0 = [
                    Vector4f(0f, 0f,  0.0, 1.0f),
                    Vector4f(0, 1f,  0.0, 1.0f),
                    Vector4f(1,  1,  0.0, 1.0f),
                    Vector4f(1.0,  0,  0.0, 1.0f),
                ];
            }
            return this;
        }
    }//public

    private{
        int _savedId =0;
        int _id = 0;
        armos.graphics.Texture _colorTexture;
        armos.graphics.Texture _depthTexture;
        armos.graphics.Mesh rect = new armos.graphics.Mesh;
        armos.graphics.Material _material;
        
        bool _isFlip = false;
    }//private
}

/++
+/
class FboMaterial : armos.graphics.Material{
    mixin armos.graphics.MaterialImpl;
    
    ///
    this(){
        _shader = new armos.graphics.Shader;
        _shader.loadSources(fboVertesShaderSource, fboFragmentShaderSource);
    }
    
    private{
    }
}//class FboMaterial

private immutable string fboVertesShaderSource = q{
#version 330

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform mat4 modelViewProjectionMatrix;
uniform mat4 textureMatrix;

in vec4 vertex;
in vec3 normal;
in vec3 tangent;
in vec4 texCoord0;
in vec4 texCoord1;
in vec4 color;

out vec4 f_color;
out vec2 outtexCoord0;
out vec2 outtexCoord1;

void main(void) {
    gl_Position = modelViewProjectionMatrix * vertex;
    f_color = color;
    outtexCoord0 = texCoord0.xy;
    outtexCoord1 = texCoord1.xy;
}
};

private immutable string fboFragmentShaderSource = q{
#version 330
    
in vec4 f_color;
in vec2 outtexCoord0;
in vec2 outtexCoord1;

uniform sampler2D colorTexture;
uniform sampler2D depthTexture;

void main(void) {
    gl_FragColor = texture(colorTexture, outtexCoord0);
}
};
