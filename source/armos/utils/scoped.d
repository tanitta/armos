module armos.utils.scoped;

///
template isScopable(S) {
    enum isScopable = __traits(hasMember, S, "begin") && __traits(hasMember, S, "end");
}//template isScopable
version(unittest){
    /++
    +/
    private struct Scopable {
        void begin(){}
        void end(){}
    }//struct Scopable

    private struct NoScopable {
        void foo(){}
    }//struct Scopable
}
unittest{
    assert(isScopable!Scopable);
    assert(!isScopable!NoScopable);
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

Scoped!T scoped(T)(T t)if(isScopable!T && (is(T == interface)) || is(T == class)){
    return Scoped!T(t);
}

Scoped!T scoped(T)(T t)if(isScopable!T && (is(T == struct))){
    return Scoped!T(t);
}
