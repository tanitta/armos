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
        ref DynamicVertex attr(T)(in string name, in T v){
            this.attrs[name]= v;
            return this;
        }
        Attribute attr(in string name)const{
            return attrs[name];
        }
    }//public
}//struct Vertex

unittest{
    auto position = Vector4f(1f, 2f, 3f, 4f);
    auto vert = DynamicVertex().attr("position", position);
    assert(vert.attr("position") == position);
}
