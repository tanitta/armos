module armos.graphics.material;
import armos.types;
import armos.graphics;

/++
材質を表すclassです．
+/
class Material {
    public{
        ///
        this(){
            this(defaultVertesShaderSource, defaultFragmentShaderSource);
        }
        
        ///
        this(in string vertexShaderSource, in string fragmentShaderSource){
            _shader = new armos.graphics.Shader;
            _shader.loadSources(vertexShaderSource, fragmentShaderSource);
        }
        
        ///
        this(armos.graphics.Shader s){
            _shader = s;
        }

        ///
        void begin(){
            _shader.begin;
            if(_texture){
                _texture.begin;
            }
        }

        ///
        void end(){
            if(_texture){
                _texture.end;
            }
            _shader.end;
        }
        
        void attr(string Name)(Color c){
            _attr[Name] = c;
        }
        
        Color attr(string Name)()const{
            return _attr[Name];
        }
        
        ///
        void texture(armos.graphics.Texture tex){ _texture = tex; }
        
        ///
        armos.graphics.Texture texture(){return _texture;}
        
        ///
        armos.graphics.Shader shader(){
            return _shader;
        }
        
        ///
        void shader(armos.graphics.Shader s){
            _shader = s;
        }
        
        ///
        void loadImage(in string pathInDataDir){
            auto image = new armos.graphics.Image();
            image.load(pathInDataDir);
        }
    }//public

    private{
        armos.types.Color[string] _attr;
        armos.graphics.Texture _texture;
        armos.graphics.Shader _shader;
    }//private
}//class Material

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
    f_color = vec4(1, 1, 1, 1);
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
