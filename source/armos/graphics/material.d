module armos.graphics.material;
static import armos.types;
static import armos.graphics;

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
            if(_texture){
                _texture.begin;
            }
        }

        ///
        void end(){
            if(_texture){
                _texture.end;
            }
        }

        ///
        void diffuse(in armos.types.Color d){ _diffuse = d; }

        ///
        void diffuse(T)(in T r, in T g, in T b, in T a = T( armos.graphics.Color.limit )){ 
            _diffuse = armos.graphics.Color(r, g, b, a); 
        }

        ///
        armos.types.Color diffuse()const{return _diffuse; }

        ///
        void speculer(in armos.types.Color s){ _specular = s; }

        ///
        void speculer(T)(in T r, in T g, in T b, in T a = T( armos.graphics.Color.limit )){
            _specular = armos.graphics.Color(r, g, b, a); 
        }

        ///
        armos.types.Color speculer()const{return _specular; }

        ///
        void ambient(in armos.types.Color a){ _ambient = a; }

        ///
        void ambient(T)(in T r, in T g, in T b, in T a = T( armos.graphics.Color.limit )){
            _ambient = armos.graphics.Color(r, g, b, a); 
        }

        ///
        armos.types.Color ambient()const{return _ambient; }

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
        armos.types.Color _diffuse;
        armos.types.Color _specular;
        armos.types.Color _ambient;
        armos.graphics.Texture _texture;
        armos.graphics.Shader _shader;
    }//private
}//class Material

private immutable string defaultVertesShaderSource = q{
#version 330

in vec4 vertex;
in vec3 normal;
in vec3 tangent;
in vec4 texCoord0;
in vec4 texCoord1;
in vec4 color;

uniform mat4 mpv;
varying vec4 f_color;

void main(void) {
    gl_Position = mpv * vertex;
    f_color = color;
}
};

private immutable string defaultFragmentShaderSource = q{
#version 330
    
varying vec4 f_color;

void main(void) {
    gl_FragColor = vec4(f_color.x, f_color.y, f_color.z, 1);
}
};
