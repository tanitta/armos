module armos.graphics.buffermesh;

import armos.graphics.gl.vao;
import armos.graphics.gl.buffer;
import armos.graphics.bufferbundle;
import armos.graphics.mesh;

/++
+/
class BufferMesh : BufferBundle{
    public{
        // alias attrs this;

        ///
        this(Mesh mesh, in BufferUsageFrequency freq, in BufferUsageNature nature){
            this();
            _vao.begin();
                attrs["vertex"].array(mesh.vertices, freq, nature);
                attrs["normal"].array(mesh.normals, freq, nature);
                attrs["tangent"].array(mesh.tangents, freq, nature);
                attrs["texCoord0"].array(mesh.texCoords0, freq, nature);
                attrs["texCoord1"].array(mesh.texCoords1, freq, nature);
                import std.algorithm;
                import std.array;
                import std.conv;
                import armos.math:Vector4f;
                import armos.types.color;
                attrs["color"].array(mesh.colors.map!(c => c.to!Vector4f).array, freq, nature);
                attrs["index"].array(mesh.indices, 0, freq, nature);
            _vao.end();
        }
        
        this(){
            super();
            attrs["vertex"]    = new Buffer(BufferType.Array);        // Vector4f
            attrs["normal"]    = new Buffer(BufferType.Array);        // Vector3f
            attrs["tangent"]   = new Buffer(BufferType.Array);        // Vector3f
            attrs["texCoord0"] = new Buffer(BufferType.Array);        // Vector4f
            attrs["texCoord1"] = new Buffer(BufferType.Array);        // Vector4f
            attrs["color"]     = new Buffer(BufferType.Array);        // Vector4f
            attrs["index"]     = new Buffer(BufferType.ElementArray); // int
        }
        
        ///
        ~this(){}
        
        ///
        Buffer vertex(){return attrs["buffer"];}

        ///
        Buffer normal(){return attrs["normal"];}

        ///
        Buffer tangent(){return attrs["tangent"];}

        ///
        Buffer texCoord0(){return attrs["texCoord0"];}

        ///
        Buffer texCoord1(){return attrs["texCoord1"];}

        ///
        alias texCoord = texCoord0;

        ///
        Buffer color(){return attrs["color"];}

        ///
        Buffer index(){return attrs["index"];}

    }//public

    private{
        // Mesh _rawMesh;
        Vao _vao;
    }//private
}//class BufferMesh
