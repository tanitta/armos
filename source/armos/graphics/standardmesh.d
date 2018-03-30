module armos.graphics.standardmesh;

import armos.graphics.gl.primitivemode;
import armos.graphics.standardvertex;
import armos.graphics.dynamicmesh;

class StandardMesh{
    private{
        StandardVertex[] _vertices;
        uint[] _indices;
        PrimitiveMode _primitiveMode = PrimitiveMode.Triangles;
    }

    PrimitiveMode primitiveMode()const{
        return _primitiveMode;
    }

    StandardMesh primitiveMode(PrimitiveMode mode){
        _primitiveMode = mode;
        return this;
    }

    ref StandardVertex[] vertices(){
        return _vertices;
    }

    StandardMesh vertices(StandardVertex[] vs){
        _vertices = vs;
        return this;
    }

    ref uint[] indices(){
        return _indices;
    }

    StandardMesh indices(uint[] indices){
        _indices = indices;
        return this;
    }

    DynamicMesh opCast(DynamicMesh)(){
        import std.algorithm;
        import std.functional;
        import std.conv;
        import std.array;
        auto result = new DynamicMesh;
        import armos.graphics.dynamicvertex;
        result.vertices = this.vertices.map!(vert => vert.to!DynamicVertex).array;
        result.indices = this.indices;
        result.primitiveMode = this._primitiveMode;
        return result;
    }
}

// StandardMesh vertices(StandardMesh mesh, StandardVertex[] vs){
//     mesh.vertices = vs;
//     return mesh;
// }

unittest{
    auto standardMesh = new StandardMesh();
    import armos.math;
    auto standardVertex = StandardVertex();
    standardMesh.vertices ~= StandardVertex().position(Vector4f(1f, 2f, 3f, 4f));
    import std.conv;
    auto dynamicMesh = standardMesh.to!DynamicMesh;
    assert(standardMesh.vertices[0].position == dynamicMesh.vertices[0]["position"]);
}   
