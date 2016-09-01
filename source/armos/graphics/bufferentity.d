module armos.graphics.bufferentity;

import armos.graphics;
import armos.graphics.mesh;
import armos.graphics.material;
import armos.graphics.buffer;
import armos.graphics.buffermesh;
import armos.graphics.shader;

/++
+/
class BufferEntity {
    import armos.utils.scoped;
    public{
        ///
        this(Mesh mesh, Material material, in BufferUsageFrequency freq, in BufferUsageNature nature){
            this(new BufferMesh(mesh, freq, nature), material);
        }
        
        ///
        this(BufferMesh bufferMesh, Material material){
            _material = material;
            _bufferMesh = bufferMesh;
            updateShaderAttribs();
        }
        
        ///
        this(){}
        
        ///
        BufferEntity updateShaderAttribs(){
            _bufferMesh.vao.begin();
            import std.algorithm;
            _bufferMesh.attribs.keys.filter!(key => key!="index")
                                    .each!((key){
                _bufferMesh.attribs[key].begin;
                _material.shader.setAttrib(key);
                _bufferMesh.attribs[key].end;
            });
            _bufferMesh.vao.end();
            return this;
        }
        
        ///
        void begin(){
            _material.begin;
            _bufferMesh.vao.begin;
        }
        
        ///
        void end(){
            _bufferMesh.vao.end;
            _material.end;
        }
        
        ///
        const(BufferMesh) bufferMesh(){
            return _bufferMesh;
        }
        
        ///
        BufferEntity bufferMesh(BufferMesh bm){
            _bufferMesh = bm;
            if(_material && _material.shader) updateShaderAttribs();
            return this;
        }
        
        ///
        BufferEntity mesh(Mesh mesh, in BufferUsageFrequency freq, in BufferUsageNature nature){
            _bufferMesh = new BufferMesh(mesh, freq, nature);
            if(_material && _material.shader) updateShaderAttribs();
            return this;
        }
        
        ///
        const(Material) material(){
            return _material;
        }
        
        ///
        BufferEntity material(armos.graphics.Material m){
            _material = m;
            return this;
        }
        
        ///
        BufferEntity shader(Shader shader){
            if(_material)_material = new Material;
            _material.shader = shader;
            if(_bufferMesh) updateShaderAttribs();
            return this;
        }
        
        ///
        void draw(){
            const scopedVao    = scoped(_bufferMesh.vao);
            const scopedShader = scoped(_material.shader);
            const iboScope     = scoped(_bufferMesh.attribs["index"]);
            
            import armos.graphics.renderer;
            _material.shader.setUniform("modelViewMatrix", viewMatrix * modelMatrix);
            _material.shader.setUniform("projectionMatrix", projectionMatrix);
            _material.shader.setUniform("modelViewProjectionMatrix", modelViewProjectionMatrix);
            //TODO set valid matrix.
            //TODO set textureMatrix to shader
            
            _material.shader.enableAttribs();
                int elements;
                import derelict.opengl3.gl;
                glGetBufferParameteriv(GL_ELEMENT_ARRAY_BUFFER, GL_BUFFER_SIZE, &elements);
                import std.conv;
                immutable int size = (elements/GLushort.sizeof).to!int;
                glDrawElements(GL_TRIANGLES, size, GL_UNSIGNED_INT, null);
            _material.shader.disableAttribs();
        }
        
        void draw(in armos.graphics.PolyRenderMode renderMode){
            import derelict.opengl3.gl;
            glPolygonMode(GL_FRONT_AND_BACK, getGLPolyRenderMode(renderMode));
            draw;
            glPolygonMode(GL_FRONT_AND_BACK, getGLPolyRenderMode(currentStyle.polyRenderMode));
        }
        
        /++
            entityをワイヤフレームで描画します．
        +/
        void drawWireFrame(){
            draw(armos.graphics.PolyRenderMode.WireFrame);
        };
        
        /++
            entityの頂点を点で描画します．
        +/
        void drawVertices(){
            draw(armos.graphics.PolyRenderMode.Points);
        };
        
        /++
            meshの面を塗りつぶして描画します．
        +/
        void drawFill(){
            draw(armos.graphics.PolyRenderMode.Fill);
        };
    }//public

    private{
        armos.graphics.BufferMesh _bufferMesh;
        armos.graphics.Material _material;
    }//private
}//class BufferEntity
