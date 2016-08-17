module armos.graphics.buffermesh;

import armos.graphics.vao;
import armos.graphics.mesh;
import armos.graphics.buffer;

/++
+/
class BufferMesh {
    public{
        ///
        this(Mesh mesh, in BufferUsageFrequency freq, in BufferUsageNature nature){
            _vao    = new armos.graphics.Vao;
            _vao.begin();
                attribs["vertices"]   = (new Buffer(BufferType.Array)).array(mesh.vertices, freq, nature);
                attribs["normals"]    = (new Buffer(BufferType.Array)).array(mesh.normals, freq, nature);
                attribs["tangents"]   = (new Buffer(BufferType.Array)).array(mesh.tangents, freq, nature);
                attribs["texCoords0"] = (new Buffer(BufferType.Array)).array(mesh.texCoords0, freq, nature);
                attribs["texCoords1"] = (new Buffer(BufferType.Array)).array(mesh.texCoords1, freq, nature);
                import std.algorithm;
                import std.array;
                import armos.types.color;
                attribs["colors"]     = (new Buffer(BufferType.Array)).array(mesh.colors.map!(c => armos.math.Vector4f(c.r, c.g, c.b, c.a)).array, freq, nature);
            _vao.end();
            
            attribs["indices"]    = (new Buffer(BufferType.ElementArray)).array(mesh.indices, freq, nature);
        }
        
        ///
        ~this(){}
        
        ///
        Vao vao(){return _vao;}
        
        ///
        // BufferMesh mesh(in Mesh mesh){
        //     return this;
        // }
        
        ///
        Buffer[string] attribs;
    }//public

    private{
        // Mesh _rawMesh;
        Vao _vao;
    }//private
}//class BufferMesh
