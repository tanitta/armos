module armos.graphics.experimental.primitives.box;

import armos.math;
import armos.graphics.gl.primitivemode;
import armos.graphics.standardmesh;
import armos.graphics.standardvertex;

StandardMesh boxMesh(in Vector4f position, in Vector3f size){
    auto halfSize = size*0.5;
    auto mesh = new StandardMesh();
    mesh.primitiveMode = PrimitiveMode.Triangles;

    mesh.vertices ~= StandardVertex().position(Vector4f(-halfSize[0], -halfSize[1], -halfSize[2], 1f));
    mesh.vertices ~= StandardVertex().position(Vector4f(halfSize[0],  -halfSize[1], -halfSize[2], 1f));
    mesh.vertices ~= StandardVertex().position(Vector4f(halfSize[0],  halfSize[1],  -halfSize[2], 1f));
    mesh.vertices ~= StandardVertex().position(Vector4f(-halfSize[0], halfSize[1],  -halfSize[2], 1f));

    mesh.vertices ~= StandardVertex().position(Vector4f(-halfSize[0], halfSize[1],  halfSize[2],  1f));
    mesh.vertices ~= StandardVertex().position(Vector4f(halfSize[0],  halfSize[1],  halfSize[2],  1f));
    mesh.vertices ~= StandardVertex().position(Vector4f(halfSize[0],  -halfSize[1], halfSize[2],  1f));
    mesh.vertices ~= StandardVertex().position(Vector4f(-halfSize[0], -halfSize[1], halfSize[2],  1f));

    import std.algorithm;
    mesh.vertices.each!((vert){vert.position += position;});


    mesh.indices = [
        0, 2, 1,
        0, 3, 2,

        4, 6, 5,
        4, 7, 6, 

        2, 3, 5,
        3, 4, 5, 

        0, 1, 6,
        0, 6, 7, 

        1, 2, 5,
        1, 5, 6,

        0, 7, 3,
        3, 7, 4, 
    ];

    return mesh;
}
