module armos.graphics.bufferbundle;

import armos.graphics.vao;
import armos.graphics.mesh;
import armos.graphics.buffer;

/++
+/
class BufferBundle {
    public{
        ///
        this(){
            _vao    = new armos.graphics.Vao;
            // attr["vertex"]    = new Buffer(BufferType.Array);
            // attr["normal"]    = new Buffer(BufferType.Array);
            // attr["tangent"]   = new Buffer(BufferType.Array);
            // attr["texCoord0"] = new Buffer(BufferType.Array);
            // attr["texCoord1"] = new Buffer(BufferType.Array);
            // attr["color"]     = new Buffer(BufferType.Array);
            // attr["index"]    = new Buffer(BufferType.ElementArray);
        }
        
        ///
        ~this(){}
        
        ///
        Vao vao(){return _vao;}
        
        ///
        auto attr(in string name, Buffer buffer){
            attrs[name] = buffer;
            return this;
        }

        ///
        auto attr(in string name){
            return attrs[name];
        }

        // alias attrs this;
        Buffer[string] attrs;

        ///
        auto begin(){
            _vao.begin;
            return this;
        }

        ///
        auto end(){
            _vao.end;
            return this;
        }
    }//public

    private{
        Vao _vao;
    }//private
}//class BufferBundle
