module armos.graphics.material;
import armos.types;
import armos.graphics;

/++
材質を表すclassです．
+/
interface Material{
    public{
        ///
        Material begin();

        ///
        Material end();
        
        ///
        Material attr(string Name, in Color c);
        
        ///
        ref Color attr(string Name);
        
        ///
        Material texture(armos.graphics.Texture tex);

        ///
        armos.graphics.Texture texture();

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
            _shader.begin;
            if(_texture){
                _texture.begin;
            }
            return this;
        }

        ///
        T end(){
            if(_texture){
                _texture.end;
            }
            _shader.end;
            return this;
        }

        ///
        T attr(string Name, in Color c){
            _attr[Name] = c;
            return this;
        }

        ///
        ref Color attr(string name){
            return _attr[name];
        }

        ///
        T texture(armos.graphics.Texture tex){
            _texture = tex; 
            return this;
        }

        ///
        armos.graphics.Texture texture(){return _texture;}

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
        armos.types.Color[string] _attr;
        armos.graphics.Texture _texture;
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
    // f_color = vec4(1, 1, 1, 1);
    outtexCoord0 = (textureMatrix * texCoord0).xy;
    outtexCoord1 = (textureMatrix * texCoord1).xy;
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
    gl_FragColor = vec4(f_color.x, f_color.y, f_color.z, 1);
}
};
