module armos.graphics.embeddedrenderer.d;

import armos.graphics.renderer:Renderer,
                               uniform, 
                               Capability, 
                               PolyRenderMode,
                               BlendMode,
                               PrimitiveMode;
import armos.graphics.gl.vao:Vao;
import armos.graphics.gl.uniform:Uniform, uniform, uniformTexture;
import armos.graphics.gl.shader:Shader;
import armos.graphics.gl.fbo:Fbo;
import armos.graphics.gl.buffer:Buffer;
import armos.graphics.gl.texture:Texture;
import armos.utils.scoped: scoped;

class EmbedddedRenderer: Renderer{
    import derelict.opengl3.gl;
    public{
        this(){
            _defaultVao = new Vao;
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
            _attributes.updateCachable(name, buffer);
            return this;
        }

        ///
        This indices(Buffer buffer){
            _indices.updateCachable(buffer);
            return this;
        }

        ///
        This texture(in string name, Texture texture){
            _textures[name] = texture;
            return this;
        }

        ///
        This polyRenderMode(PolyRenderMode mode){
            _polyRenderMode.updateCachable(mode);
            return this;
        }

        ///
        This isBackgrounding(in bool b){
            _isBackgrounding = b;
            return this;
        }

        ///
        This capability(Capability cap, bool b){
            _capabilities.updateCachable(cap, b);
            return this;
        }

        ///
        bool capability(Capability cap){
            return _capabilities[cap].content;
        }

        ///
        This blendMode(BlendMode blendMode){
            _blendMode.updateCachable(blendMode);
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
        This render(){
            if(_backgroundColor.hasChanged){
                auto c = _backgroundColor.content;
                glClearColor(c[0], c[1], c[2], c[3]);
            } 

            if(_isBackgrounding){
                glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
            }

            if(_isUsingUserVao){
                auto vaoScope = scoped(_vao);
                sendAttribsToShaderWithBindedVao();
                renderWithBindedVao();
            }else{
                auto vaoScope = scoped(_defaultVao);
                sendBuffersToBindedVao;
                sendAttribsToShaderWithBindedVao();
                renderWithBindedVao();
            }

            turnOffupdateFlagOfEachCachable;

            return this;
        }

        ///
        This renderer(Renderer renderer){
            _renderer = renderer;
            return this;
        }
    }//public

    public{
        ///
        This uniformImpl(in string name, Uniform u){
            _uniforms.updateCachable(name, u);
            return this;
        }

        ///
        This backgroundColorImpl(in float r, in float g, in float b, in float a){
            _backgroundColor.updateCachable([r, g, b, a]);
            return this;
        }
    }//public

    private{
        Fbo _target;

        Cachable!Uniform[string]  _uniforms;
        Cachable!Buffer[string]   _attributes;
        Cachable!bool[Capability] _capabilities;
        Cachable!Buffer           _indices;
        Cachable!PolyRenderMode   _polyRenderMode;
        Cachable!BlendMode        _blendMode;
        Cachable!(float[4])       _backgroundColor;

        bool _isBackgrounding;
        Shader _shader;
        Vao _vao;
        Vao _defaultVao;
        bool _isUsingUserVao = false;
        PrimitiveMode _primitiveMode;
        Texture[string] _textures;
        Renderer _renderer;

        This turnOffupdateFlagOfEachCachable(){
            _uniforms.turnOffupdateFlag;
            _attributes.turnOffupdateFlag;
            _capabilities.turnOffupdateFlag;
            _indices.hasChanged         = false;
            _polyRenderMode.hasChanged  = false;
            _blendMode.hasChanged       = false;
            _backgroundColor.hasChanged = false;
            return this;
        }
        // binding requirement
        // shader : no
        // vao    : yes 
        This sendAttribsToShaderWithBindedVao(){
            import std.array:byPair;
            foreach (pair; _attributes.byPair){
                auto name   = pair[0];
                auto buffer = pair[1].content;
                buffer.begin;
                _shader.attr(name);
                buffer.end;
            }
            return this;
        }

        // binding requirement
        // shader : no 
        // vao    : yes 
        This renderWithBindedVao(){
            import std.array:byPair;
            import std.algorithm:each;

            assert(_indices.content);

            const shaderScope= scoped(_shader);
            _uniforms.byPair.each!(u => _shader.uniform(u[0], u[1].content));

            const texturesScope = scoped(Textures(_textures));
            uint textureIndex;
            foreach (pair; _textures.byPair) {
                auto name = pair[0];
                auto texture  = pair[1];
                _shader.uniformTexture(name, texture , textureIndex);
                textureIndex++;
            }

            const iboScope       = scoped(_indices.content);
            _shader.enableAttribs();
                int elements;
                import derelict.opengl3.gl;
                glGetBufferParameteriv(GL_ELEMENT_ARRAY_BUFFER, GL_BUFFER_SIZE, &elements);
                import std.conv;
                immutable int size = (elements/GLuint.sizeof).to!int;
                glDrawElements(_primitiveMode, size, GL_UNSIGNED_INT, null);
            _shader.disableAttribs();

            return this;
        }

        This sendBuffersToBindedVao(){
            import std.algorithm;
            _attributes.values.map!(cachable => cachable.content)
                              .each!(b => b.sendToBindedVao);
            return this;
        }

        This sendBuffersToDefaultVao(){
            return this;
        }
    }//private
}//class EmbedddedRenderer

private void turnOffupdateFlag(Content, Key)(ref Cachable!Content[Key] cachables){
    import std.algorithm:each;
    cachables.values.each!(c => c.hasChanged = false);
}

///
private struct Cachable(T) {
    T content;
    bool hasChanged;
}//struct Cachable

private Cachable!T cachable(T)(T content){
    return Cachable!T(content, true);
}

private ref Cachable!Content updateCachable(Cachables:Cachable!Content[Key], Content, Key)(ref Cachables cachables, in Key key, Content newContent){
    import std.algorithm:canFind;
    bool keyExists = cachables.keys.canFind(key);
    if(keyExists){
        bool hasChanged = cachables[key].content != newContent;
        cachables[key].content = newContent;
        cachables[key].hasChanged = hasChanged;
    }else{
        cachables[key] = cachable(newContent);
    }
    return cachables[key];
}

private ref Cachable!Content updateCachable(Content)(ref Cachable!Content cachable, Content newContent){
    bool hasChanged = cachable.content != newContent;
    if(!hasChanged)return cachable;
    cachable.content = newContent;
    cachable.hasChanged = hasChanged;
    return cachable;
}

unittest{
    Cachable!int[string] cachables;
    cachables.updateCachable("foo", 1);
    assert(cachables["foo"].content == 1);
    assert(cachables["foo"].hasChanged == true);

    cachables["foo"].hasChanged = false;

    cachables.updateCachable("foo", 1);

    assert(cachables["foo"].content == 1);
    assert(cachables["foo"].hasChanged == false);
}

unittest{
    Cachable!int[string] cachables;
    cachables.updateCachable("foo", 1);
    assert(cachables["foo"].content == 1);
    assert(cachables["foo"].hasChanged == true);

    cachables["foo"].hasChanged = false;

    cachables.updateCachable("foo", 2);

    assert(cachables["foo"].content == 2);
    assert(cachables["foo"].hasChanged == true);
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
