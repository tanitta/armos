module armos.graphics.defaultrenderer;

import armos.graphics.renderer:Renderer,
                               uniform, 
                               backgroundColor;
import armos.graphics.gl.context;
import armos.graphics.gl.capability;
import armos.graphics.gl.polyrendermode;
import armos.graphics.gl.primitivemode;
import armos.graphics.gl.blendmode;
import armos.graphics.gl.vao:Vao;
import armos.graphics.gl.uniform:Uniform, uniform, uniformTexture;
import armos.graphics.gl.shader:Shader;
import armos.graphics.gl.fbo:Fbo;
import armos.graphics.gl.buffer:Buffer;
import armos.graphics.gl.texture:Texture;

class DefaultRenderer: Renderer{
    import derelict.opengl3.gl;
    import armos.math:Matrix4f;
    private alias This = typeof(this);
    public{
        import armos.utils.scoped;

        ///
        This setup(){
            _defaultVao = new Vao;
            return this;
        }

        ///
        This vao(Vao vao){
            _isUsingUserVao = true;
            _vao = vao;
            return this;
        }
        
        ///
        This attrBuffer(in string name, Buffer buffer){
            _isUsingUserVao = false;
            _attributes[name] = buffer;
            return this;
        }

        ///
        Buffer attrBuffer(in string name){
            import std.algorithm;
            if(!_attributes.keys.canFind(name)) return null;
            return _attributes[name];
        }

        ///
        This indexBuffer(Buffer buffer){
            _indexBuffer = buffer;
            return this;
        }

        ///
        Buffer indexBuffer(){
            return _indexBuffer;
        }

        ///
        This texture(in string name, Texture texture){
            _textures[name] = texture;
            return this;
        }

        ///
        This polyRenderMode(PolyRenderMode mode){
            _polyRenderMode = mode;
            return this;
        }

        ///
        This fillBackground(){
            const fboScope = scoped(_target);

            auto c = _backgroundColor;
            glClearColor(c[0], c[1], c[2], c[3]);
            glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
            return this;
        }

        ///
        This capability(Capability cap, bool b){
            _capabilities[cap] = b;
            return this;
        }

        ///
        bool capability(Capability cap){
            return _capabilities[cap];
        }

        ///
        This blendMode(BlendMode blendMode){
            _blendMode = blendMode;
            return this;
        }
        
        ///
        Fbo  target(){
            return _target;
        }

        ///
        This target(Fbo fbo){
            _target = fbo;
            return this;
        }

        ///
        This shader(Shader shader){
            _shader = shader;
            return this;
        }

        ///
        This render(){
            if(_isUsingUserVao){
                renderVao(_vao);
            }else{
                registerBuffersToDefaultVao;
                renderVao(_defaultVao);
            }
            return this;
        }

        This uniformImpl(in string name, Uniform u){
            _uniforms[name] = u;
            return this;
        }

        This backgroundColorImpl(in float r, in float g, in float b, in float a){
            _backgroundColor = [r, g, b, a];
            return this;
        }
    }//public

    protected{
        Fbo _target;
        Uniform[string]  _uniforms;
        Buffer[string]   _attributes;
        bool[Capability] _capabilities;
        Buffer           _indexBuffer;
        PolyRenderMode   _polyRenderMode;
        BlendMode        _blendMode;
        float[4]         _backgroundColor;

        Shader _shader;
        Vao _vao;
        Vao _defaultVao;
        bool _isUsingUserVao = false;
        PrimitiveMode _primitiveMode;
        Texture[string] _textures;

        //
        // This updateBuildinUniforms(){
        //     auto viewMatrix       = Matrix4f.array(*_uniforms["viewMatrix"].peek!(float[4][4]));
        //     auto modelMatrix      = Matrix4f.array(*_uniforms["modelMatrix"].peek!(float[4][4]));
        //     auto projectionMatrix = Matrix4f.array(*_uniforms["projectionMatrix"].peek!(float[4][4]));
        //     this.uniform("modelViewMatrix",           (modelMatrix*viewMatrix).array!2);
        //     this.uniform("modelViewProjectionMatrix", (modelMatrix*viewMatrix*projectionMatrix).array!2);
        //     // this.uniform("modelViewProjectionMatrix", (projectionMatrix*viewMatrix*modelMatrix).transpose.array!2);
        //     return this;
        // }

        This registerBuffersToDefaultVao(){
            import std.array:byPair;
            import std.algorithm:each;
            _attributes.byPair.each!((p){
                _defaultVao.registerBuffer(p[0], p[1], _shader);
            });
            if(!_indexBuffer)return this;
            _defaultVao.registerBuffer(_indexBuffer);
            return this;
        }

        This renderVao(Vao vao){
            import std.array:byPair;
            import std.algorithm:each;

            if(!_indexBuffer)return this;

            auto vaoScope = scoped(vao);

            const shaderScope = scoped(_shader);
            _uniforms.byPair.each!(u => _shader.uniform(u[0], u[1]));

            const texturesScope = scoped(Textures(_textures));
            uint textureIndex;
            foreach (pair; _textures.byPair) {
                auto name = pair[0];
                auto texture  = pair[1];
                _shader.uniformTexture(name, texture , textureIndex);
                textureIndex++;
            }

            const iboScope = scoped(_indexBuffer);
            int elements;
            import derelict.opengl3.gl;
            glGetBufferParameteriv(GL_ELEMENT_ARRAY_BUFFER, GL_BUFFER_SIZE, &elements);
            import std.conv;
            immutable int size = (elements/GLuint.sizeof).to!int;

            const fboScope = scoped(_target);

            vao.isUsingAttributes(true);
            glDrawElements(_primitiveMode, size, GL_UNSIGNED_INT, null);
            vao.isUsingAttributes(false);
            return this;
        }
    }//private
}//class DefaultRenderer

private struct Textures {
    import std.array:byPair;
    public{
        Textures begin(){
            foreach (pair; _textures.byPair) {
                auto texture  = pair[1];
                texture.begin;
            }
            return this;
        }

        Textures end(){
            foreach (pair; _textures.byPair) {
                auto texture  = pair[1];
                texture.end;
            }
            return this;
        }
    }//public

    private{
        Texture[string] _textures;
    }//private
}//struct Textures
