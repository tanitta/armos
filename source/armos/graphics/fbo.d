module armos.graphics.fbo;

import derelict.opengl3.gl;
import armos.graphics;
import armos.types;
import armos.math.vector;

/++
    Frame Buffer Objectを表すclassです．
+/
class Fbo{
    public{
        /++
        +/
        this(){
            import armos.app;
            this(currentWindow.size);
        }

        /++
        +/
        this(in armos.math.Vector2i size){
            this(size[0], size[1]);
        }

        /++
        +/
        this(in int width, in int height){
            _size = Vector2i(width, height);
            Vector2i textureSize = _size * _samples;
            int x = textureSize.x;
            int y = textureSize.y;
            
            glGenFramebuffers(1, cast(uint*)&_id);

            _colorTexture = (new Texture).allocate(x, y, armos.graphics.ColorFormat.RGBA)
                                         .minMagFilter(TextureMinFilter.Nearest, TextureMagFilter.Nearest);

            _depthTexture = (new Texture).allocate(x, y, armos.graphics.ColorFormat.Depth)
                                         .minMagFilter(TextureMinFilter.Nearest, TextureMagFilter.Nearest);
            
            _colorTextureTmp = (new Texture).allocate(x, y, armos.graphics.ColorFormat.RGBA)
                                            .minMagFilter(TextureMinFilter.Nearest, TextureMagFilter.Nearest);
            
            _depthTextureTmp = (new Texture).allocate(x, y, armos.graphics.ColorFormat.Depth)
                                            .minMagFilter(TextureMinFilter.Nearest, TextureMagFilter.Nearest);

            _rect = new Mesh;

            _rect.texCoords0 = [
                Vector4f(0f, 0f, 0.0, 1.0f),
                Vector4f(0,  1f, 0.0, 1.0f),
                Vector4f(1f, 1f, 0.0, 1.0f),
                Vector4f(1f, 0,  0.0, 1.0f),
            ];
            // isFlip(true);
            
            _rect.vertices = [
                Vector4f(0.0,   0.0,    0.0, 1.0f),
                Vector4f(0.0,   height, 0.0, 1.0f),
                Vector4f(width, height, 0.0, 1.0f),
                Vector4f(width, 0.0,    0.0, 1.0f),
            ];
            
            _rect.indices = [
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
        Fbo begin(in bool setScreenPerspective = true){
            glGetIntegerv(GL_FRAMEBUFFER_BINDING, &_savedId);
            glBindFramebuffer(GL_FRAMEBUFFER, _id);
            Vector2i textureSize = _size*_samples;
            glViewport(0, 0, textureSize[0], textureSize[1]);
            
            pushProjectionMatrix;
            if(setScreenPerspective) loadProjectionMatrix(screenPerspectiveMatrix);
            return this;
        }

        /++
            FBOへの描画処理を終了します．
        +/
        Fbo end(){
            popProjectionMatrix;
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
            _rect.drawFill;
            _material.end;
            return this;
        }

        /++
            FBOをリサイズします．
            Params:
            size = リサイズ後のサイズ
        +/
        Fbo resize(in armos.math.Vector2i size){
            _size = size;
            _rect.vertices[1][1] = _size[1];
            _rect.vertices[2][0] = _size[0];
            _rect.vertices[2][1] = _size[1];
            _rect.vertices[3][0] = _size[0];
            
            resizeTextures;
            return this;
        }
        
        ///
        bool isFlip()const{return _isFlip;}
        
        ///
        Fbo isFlip(in bool f){
            _isFlip = f;
            if(_isFlip){
                _rect.texCoords0 = [
                    Vector4f(0f,  1f, 0.0, 1.0f),
                    Vector4f(0,   0f, 0.0, 1.0f),
                    Vector4f(1,   0,  0.0, 1.0f),
                    Vector4f(1.0, 1,  0.0, 1.0f),
                ];
            }else{
                _rect.texCoords0 = [
                    Vector4f(0f,  0f, 0.0, 1.0f),
                    Vector4f(0,   1f, 0.0, 1.0f),
                    Vector4f(1,   1,  0.0, 1.0f),
                    Vector4f(1.0, 0,  0.0, 1.0f),
                ];
            }
            return this;
        }
        
        ///
        Fbo samples(in int s){
            _samples = s;
            resizeTextures;
            return this;
        }
        
        ///
        int samples()const{
            return _samples;
        }
        
        ///
        Fbo filteredBy(Material material){
            begin;
                _colorTextureTmp.begin;
                    glCopyTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, 0, 0, _size.x, _size.y);
                _colorTextureTmp.end;
                _depthTextureTmp.begin;
                    glCopyTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, 0, 0, _size.x, _size.y);
                _depthTextureTmp.end;
            end;
            
            material.texture("colorTexture", _colorTextureTmp)
                    .texture("depthTexture", _depthTextureTmp);
            
            begin;
                material.begin;
                    _rect.drawFill;
                material.end;
            end;
            
            return this;
        }
        
    }//public

    private{
        int _savedId = 0;
        int _id = 0;
        Texture _colorTexture;
        Texture _colorTextureTmp;
        Texture _depthTexture;
        Texture _depthTextureTmp;
        Mesh _rect = new Mesh;
        Material _material;
        int _samples = 1;
        bool _isFlip = false;
        Vector2i _size;
        
        void resizeTextures(){
            begin;
            _colorTexture.resize(_size*_samples);
            _depthTexture.resize(_size*_samples);
            _colorTextureTmp.resize(_size*_samples);
            _depthTextureTmp.resize(_size*_samples);
            end;
        }
    }//private
}

/++
+/
class FboMaterial : Material{
    mixin MaterialImpl;
    
    ///
    this(){
        _shader = new Shader;
        _shader.loadSources(fboVertexShaderSource, "", fboFragmentShaderSource);
    }
    
    private{
    }
}//class FboMaterial

private immutable string fboVertexShaderSource = q{
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

out vec4 fragColor;

uniform sampler2D colorTexture;
uniform sampler2D depthTexture;

void main(void) {
    fragColor = texture(colorTexture, outtexCoord0);
}
};
