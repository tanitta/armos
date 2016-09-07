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
            foreach (string key; _attrs.keys) {
                _shader.uniform(key, _attrs[key]);
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
        T attr(string Name, in Vector4f v){
            _attrs[Name] = v;
            return this;
        }
        
        ///
        T attr(string Name, in Color c){
            import std.conv;
            _attrs[Name] = Vector4f(c.r.to!float/255f, c.g.to!float/255f, c.b.to!float/255f, c.a.to!float/255f);
            return this;
        }

        ///
        ref Vector4f attr(string name){
            return _attrs[name];
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
        Vector4f[string] _attrs;
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
        _shader.loadSources(defaultVertesShaderSource, defaultFragmentShaderSource);
    }
}//class DefaultMaterial

private immutable string defaultVertesShaderSource = q{
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

private immutable string defaultFragmentShaderSource = q{
#version 330
    
in vec4 f_color;
in vec2 outtexCoord0;
in vec2 outtexCoord1;

uniform sampler2D tex0;
uniform sampler2D tex1;

void main(void) {
    // gl_FragColor = texture(tex0, outtexCoord0)*f_color;
    gl_FragColor = texture(tex0, outtexCoord0);
}
};
