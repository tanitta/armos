module armos.graphics.standardvertex;

import armos.math;
import armos.graphics.dynamicvertex;

// Flow of allowed castability.
// L2 -> L1

////////////////////////////////////////////////////////////////
/// L2 Armos Embedded Layer

/// Prefix
/// - "L2"
/// - "Standard"
/// - "Armos"
struct StandardVertex {
    public{
        Vector4f position;
        Vector3f normal;
        Vector3f tangent;
        Vector4f texCoord0;
        Vector4f texCoord1;
        Vector3f color;

        DynamicVertex opCast(DynamicVertex)(){
            DynamicVertex dynamicVert;
            dynamicVert["position"]  = position;
            dynamicVert["normal"]    = normal;
            dynamicVert["tangent"]   = tangent;
            dynamicVert["texCoord0"] = texCoord0;
            dynamicVert["texCoord1"] = texCoord1;
            dynamicVert["color"]     = color;
            return dynamicVert;
        }
    }//public
}//struct Vertex

unittest{
    StandardVertex standardVert;
    standardVert.position = Vector4f(1f, 2f, 3f, 4);
    DynamicVertex dynamicVert = cast(DynamicVertex)standardVert;
    assert(dynamicVert["position"] == standardVert.position);
}
