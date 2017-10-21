module armos.graphics.defaultrenderer;

// import armos.graphics.renderer;
import armos.graphics.renderer:Renderer,
                               uniform, 
                               backgroundColor, 
                               Capability, 
                               PolyRenderMode,
                               BlendMode,
                               PrimitiveMode;
import armos.graphics.vao:Vao;
import armos.graphics.shader.uniform:Uniform, uniform, uniformTexture;
import armos.graphics.shader:Shader;
import armos.graphics.fbo:Fbo;
import armos.graphics.buffer:Buffer;
import armos.graphics.texture:Texture;

class DefaultRenderer: Renderer{
    import armos.math:Matrix4f;
    public{
        import armos.utils.scoped: scoped;
        this(){
            import armos.math:Vector2i;
            _target = new Fbo(Vector2i(256, 256));

            import armos.graphics.material:defaultVertexShaderSource,
                                           defaultFragmentShaderSource;
            _shader = (new Shader).loadSources(defaultVertexShaderSource,
                                               "",
                                               defaultFragmentShaderSource);
            import std.stdio;
            _shader.log.writeln;
            _defaultVao = new Vao;
            _primitiveMode = PrimitiveMode.Triangles;
            _isBackgrounding = true;
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
        This isBackgrounding(in bool b){
            _isBackgrounding = b;
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
            updateBuildinUniforms;
            import std.array:byPair;
            foreach (pair; _capabilities.byPair) {
                auto name    = pair[0];
                auto capability = pair[1];
                _renderer.capability(name, capability);
            }

            foreach (pair; _uniforms.byPair) {
                auto name    = pair[0];
                auto uniform = pair[1];
                _renderer.uniform(name, uniform);
            }

            foreach (pair; _textures.byPair) {
                auto name    = pair[0];
                auto texture = pair[1];
                _renderer.texture(name, texture);
            }

            _renderer.indices(_indices);

            if(_isUsingUserVao){
                _renderer.vao = _vao;
            }else{
                foreach (pair; _attributes.byPair) {
                    auto name    = pair[0];
                    auto attribute = pair[1];
                    _renderer.attribute(name, attribute);
                }
            }

            import std.stdio;
            _renderer.polyRenderMode(_polyRenderMode)
                     .blendMode(_blendMode)
                     .isBackgrounding(_isBackgrounding)
                     .backgroundColor(_backgroundColor)
                     .target(_target)
                     .shader(_shader)
                     .render();
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

        bool _isBackgrounding;
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

