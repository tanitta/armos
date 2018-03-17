module armos.graphics.dynamicvertex;

import armos.math;
import armos.graphics.gl.attribute;

// Flow of allowed castability.
// L2 -> L1

/// Prefix
/// - "L1"
/// - "Dynamic"
struct DynamicVertex {
    public{
        alias attrs this;
        Attribute[string] attrs;
    }//public
}//struct Vertex
