module armos.graphics.dynamicmesh;

import armos.graphics.gl.primitivemode;
import armos.graphics.dynamicvertex;

class DynamicMesh{
    DynamicVertex[] vertices;
    size_t[] indices;
    PrimitiveMode primitiveMode = PrimitiveMode.Triangles;
}
