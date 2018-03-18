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
        ref StandardVertex position(in Vector4f v){
            this._position = v;
            return this;
        }

        Vector4f position()const{
            return _position;
        }

        ref StandardVertex normal(in Vector3f v){
            this._normal = v;
            return this;
        }

        Vector3f normal()const{
            return _normal;
        }

        ref StandardVertex tangent(in Vector3f v){
            this._tangent = v;
            return this;
        }

        Vector3f tangent()const{
            return _tangent;
        }

        ref StandardVertex texCoord0(in Vector4f v){
            this._texCoord0 = v;
            return this;
        }

        Vector4f texCoord0()const{
            return _texCoord0;
        }

        ref StandardVertex texCoord1(in Vector4f v){
            this._texCoord1 = v;
            return this;
        }

        Vector4f texCoord1()const{
            return _texCoord1;
        }

        ref StandardVertex color(in Vector4f v){
            this._color = v;
            return this;
        }

        Vector4f color()const{
            return _color;
        }

        DynamicVertex opCast(DynamicVertex)(){
            DynamicVertex dynamicVert;
            dynamicVert["position"]  = _position;
            dynamicVert["normal"]    = _normal;
            dynamicVert["tangent"]   = _tangent;
            dynamicVert["texCoord0"] = _texCoord0;
            dynamicVert["texCoord1"] = _texCoord1;
            dynamicVert["color"]     = _color;
            return dynamicVert;
        }
    }//public
    private{
        Vector4f _position;
        Vector3f _normal;
        Vector3f _tangent;
        Vector4f _texCoord0;
        Vector4f _texCoord1;
        Vector4f _color;

    }//private
}//struct Vertex

unittest{
    StandardVertex standardVert;
    standardVert.position = Vector4f(1f, 2f, 3f, 4);
    DynamicVertex dynamicVert = cast(DynamicVertex)standardVert;
    assert(dynamicVert["position"] == standardVert.position);
}


unittest{
    auto standardVert = StandardVertex().position(Vector4f(1f, 2f, 3f, 4f));
    assert(standardVert.position == Vector4f(1f, 2f, 3f, 4f));
    const constvert = standardVert;
    assert(constvert.position == standardVert.position);
}
