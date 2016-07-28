module armos.graphics.bundle;

import armos.graphics.vao;
import armos.graphics.shader;
import armos.graphics.mesh;

/++
+/
class Bundle {
    public{
        this(){
            _vao = new Vao();
        }
        
        Bundle bind(Shader shader){
            _shader = shader;
            return this;
        }
        
        Bundle bind(Mesh mesh){
            _mesh = mesh;
            return this;
        }
        
        void begin(){
            _vao.begin;
        }
        
        void end(){
            _vao.end;
        }
    }//public

    private{
        Vao _vao;
        Shader _shader;
        Mesh _mesh;
    }//private
}//class Bundle
