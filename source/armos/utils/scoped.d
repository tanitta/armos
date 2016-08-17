module armos.utils.scoped;

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

Scoped!T scoped(T)(T t){
    return Scoped!T(t);
}
