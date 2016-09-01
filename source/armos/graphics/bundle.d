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
            updateShaderAttribs();
        }
        
        ///
        Bundle shader(Shader shader){
            _shader = shader;
            if(_bufferMesh) updateShaderAttribs();
            return this;
        }
        
        ///
        Bundle mesh(Mesh mesh, in BufferUsageFrequency freq, in BufferUsageNature nature){
            _bufferMesh = new BufferMesh(mesh, freq, nature);
            if(_shader) updateShaderAttribs();
            return this;
        }
        
        ///
        Bundle bufferMesh(BufferMesh bufferMesh){
            _bufferMesh = bufferMesh;
            if(_shader) updateShaderAttribs();
            return this;
        }
        
        ///
        Bundle updateShaderAttribs(){
            _bufferMesh.vao.begin();
            import std.algorithm;
            _bufferMesh.attribs.keys.filter!(key => key!="index")
                                    .each!((key){
                _bufferMesh.attribs[key].begin;
                _shader.setAttrib(key);
                _bufferMesh.attribs[key].end;
            });
            _bufferMesh.vao.end();
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
            const scopedVao    = scoped(_bufferMesh.vao);
            const scopedShader = scoped(_shader);
            const iboScope     = scoped(_bufferMesh.attribs["index"]);
            
            import armos.graphics.renderer;
            _shader.setUniform("modelViewMatrix", viewMatrix * modelMatrix);
            _shader.setUniform("projectionMatrix", projectionMatrix);
            _shader.setUniform("modelViewProjectionMatrix", modelViewProjectionMatrix);
            //TODO set valid matrix.
            //TODO set textureMatrix to shader
            
            _shader.enableAttribs();
                int elements;
                import derelict.opengl3.gl;
                glGetBufferParameteriv(GL_ELEMENT_ARRAY_BUFFER, GL_BUFFER_SIZE, &elements);
                import std.conv;
                immutable int size = (elements/GLushort.sizeof).to!int;
                glDrawElements(GL_TRIANGLES, size, GL_UNSIGNED_INT, null);
            _shader.disableAttribs();
        }
    }//public

    private{
        Shader _shader;
        BufferMesh _bufferMesh;
    }//private
}//class Bundle
