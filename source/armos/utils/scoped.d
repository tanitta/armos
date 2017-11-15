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
        this(T t, in bool isActive = true){
            _t = t;
            _isActive = isActive;
            if(_isActive) _t.begin;
        }

        ~this(){
            if(_isActive) _t.end;
        }
    }//public

    private{
        T _t;
        bool _isActive;
    }//private
}//struct ScopedShader

Scoped!T scoped(T)(T t)if(isScopable!T && (is(T == interface)) || is(T == class)){
    return Scoped!T(t, t !is null);
}

Scoped!T scoped(T)(T t, in bool isActive)if(isScopable!T && (is(T == interface)) || is(T == class)){
    return Scoped!T(t, isActive);
}

Scoped!T scoped(T)(T t, in bool isActive = true)if(isScopable!T && (is(T == struct))){
    return Scoped!T(t, isActive);
}
