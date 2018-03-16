module armos.graphics.standardmesh;

import armos.graphics.gl.primitivemode;
import armos.graphics.vertex;

class StandardMesh{
    StandardVertex[] vertices;
    size_t[] indices;
    PrimitiveMode primitiveMode = PrimitiveMode.Triangles;
}
