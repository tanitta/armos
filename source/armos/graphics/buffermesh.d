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
            this();
            _vao.begin();
                attribs["vertex"].array(mesh.vertices, freq, nature);
                attribs["normal"].array(mesh.normals, freq, nature);
                attribs["tangent"].array(mesh.tangents, freq, nature);
                attribs["texCoord0"].array(mesh.texCoords0, freq, nature);
                attribs["texCoord1"].array(mesh.texCoords1, freq, nature);
                import std.algorithm;
                import std.array;
                import armos.types.color;
                attribs["color"].array(mesh.colors.map!(c => armos.math.Vector4f(c.r, c.g, c.b, c.a)).array, freq, nature);
                attribs["index"].array(mesh.indices, 0, freq, nature);
            _vao.end();
        }
        
        this(){
            _vao    = new armos.graphics.Vao;
            attribs["vertex"]    = new Buffer(BufferType.Array);
            attribs["normal"]    = new Buffer(BufferType.Array);
            attribs["tangent"]   = new Buffer(BufferType.Array);
            attribs["texCoord0"] = new Buffer(BufferType.Array);
            attribs["texCoord1"] = new Buffer(BufferType.Array);
            attribs["color"]     = new Buffer(BufferType.Array);
            attribs["index"]    = new Buffer(BufferType.ElementArray);
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
