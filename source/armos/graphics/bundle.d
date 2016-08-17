module armos.graphics.bundle;

import armos.graphics.vao;
import armos.graphics.buffer;
import armos.graphics.buffermesh;
import armos.graphics.shader;
import armos.graphics.mesh;
import armos.utils.scoped;

/++
+/
class Bundle {
    public{
        ///
        this(Mesh mesh, Shader shader, in BufferUsageFrequency freq, in BufferUsageNature nature){
            this(new BufferMesh(mesh, freq, nature), shader);
        }
        
        ///
        this(BufferMesh bufferMesh, Shader shader){
            _shader = shader;
            _bufferMesh = bufferMesh;
            
            //TODO bind attribs to shader.
            //e.g.
            // attribs["vertices"].begin;
            // _shader.setAttrib("coord");
            // attribs["vertices"].end;
        }
        
        ///
        Bundle shader(Shader shader){
            _shader = shader;
            return this;
        }
        
        ///
        Bundle mesh(Mesh mesh, in BufferUsageFrequency freq, in BufferUsageNature nature){
            _bufferMesh = new BufferMesh(mesh, freq, nature);
            return this;
        }
        
        ///
        void begin(){
            _shader.begin;
            _bufferMesh.vao.begin;
        }
        
        ///
        void end(){
            _bufferMesh.vao.end;
            _shader.end;
        }
        
        ///
        void draw(){
            auto scopedVao    = scoped(_bufferMesh.vao);
            auto scopedShader = scoped(_shader);
        }
    }//public

    private{
        Shader _shader;
        BufferMesh _bufferMesh;
    }//private
}//class Bundle
