module armos.graphics.scopes;

import armos.math.matrix:Matrix4f;

/++
+/
struct ScopedModelMatrix {
    public{
        this(in Matrix4f m){begin;}
        ~this(){end;}
    }//public

    private{
        import std.stdio;
        void begin(){"begin".writeln;}
        void end(){"end".writeln;}
    }//private
}//struct ScopedModelMatrix

ScopedModelMatrix scopedModelMatrix(in Matrix4f m = Matrix4f.identity){
    return ScopedModelMatrix(m);
}

unittest{
    // import std.stdio;
    // auto s = scopedModelMatrix();
    // "hoge".writeln;
}
