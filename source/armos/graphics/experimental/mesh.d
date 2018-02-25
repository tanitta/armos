module armos.graphics.experimental.mesh;

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

        Attribute!ElementType attr(in string name){
            return _attrs[name];
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
