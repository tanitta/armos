module armos.graphics.dynamicmesh;

import armos.graphics.gl.primitivemode;
import armos.graphics.dynamicvertex;

class DynamicMesh{
    DynamicVertex[] vertices;
    uint[] indices;
    PrimitiveMode primitiveMode = PrimitiveMode.Triangles;
}
