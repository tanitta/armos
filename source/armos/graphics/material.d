module armos.graphics.material;
import armos.types;
import armos.math;
import armos.graphics.gl.texture;
import armos.graphics.gl.shader;

import armos.graphics.renderer;

import armos.graphics.gl.uniform;

/++
材質を表すinterfaceです．
+/
interface Material{
    public{
        ///
        Material begin();
        
        ///
        Material end();
        
        ///
        Material uniformImpl(in string name, NumericalUniform);

        ///
        // Uniform uniformImpl(in string);
        
        ///
        Material uniformImpl(in string name, Texture tex);
        //
        // ///
        // Texture texture(in string name);

        ///
        Shader shader();
        
        ///
        Material shader(Shader s);
        
        ///
        Material loadImage(in string pathInDataDir, in string name);

        ///
        Material sendToRenderer(Renderer);
    }//public

}//interface Material

// Material uniform(Material material, in string name, Texture texture){
//     return material.uniformImpl(name, Uniform(texture));
// };

Renderer material(Renderer renderer, Material material){
    material.sendToRenderer(renderer);
    return renderer;
}

///
mixin template MaterialImpl(){
    alias T = typeof(this);
    import armos.math;
    import armos.types:Color;
    import armos.graphics.renderer;
    public{
        ///
        T begin(){
            beginDefault;
            return this;
        }

        ///
        T end(){
            endDefault;
            return this;
        }
        
        ///
        T uniformImpl(in string name, NumericalUniform u){
            _uniforms[name] = u;
            return this;
        }

        ///
        T uniformImpl(in string name, Texture tex){
            _textures[name] = tex;
            return this;
        }

        ///
        Texture texture(in string name){return _textures[name];}

        ///
        Shader shader(){
            return _shader;
        }

        ///
        T shader(Shader s){
            _shader = s;
            return this;
        }

        ///
        T loadImage(in string pathInDataDir, in string name){
            import armos.graphics.image;
            auto image = new Image();
            image.load(pathInDataDir);
            uniformImpl(name, image.texture);
            return this;
        }
    }//public

    protected{
        T sendToRenderer(Renderer renderer){
            _uniforms.sendTo(_shader);
            _textures.sendTo(_shader);
            return this;
        }
    }

    private{
        NumericalUniform[string] _uniforms;
        Texture[string] _textures;
        Shader _shader;

        ///
        T beginDefault(){
            _shader.begin;
            _textures.begin;
            sendUniformsToShader;
            return this;
        }

        ///
        T endDefault(){
            _textures.end;
            _shader.end;
            return this;
        }

        T sendUniformsToShader(){
            _uniforms.sendTo(_shader);
            _textures.sendTo(_shader);
            return this;
        }
    }//private
   
}

void begin(Texture[string] textures){
    foreach (string key; textures.keys) {
        auto texture = textures[key];
        if(texture){
            texture.begin;
        }
    }
}

void end(Texture[string] textures){
    foreach_reverse (string key; textures.keys) {
        auto texture = textures[key];
        if(texture){
            texture.end;
        }
    }
}

void sendTo(U:E[K], E, K)(U uniform, Shader shader){
    foreach (int i, string key; uniform.keys) {
        static if(is(E == Texture)){
            shader.uniform(key, uniform[key], i);
        }else{
            shader.uniform(key, uniform[key]);
        }
    }
}

void sendTo(U:E[K], E, K)(U uniforms, Renderer renderer){
    foreach (int i, string key; uniforms.keys) {
        static if(is(E == Texture)){
            renderer.texture(key, uniforms[key]);
        }else{
            renderer.uniform(key, uniforms[key]);
        }
    }
}

///
class DefaultMaterial : Material{
    mixin MaterialImpl;
    
    ///
    this(){
        _shader = new armos.graphics.Shader;
        _shader.loadSources(defaultVertexShaderSource, "", defaultFragmentShaderSource);
    }
}//class DefaultMaterial

/++
+/
class CustomShaderMaterial : Material{
    mixin MaterialImpl;
    static CustomShaderMaterial loadFiles(in string shaderName){
        auto mat = new CustomShaderMaterial();
        mat.shader = new armos.graphics.Shader;
        mat.shader.load(shaderName);
        return mat;
    }

    static CustomShaderMaterial loadFiles(in string vertShaderPath, in string geomShaderPath, in string fragShaderPath){
        auto mat = new CustomShaderMaterial();
        mat.shader = new armos.graphics.Shader;
        mat.shader.loadFiles(vertShaderPath, geomShaderPath, fragShaderPath);
        return mat;
    }

    static CustomShaderMaterial loadString(in string vertShaderPath, in string geomShaderPath, in string fragShaderPath){
        auto mat = new CustomShaderMaterial();
        mat.shader = new armos.graphics.Shader;
        mat.shader.loadSources(vertShaderPath, geomShaderPath, fragShaderPath);
        return mat;
    }
}//class CustomShaderMaterial

///
class AutoReloadMaterial : Material{
    mixin MaterialImpl;
    
    import fswatch;
    
    ///
    this(in string shaderPath){
        _shaderName = shaderPath;
        
        import armos.utils.file;
        _watcher = FileWatch(absolutePath("."), true);
        
        _shader = new armos.graphics.Shader;
        _shader.load(_shaderName);
    }

    ///
    bool hasReloaded()const{
        return _hasReloaded;
    }

    ///
    T checkAndUpdateShader(){
        _hasReloaded = false;
        bool hasGotEvents;
        FileChangeEvent[] events;
        do{
            hasGotEvents = true;
            import std.exception;
            try{
                events = _watcher.getEvents();
            }catch(Exception e){
                hasGotEvents = false;
            }
        }while(!hasGotEvents);

        foreach (event; events){
            if(event.type == FileChangeEventType.modify && (event.path == _shaderName ~ ".frag" ||
                        event.path == _shaderName ~ ".geom" ||
                        event.path == _shaderName ~ ".vert") 
              ){
                _shader.clearLog
                       .load(_shaderName);
                _hasReloaded = _hasReloaded||true;
            }
        }
        return this;
    }

    private{
        string _shaderName;
        bool _hasReloaded = false;
        FileWatch _watcher;
    }
}//class DefaultMaterial


immutable string defaultVertexShaderSource = q{
#version 330


uniform mat4 viewMatrix;
uniform mat4 modelMatrix;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform mat4 modelViewProjectionMatrix;
uniform mat4 textureMatrix;

in vec4 position;
in vec3 normal;
in vec3 tangent;
in vec4 texCoord0;
in vec4 texCoord1;
in vec4 color;

out vec4 f_color;
out vec2 outtexCoord0;
out vec2 outtexCoord1;

void main(void) {
    gl_Position = modelViewProjectionMatrix * position;
    f_color = color;
    outtexCoord0 = texCoord0.xy;
    outtexCoord1 = texCoord1.xy;
}
};

immutable string defaultFragmentShaderSource = q{
#version 330
    
in vec4 f_color;
in vec2 outtexCoord0;
in vec2 outtexCoord1;

out vec4 fragColor;

uniform vec4      diffuse;
uniform sampler2D tex0;
uniform sampler2D tex1;

void main(void) {
    fragColor = texture(tex0, outtexCoord0)*diffuse;
    // fragColor = diffuse;
    // fragColor = vec4(1, 1, 1, 1);
}
};
