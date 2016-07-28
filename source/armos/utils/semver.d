module armos.utils.semver;

///
struct SemVer{
    ///
    int major;
    
    ///
    int minor;
    
    ///
    int patch;
    
    ///
    this(in string semver){
        import std.algorithm;
        import std.array;
        import std.conv;
        immutable digits = semver.split(".").map!(n => n.to!int).array;
        major = digits[0];
        minor = digits[1];
        patch = digits[2];
    }
    
    ///
    this(in uint major, in uint minor, in uint patch){
        this.major = major;
        this.minor = minor;
        this.patch = patch;
    }
    
    ///
    int opCmp(in SemVer rhs)const{
        if(
            this.major == rhs.major &&
            this.minor == rhs.minor &&
            this.patch == rhs.patch
        ){
            return 0;
        }else if(this.major > rhs.major || 
                 this.major == rhs.major && this.minor > rhs.minor ||
                 this.major == rhs.major && this.minor == rhs.minor && this.patch > rhs.patch
        ){
            return 1;
        }else{
            return -1;
        }
    }
    
    ///
    SemVer opBinary(string op)(in SemVer rhs){
        static if (op == "+" || op == "-"){
             return mixin("SemVer( this.major" ~ op ~ "rhs.major, this.minor" ~ op ~ "rhs.minor, this.patch" ~ op ~ "rhs.patch)");
        }else{
            static assert(0, "Operator "~op~" not implemented");
        }
    } 
    
    ///
    string toString()const{
        import std.algorithm;
        import std.array;
        import std.conv;
        return [major, minor, patch].map!(n => n.to!string).join(".");
    }

}

unittest{
    assert(SemVer(1, 2, 3) == SemVer(1, 2, 3));
    assert(SemVer(1, 2, 4) != SemVer(1, 2, 3));
    
    assert(SemVer(1, 2, 3) < SemVer(1, 2, 4));
    assert(SemVer(1, 2, 4) > SemVer(1, 2, 3));
    assert(SemVer(1, 3, 3) > SemVer(1, 2, 3));
    assert(SemVer(2, 2, 3) > SemVer(1, 2, 3));
    
    assert(SemVer(1, 2, 3) >= SemVer(1, 2, 3));
    assert(SemVer(1, 2, 3) <= SemVer(1, 2, 3));
}

unittest{
    //valid operators
    assert(SemVer(1, 2, 3) + SemVer(1, 2, 3) == SemVer(2, 4, 6));
    assert(SemVer(2, 3, 4) - SemVer(1, 2, 3) == SemVer(1, 1, 1));
    
    //invalid operators
    assert(!__traits(compiles, {
        auto v = SemVer(2, 3, 4) * SemVer(1, 2, 3);
    }));
    assert(!__traits(compiles, {
        auto v = SemVer(2, 3, 4) / SemVer(1, 2, 3);
    }));
}
