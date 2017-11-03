module armos.graphics.bufferentity;

import armos.graphics.gl.buffer;
import armos.graphics.gl.shader;
import armos.graphics.mesh;
import armos.graphics.material;
import armos.graphics.buffermesh;
import armos.graphics.bufferbundle;

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
        this(BufferBundle bufferBundle, Material material){
            _material = material;
            _bufferBundle = bufferBundle;
            updateShaderAttribs();
        }
        
        ///
        this(){}
        
        ///
        BufferEntity updateShaderAttribs(){
            auto scopedVao = _bufferBundle.vao.scoped;
            import std.algorithm;
            _bufferBundle.attrs.keys.filter!(key => _bufferBundle.attrs[key].type!=BufferType.ElementArray && _bufferBundle.attrs[key].type!=BufferType.DrawIndirect)
                                    .each!((key){
                                        if(_bufferBundle.attrs[key].size > 0){
                                            _bufferBundle.attrs[key].begin;
                                            _material.shader.attr(key);
                                            _bufferBundle.attrs[key].end;
                                        }
                                    });
            return this;
        }

        BufferEntity sendBuffersToBindedVao()in{
            assert(_material);
            assert(_material.shader);
        }body{
            import std.algorithm;
            _bufferBundle.attrs.keys.each!((key){
                _bufferBundle.attr(key).sendToBindedVao(_material.shader.attrLocation(key));
            });
            return this;
        }
        
        ///
        void begin(){
            _material.begin;
            _bufferBundle.vao.begin;
        }
        
        ///
        void end(){
            _bufferBundle.vao.end;
            _material.end;
        }
        
        ///
        BufferBundle bufferBundle(){
            return _bufferBundle;
        }
        
        ///
        BufferEntity bufferBundle(BufferBundle bb){
            _bufferBundle = bb;
            if(_material && _material.shader) updateShaderAttribs();
            return this;
        }
        
        ///
        BufferEntity mesh(Mesh mesh, in BufferUsageFrequency freq, in BufferUsageNature nature){
            _bufferBundle = new BufferMesh(mesh, freq, nature);
            if(_material && _material.shader) updateShaderAttribs();
            return this;
        }
        
        ///
        Material material(){
            return _material;
        }
        
        ///
        BufferEntity material(armos.graphics.Material m){
            _material = m;
            return this;
        }
        
        ///
        BufferEntity shader(Shader shader){
            if(_material)_material = new DefaultMaterial;
            _material.shader = shader;
            if(_bufferBundle) updateShaderAttribs();
            return this;
        }
        
        void draw(){
            sendBuffersToBindedVao;
            updateShaderAttribs;
            drawWithoutUpdate;
        }

        ///
        void drawWithoutUpdate(){
            pragma(msg, __FILE__, "(", __LINE__, "): ",
                   "TODO: rewrite");
            // const scopedVao      = scoped(_bufferBundle.vao);
            // const scopedMaterial = scoped(_material);
            // const iboScope       = scoped(_bufferBundle.attrs["index"]);
            //
            // import armos.graphics.renderer;
            // _material.shader.uniform("modelViewMatrix", viewMatrix * modelMatrix);
            // _material.shader.uniform("projectionMatrix", projectionMatrix);
            // _material.shader.uniform("modelViewProjectionMatrix", modelViewProjectionMatrix);
            // _material.shader.uniform("textureMatrix", textureMatrix);
            // _material.shader.enableAttribs();
            //     int elements;
            //     import derelict.opengl3.gl;
            //     glGetBufferParameteriv(GL_ELEMENT_ARRAY_BUFFER, GL_BUFFER_SIZE, &elements);
            //     import std.conv;
            //     immutable int size = (elements/GLuint.sizeof).to!int;
            //     glDrawElements(_primitiveMode, size, GL_UNSIGNED_INT, null);
            // _material.shader.disableAttribs();
        }
        
        void draw(in armos.graphics.PolyRenderMode renderMode){
            //TODO
            // import derelict.opengl3.gl;
            // glPolygonMode(GL_FRONT_AND_BACK, renderMode);
            // draw;
            // glPolygonMode(GL_FRONT_AND_BACK, currentStyle.polyRenderMode);
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
        
        ///
        BufferEntity primitiveMode(in armos.graphics.PrimitiveMode mode){
            _primitiveMode = mode;
            return this;
        }
        
        ///
        armos.graphics.PrimitiveMode primitiveMode()const{
            return _primitiveMode;
        }
    }//public

    private{
        armos.graphics.BufferBundle _bufferBundle;
        armos.graphics.Material _material;
        armos.graphics.PrimitiveMode _primitiveMode = armos.graphics.PrimitiveMode.Triangles;
    }//private
}//class BufferEntity
