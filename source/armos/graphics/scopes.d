module armos.graphics.scopes;

import armos.math.matrix:Matrix4f;

// /++
// +/
// struct ScopedModelMatrix {
//     public{
//         this(in Matrix4f m){begin;}
//         ~this(){end;}
//     }//public
//
//     private{
//         import std.stdio;
//         void begin(){"begin".writeln;}
//         void end(){"end".writeln;}
//     }//private
// }//struct ScopedModelMatrix
//
// ScopedModelMatrix scopedModelMatrix(in Matrix4f m = Matrix4f.identity){
//     return ScopedModelMatrix(m);
// }

/++
+/
// struct Scoped(T) {
//     public{
//         ///
//         this(T t){
//             _t = t;
//             _t.begin;
//         }
//        
//         ///
//         ~this(){
//             _t.end;
//         }
//     }//public
//
//     private{
//         T _t;
//     }//private
// }//struct Scoped

unittest{
    // import std.stdio;
    // auto s = scopedModelMatrix();
    // "hoge".writeln;
}

/++
+/
struct Scoped(T){
    public{
        this(T t){
            _t = t;
            _t.begin;
        }
        ~this(){
            _t.end;
        }
    }//public

    private{
        T _t;
    }//private
}//struct ScopedShader

Scoped!T scoped(T)(T t = new T()){
    return Scoped!T(t);
}
