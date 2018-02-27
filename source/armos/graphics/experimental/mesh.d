module armos.graphics.experimental.mesh;

import armos.graphics.bufferbundle;
import armos.graphics.gl.primitivemode;

///
struct Attribute(ElementType) {
    size_t dimention;
    ElementType[] elements;
}//struct Attribute

///
class Mesh(ElementType) {
    private: alias This = typeof(this);
    public{
        PrimitiveMode primitiveMode = PrimitiveMode.Triangles;
        This attr(in string name, ElementType[] arr, in size_t dimention){
            import std.algorithm.searching;
            if(!_attrs.keys.canFind(name))
                _attrs[name] = Attribute!ElementType();
            _attrs[name].dimention = dimention;
            _attrs[name].elements = arr;
            return this;
        }

        This attr(V)(in string name, V[] arr){
            V.elementType[] serialized;
            foreach (v; arr) {
                serialized ~= v.array[];
            }
            this.attr(name, serialized, V.dimention);
            return this;
        }

        Attribute!ElementType attr(in string name){
            return _attrs[name];
        }

        BufferBundle opCast()const{
            auto bb = new BufferBundle();
            import std.array:byPair;
            foreach (pair; _attrs.byPair) {
                auto name = pair[0];
                auto attr = pair[1];
                bb.attr(name, attr.elements, attr.dimention);
            }
            return bb;
        }
    }//public

    private{
        Attribute!ElementType[string] _attrs;
    }//private
}//class Mesh

unittest{
    Mesh!float mesh = new Mesh!float();
    mesh.attr("foo", [0f, 1f, 2f], 1);
    assert(mesh.attr("foo").elements == [0f, 1f, 2f]);
    assert(mesh.attr("foo").elements == [0f, 1f, 2f]);
    assert(mesh.attr("foo").dimention == 1);
}
