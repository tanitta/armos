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
    public{
        import armos.utils.scoped: scoped;

        ///
        This setup(){
            import armos.graphics.material:defaultVertexShaderSource,
                                           defaultFragmentShaderSource;
            _shader = (new Shader).loadSources(defaultVertexShaderSource,
                                               "",
                                               defaultFragmentShaderSource);
            import std.stdio;
            _shader.log.writeln;
            _defaultVao = new Vao;
            _primitiveMode = PrimitiveMode.Triangles;
            _backgroundColor = [0.1, 0.1, 0.1, 1.0];
            this.diffuse = [1.0f, 1.0f, 1.0f, 1.0f];
            setupBuildinUniforms();

            import armos.graphics.pixel;
            auto bitmap = (new armos.graphics.Bitmap!(char))
                         .allocate(1, 1, ColorFormat.RGBA)
                         .setAllPixels(0, 255)
                         .setAllPixels(1, 255)
                         .setAllPixels(2, 255)
                         .setAllPixels(3, 255);
            _textures["tex0"] = (new Texture).allocate(bitmap);
            return this;
        }
        //inputs
        // // This scene(Scene);

        ///
        This vao(Vao vao){
            _isUsingUserVao = true;
            _vao = vao;
            return this;
        };
        
        ///
        This attribute(in string name, Buffer buffer){
            _isUsingUserVao = false;
            _attributes[name] = buffer;
            return this;
        }

        ///
        This indices(Buffer buffer){
            _indices = buffer;
            return this;
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
        
        //output
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
        This renderer(Renderer renderer){
            _renderer = renderer;
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
    }//public

    public{
        ///
        This uniformImpl(in string name, Uniform u){
            _uniforms[name] = u;
            return this;
        }

        This backgroundColorImpl(in float r, in float g, in float b, in float a){
            _backgroundColor = [r, g, b, a];
            return this;
        }
    }//public

    private{
        Fbo _target;
        Uniform[string]  _uniforms;
        Buffer[string]   _attributes;
        bool[Capability] _capabilities;
        Buffer           _indices;
        PolyRenderMode   _polyRenderMode;
        BlendMode        _blendMode;
        float[4]         _backgroundColor;

        Shader _shader;
        Vao _vao;
        Vao _defaultVao;
        bool _isUsingUserVao = false;
        PrimitiveMode _primitiveMode;
        Texture[string] _textures;
        Renderer _renderer;

        This setupBuildinUniforms(){
            this.uniform("modelMatrix",               Matrix4f.identity.array!2);
            this.uniform("viewMatrix",                Matrix4f.identity.array!2);
            this.uniform("projectionMatrix",          Matrix4f.identity.array!2);
            this.uniform("textureMatrix",             Matrix4f.identity.array!2);
            this.uniform("modelViewMatrix",           Matrix4f.identity.array!2);
            this.uniform("modelViewProjectionMatrix", Matrix4f.identity.array!2);
            return this;
        }

        This updateBuildinUniforms(){
            auto viewMatrix       = Matrix4f.array(*_uniforms["viewMatrix"].peek!(float[4][4]));
            auto modelMatrix      = Matrix4f.array(*_uniforms["modelMatrix"].peek!(float[4][4]));
            auto projectionMatrix = Matrix4f.array(*_uniforms["projectionMatrix"].peek!(float[4][4]));
            this.uniform("modelViewMatrix",           (viewMatrix*modelMatrix).array!2);
            this.uniform("modelViewProjectionMatrix", (projectionMatrix*viewMatrix*modelMatrix).array!2);
            return this;
        }

        This registerBuffersToDefaultVao(){
            import std.array:byPair;
            import std.algorithm:each;
            _attributes.byPair.each!((p){
                pragma(msg, __FILE__, "(", __LINE__, "): ",
                       "TODO: use cachables");
                _defaultVao.registerBuffer(p[0], p[1], _shader);
            });
            _defaultVao.registerBuffer(_indices);
            return this;
        }

        This renderVao(Vao vao){
            import std.array:byPair;
            import std.algorithm:each;

            assert(_indices);

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

            const iboScope = scoped(_indices);
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

///
Renderer diffuse(Renderer renderer, float[4] c){
    renderer.uniform("diffuse", c);
    return renderer;
}

///
Renderer diffuse(Renderer renderer, in float r, in float g, in float b, in float a = 1){
    float[4] arr = [r, g, b, a];
    renderer.uniform("diffuse", arr);
    return renderer;
}

import armos.types.color;
///
Renderer diffuse(Renderer renderer, Color c){
    float[4] arr = [c.r, c.g, c.b, c.a];
    renderer.uniform("diffuse", arr);
    return renderer;
}

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
