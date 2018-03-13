module armos.graphics.vertex;
import armos.math;

// Flow of Castability.
// L3 -> L2 -> L1

/// L3 Armos Embedded Layer
/// Prefix
/// - L3
/// - Standard
/// - Armos
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

/// L2 Static Layer
struct StaticVertex(alias TP){
    public{
    }//public

    private{
    }//private
}//struct Vertex

/// L1 Dynamic Layer
struct DynamicVertex {
    public{
    }//public

    private{
    }//private
}//struct Vertex

/// L0 Raw OpenGL Layer
