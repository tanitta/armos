module armos.graphics.bundle;

import armos.graphics.vao;
import armos.graphics.shader;
import armos.graphics.mesh;
import armos.utils.scoped;

/++
+/
class Bundle {
    public{
        this(){
            _vao = new Vao();
        }
        
        Bundle shader(Shader shader){
            _shader = shader;
            return this;
        }
        
        Bundle mesh(Mesh mesh){
            _mesh = mesh;
            return this;
        }
        
        void begin(){
            _shader.begin;
            _vao.begin;
        }
        
        void end(){
            _vao.end;
            _shader.end;
        }
        
        void draw(){
            auto scopedShader = scoped(_shader);
            auto scopedVao    = scoped(_vao);
        }
    }//public

    private{
        Vao _vao;
        Shader _shader;
        Mesh _mesh;
    }//private
}//class Bundle
