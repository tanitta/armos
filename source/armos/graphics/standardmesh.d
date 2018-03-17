module armos.graphics.standardmesh;

import armos.graphics.gl.primitivemode;
import armos.graphics.standardvertex;

class StandardMesh{
    StandardVertex[] vertices;
    size_t[] indices;
    PrimitiveMode primitiveMode = PrimitiveMode.Triangles;
}
