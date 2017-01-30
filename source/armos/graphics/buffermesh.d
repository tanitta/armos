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
                attr["vertex"].array(mesh.vertices, freq, nature);
                attr["normal"].array(mesh.normals, freq, nature);
                attr["tangent"].array(mesh.tangents, freq, nature);
                attr["texCoord0"].array(mesh.texCoords0, freq, nature);
                attr["texCoord1"].array(mesh.texCoords1, freq, nature);
                import std.algorithm;
                import std.array;
                import armos.types.color;
                attr["color"].array(mesh.colors.map!(c => armos.math.Vector4f(c.r, c.g, c.b, c.a)).array, freq, nature);
                attr["index"].array(mesh.indices, 0, freq, nature);
            _vao.end();
        }
        
        this(){
            _vao    = new armos.graphics.Vao;
            attr["vertex"]    = new Buffer(BufferType.Array);
            attr["normal"]    = new Buffer(BufferType.Array);
            attr["tangent"]   = new Buffer(BufferType.Array);
            attr["texCoord0"] = new Buffer(BufferType.Array);
            attr["texCoord1"] = new Buffer(BufferType.Array);
            attr["color"]     = new Buffer(BufferType.Array);
            attr["index"]    = new Buffer(BufferType.ElementArray);
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
        Buffer[string] attr;
    }//public

    private{
        // Mesh _rawMesh;
        Vao _vao;
    }//private
}//class BufferMesh
