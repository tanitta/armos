module armos.graphics.vertex;
import armos.math;

import armos.graphics.gl.attribute;

// Flow of allowed castability.
// L3 -> L2 -> L1

////////////////////////////////////////////////////////////////
/// L3 Armos Embedded Layer

/// Prefix
/// - "L3"
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
    }//public

    private{
    }//private
}//struct Vertex

////////////////////////////////////////////////////////////////
/// L2 Static Layer
/// Set type of Attribute as tuple on defining.

/// Prefix
/// - "L2"
/// - "Static"
struct StaticVertex(alias TP){
    public{
    }//public

    private{
    }//private
}//struct Vertex

////////////////////////////////////////////////////////////////
/// L1 Dynamic Layer
/// Use valiant.

/// Prefix
/// - "L1"
/// - "Dynamic"
struct DynamicVertex {
    public{
        V attr
    }//public

    private{
    }//private
}//struct Vertex

/// L0 Raw OpenGL Layer
/// None
