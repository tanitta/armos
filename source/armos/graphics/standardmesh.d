module armos.graphics.standardmesh;

import armos.graphics.gl.primitivemode;
import armos.graphics.standardvertex;
import armos.graphics.dynamicmesh;

class StandardMesh{
    StandardVertex[] vertices;
    size_t[] indices;
    PrimitiveMode primitiveMode = PrimitiveMode.Triangles;

    DynamicMesh opCast(DynamicMesh)(){
        import std.algorithm;
        import std.functional;
        import std.conv;
        import std.array;
        auto result = new DynamicMesh;
        import armos.graphics.dynamicvertex;
        result.vertices = this.vertices.map!(vert => vert.to!DynamicVertex).array;
        result.indices = this.indices;
        result.primitiveMode = this.primitiveMode;
        return result;
    }
}

unittest{
    auto standardMesh = new StandardMesh();
    import armos.math;
    auto standardVertex = StandardVertex();
    standardMesh.vertices ~= StandardVertex().position(Vector4f(1f, 2f, 3f, 4f));
    import std.conv;
    auto dynamicMesh = standardMesh.to!DynamicMesh;
    assert(standardMesh.vertices[0].position == dynamicMesh.vertices[0]["position"]);
}   
