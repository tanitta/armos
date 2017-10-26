module armos.graphics.bufferbundle;

import armos.graphics.gl.vao;
import armos.graphics.mesh;
import armos.graphics.gl.buffer;
import armos.math;

/++
+/
class BufferBundle {
    public{
        ///
        this(){
            _vao    = new armos.graphics.Vao;
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
        auto attr(T)(in string name, T[] vectorArray,
                     in BufferUsageFrequency freq   = BufferUsageFrequency.Dynamic,
                     in BufferUsageNature    nature = BufferUsageNature.Draw)
        if(isVector!T){
            attrs[name].array(vectorArray, freq, nature);
            return this;
        }

        ///
        auto attr(V)(in string name, V[] array, in size_t numDimentions = 1,
                     in BufferUsageFrequency freq   = BufferUsageFrequency.Dynamic,
                     in BufferUsageNature    nature = BufferUsageNature.Draw)
        if(__traits(isArithmetic, V)){
            attrs[name].array(array, numDimentions, freq, nature);
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
