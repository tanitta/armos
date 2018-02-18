module armos.graphics.gl.fbo;

import derelict.opengl3.gl;
import armos.graphics.gl.texture;
import armos.graphics.material;
import armos.graphics.mesh;
import armos.graphics.gl.shader;
import armos.types;
import armos.math.vector;
import armos.utils.scoped;

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
        this(V2)(in V2 size){
            this(size[0], size[1]);
        }

        /++
        +/
        this(T)(in T width, in T height){
            glGenFramebuffers(1, cast(uint*)&_id);
            _size = Vector2i(width, height);
            _colorTexture    = (new Texture).allocate(_size.x, _size.y, armos.graphics.ColorFormat.RGBA)
                                            .minMagFilter(TextureMinFilter.Nearest, TextureMagFilter.Nearest);
            _depthTexture    = (new Texture).allocate(_size.x, _size.y, armos.graphics.ColorFormat.Depth)
                                            .minMagFilter(TextureMinFilter.Nearest, TextureMagFilter.Nearest);

            _colorTextureTmp = (new Texture).allocate(_size.x, _size.y, armos.graphics.ColorFormat.RGBA)
                                            .minMagFilter(TextureMinFilter.Nearest, TextureMagFilter.Nearest);
            _depthTextureTmp = (new Texture).allocate(_size.x, _size.y, armos.graphics.ColorFormat.Depth)
                                            .minMagFilter(TextureMinFilter.Nearest, TextureMagFilter.Nearest);
            
            {
                begin;scope(exit)end;
                glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _colorTexture.id, 0);
                glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT,  GL_TEXTURE_2D, _depthTexture.id, 0);
            }
        }

        Vector2i size()const {
            return _size;
        }

        /++
            FBOへの描画処理を開始します．
        +/
        Fbo begin(in bool setScreenPerspective = true){
            import armos.app.runner:currentContext;
            import armos.graphics.gl.context.helper.fbo;
            currentContext.pushFbo(this);
            return this;
        }

        /++
            FBOへの描画処理を終了します．
        +/
        Fbo end(){
            import armos.app.runner:currentContext;
            import armos.graphics.gl.context.helper.fbo;
            currentContext.popFbo();
            return this;
        }

        /++
            FBOのIDを返します．
        +/
        int id()const{
            return _id;
        }

        Texture colorTexture(){
            return _colorTexture;
        }

        Texture depthTexture(){
            return _depthTexture;
        }

        /++
            FBOをリサイズします．
            Params:
            size = リサイズ後のサイズ
        +/
        Fbo resize(in armos.math.Vector2i size){
            _size = size;
            resizeTextures;

            return this;
        }
        
        ///
        Fbo minFilter(in TextureMinFilter filter){
            _colorTexture.minFilter(filter);
            _colorTextureTmp.minFilter(filter);
            _depthTexture.minFilter(filter);
            _depthTextureTmp.minFilter(filter);
            return this;
        }

        ///
        Fbo magFilter(in TextureMagFilter filter){
            _colorTexture.magFilter(filter);
            _colorTextureTmp.magFilter(filter);
            _depthTexture.magFilter(filter);
            _depthTextureTmp.magFilter(filter);
            return this;
        }
        
    }//public

    package{
        Fbo bind(){
            return Fbo.bind(this);
        }

        static Fbo bind(Fbo fbo){
            if(!fbo){
                glBindFramebuffer(GL_FRAMEBUFFER, 0);
                return fbo;
            }
            glBindFramebuffer(GL_FRAMEBUFFER, fbo._id);
            return fbo;
        }
    }

    private{
        int _savedId = 0;
        int _id = 0;

        Texture _colorTexture;
        Texture _colorTextureTmp;
        Texture _depthTexture;
        Texture _depthTextureTmp;

        Mesh _rect = new Mesh;
        Material _material;
        Vector2i _size;
        
        void resizeTextures(){
            import std.stdio;
            begin;
            _colorTexture.resize(_size);
            _depthTexture.resize(_size);
            _colorTextureTmp.resize(_size);
            _depthTextureTmp.resize(_size);
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
