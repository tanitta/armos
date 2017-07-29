module armos.graphics.material;
import armos.types;
import armos.math;
import armos.graphics;

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
        Material uniform(in string name, in int i);
        
        ///
        Material uniform(in string name, in float f);

        ///
        Material uniform(in string name, in Color c);
        
        ///
        Material uniform(in string name, in Vector2f v);
        
        ///
        Material uniform(in string name, in Vector3f v);
        
        ///
        Material uniform(in string name, in Vector4f v);
        
        ///
        ref Vector4f uniform(in string name);
        
        ///
        Material texture(in string name, armos.graphics.Texture tex);

        ///
        armos.graphics.Texture texture(in string name);

        ///
        armos.graphics.Shader shader();
        
        ///
        Material shader(armos.graphics.Shader s);
        
        ///
        Material loadImage(in string pathInDataDir, in string name);
    }//public

}//interface Material

///
mixin template MaterialImpl(){
    alias T = typeof(this);
    import armos.math;
    import armos.types:Color;
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
        T uniform(in string Name, in int v){
            _uniformsI[Name] = v;
            return this;
        }
        
        ///
        T uniform(in string Name, in float v){
            _uniformsF[Name] = v;
            return this;
        }
        
        ///
        T uniform(in string Name, in Vector2f v){
            _uniformsV2f[Name] = v;
            return this;
        }

        ///
        T uniform(in string Name, in Vector3f v){
            _uniformsV3f[Name] = v;
            return this;
        }
        
        ///
        T uniform(in string Name, in Vector4f v){
            _uniformsV4f[Name] = v;
            return this;
        }
        
        ///
        T uniform(in string Name, in Color c){
            import std.conv;
            _uniformsV4f[Name] = Vector4f(c.r.to!float/c.limit, c.g.to!float/c.limit, c.b.to!float/c.limit, c.a.to!float/c.limit);
            return this;
        }

        ///
        ref Vector4f uniform(in string name){
            return _uniformsV4f[name];
        }

        ///
        T texture(in string name, armos.graphics.Texture tex){
            _textures[name] = tex;
            return this;
        }

        ///
        armos.graphics.Texture texture(in string name){return _textures[name];}

        ///
        armos.graphics.Shader shader(){
            return _shader;
        }

        ///
        T shader(armos.graphics.Shader s){
            _shader = s;
            return this;
        }

        ///
        T loadImage(in string pathInDataDir, in string name){
            auto image = new armos.graphics.Image();
            image.load(pathInDataDir);
            texture(name, image.texture);
            return this;
        }
    }//public

    private{
        int[string] _uniformsI;
        float[string] _uniformsF;
        Vector2f[string] _uniformsV2f;
        Vector3f[string] _uniformsV3f;
        Vector4f[string] _uniformsV4f;
        armos.graphics.Texture[string] _textures;
        armos.graphics.Shader _shader;

        ///
        T beginDefault(){
            import armos.graphics:pushMaterialStack;
            pushMaterialStack(this);
            _shader.begin;
            _textures.begin;
            sendUniformsToShader;
            return this;
        }

        ///
        T endDefault(){
            _textures.end;
            _shader.end;
            
            import armos.graphics:popMaterialStack;
            popMaterialStack;
            return this;
        }

        T sendUniformsToShader(){
            _uniformsF.sendTo(_shader);
            _uniformsI.sendTo(_shader);
            _uniformsV2f.sendTo(_shader);
            _uniformsV3f.sendTo(_shader);
            _uniformsV4f.sendTo(_shader);
            _textures.sendTo(_shader);
            return this;
        }
    }//private
   
}

void begin(armos.graphics.Texture[string] textures){
    foreach (string key; textures.keys) {
        auto texture = textures[key];
        if(texture){
            texture.begin;
        }
    }
}

void end(armos.graphics.Texture[string] textures){
    foreach_reverse (string key; textures.keys) {
        auto texture = textures[key];
        if(texture){
            texture.end;
        }
    }
}

void sendTo(U:E[K], E, K)(U uniform, armos.graphics.Shader shader){
    foreach (int i, string key; uniform.keys) {
        static if(is(E == armos.graphics.Texture)){
            shader.uniformTexture(key, uniform[key], i);
        }else{
            shader.uniform(key, uniform[key]);
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
    T begin(){
        checkAndUpdateShader;
        beginDefault;
        return this;
    }

    private{
        string _shaderName;
        FileWatch _watcher;

        T checkAndUpdateShader(){
            foreach (event; _watcher.getEvents()){
                if(event.type == FileChangeEventType.modify && (event.path == _shaderName ~ ".frag" ||
                                                                event.path == _shaderName ~ ".geom" ||
                                                                event.path == _shaderName ~ ".vert") 
                ){
                    _shader.clearLog;
                    _shader.load(_shaderName);
                }
            }
            return this;
        }
    }
}//class DefaultMaterial

immutable string defaultVertexShaderSource = q{
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
}
};
