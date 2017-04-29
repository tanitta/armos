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
        Material attr(string name, in Color c);
        
        ///
        Material attr(string name, in Vector2f v);
        
        ///
        Material attr(string name, in Vector3f v);
        
        ///
        Material attr(string name, in Vector4f v);
        
        ///
        ref Vector4f attr(string name);
        
        ///
        Material texture(in string name, armos.graphics.Texture tex);

        ///
        armos.graphics.Texture texture(in string name);

        ///
        armos.graphics.Shader shader();
        
        ///
        Material shader(armos.graphics.Shader s);
        
        ///
        Material loadImage(in string pathInDataDir);
    }//public

}//interface Material

///
mixin template MaterialImpl(){
    alias T = typeof(this);
    public{
        ///
        T begin(){
            pushMaterialStack(this);
            
            _shader.begin;
            foreach (string key; _textures.keys) {
                auto texture = _textures[key];
                if(texture){
                    texture.begin;
                }
            }
            import std.algorithm;
            import std.array;
            import armos.math;
            foreach (string key; _attrF.keys) {
                _shader.uniform(key, _attrF[key]);
            }
            
            foreach (string key; _attrI.keys) {
                _shader.uniform(key, _attrI[key]);
            }
            
            foreach (string key; _attrV2f.keys) {
                _shader.uniform(key, _attrV2f[key]);
            }
            
            foreach (string key; _attrV3f.keys) {
                _shader.uniform(key, _attrV3f[key]);
            }
            
            foreach (string key; _attrV4f.keys) {
                _shader.uniform(key, _attrV4f[key]);
            }
            
            foreach (int index, string key; _textures.keys){
                _shader.uniformTexture(key, _textures[key], index);
            }
            return this;
        }

        ///
        T end(){
            foreach (string key; _textures.keys) {
                auto texture = _textures[key];
                if(texture){
                    texture.end;
                }
            }
            _shader.end;
            
            popMaterialStack;
            return this;
        }
        
        ///
        T attr(string Name, in int v){
            _attrI[Name] = v;
            return this;
        }
        
        ///
        T attr(string Name, in float v){
            _attrF[Name] = v;
            return this;
        }
        
        ///
        T attr(string Name, in Vector2f v){
            _attrV2f[Name] = v;
            return this;
        }

        ///
        T attr(string Name, in Vector3f v){
            _attrV3f[Name] = v;
            return this;
        }
        
        ///
        T attr(string Name, in Vector4f v){
            _attrV4f[Name] = v;
            return this;
        }
        
        ///
        T attr(string Name, in Color c){
            import std.conv;
            _attrV4f[Name] = Vector4f(c.r.to!float/c.limit, c.g.to!float/c.limit, c.b.to!float/c.limit, c.a.to!float/c.limit);
            return this;
        }

        ///
        ref Vector4f attr(string name){
            return _attrV4f[name];
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
        T loadImage(in string pathInDataDir){
            auto image = new armos.graphics.Image();
            image.load(pathInDataDir);
            return this;
        }
    }//public

    private{
        int[string] _attrI;
        float[string] _attrF;
        Vector2f[string] _attrV2f;
        Vector3f[string] _attrV3f;
        Vector4f[string] _attrV4f;
        armos.graphics.Texture[string] _textures;
        armos.graphics.Shader _shader;
    }//private
   
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
            loadShaderUpdateIfModified;
            pushMaterialStack(this);
            
            _shader.begin;
            foreach (string key; _textures.keys) {
                auto texture = _textures[key];
                if(texture){
                    texture.begin;
                }
            }
            import std.algorithm;
            import std.array;
            import armos.math;
            foreach (string key; _attrF.keys) {
                _shader.uniform(key, _attrF[key]);
            }
            
            foreach (string key; _attrI.keys) {
                _shader.uniform(key, _attrI[key]);
            }
            
            foreach (string key; _attrV2f.keys) {
                _shader.uniform(key, _attrV2f[key]);
            }
            
            foreach (string key; _attrV3f.keys) {
                _shader.uniform(key, _attrV3f[key]);
            }
            
            foreach (string key; _attrV4f.keys) {
                _shader.uniform(key, _attrV4f[key]);
            }
            
            foreach (int index, string key; _textures.keys){
                _shader.uniformTexture(key, _textures[key], index);
            }
            
            return this;
        }
    
    private{
        string _shaderName;
        FileWatch _watcher;
        
        void loadShaderUpdateIfModified(){
            foreach (event; _watcher.getEvents()){
                if(event.path == _shaderName ~ ".frag" ||
                   event.path == _shaderName ~ ".geom" ||
                   event.path == _shaderName ~ ".vert" 
                ){
                    if(event.type == FileChangeEventType.modify){
                        //TODO
                        auto shaderTmp = new armos.graphics.Shader; 
                        import core.exception;
                        try{
                            shaderTmp.load(_shaderName);
                        }catch(AssertError err){
                            continue;
                        }
                        import std.stdio;
                        if(!shaderTmp.isLoaded)shaderTmp.log.writeln;
                        _shader = shaderTmp;
                        // _shader.load(_shaderName);
                    }
                }
            }
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
