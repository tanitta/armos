module armos.app.windowconfig;

static import armos.math;
import armos.utils.semver;
import std.conv;

/++
+/
class WindowConfig {
    public{
        int height()const{return _height;}
        void height(in int h){_height = h;}
        
        int width()const{return _width;}
        void width(in int h){_width = h;}
        
        armos.math.Vector2i position()const{return _position;}
        void position(in armos.math.Vector2i p){_position = p;}
        
        int glVersionMajor()const{return _glVersion.major;}
        int glVersionMinor()const{return _glVersion.minor;}
        
        SemVer glVersion()const{
            return _glVersion;
        }
        
        void glVersion(in string v){
            import std.algorithm;
            import std.array;
            immutable digits = v.split(".").map!(n => n.to!int).array;
            glVersion = SemVer(digits[0], digits[1], digits[2]);
        }
        
        void glVersion(in SemVer v){
            _glVersion = v;
        }
        
        void glVersionMajor(in int versionMajor){_glVersion.major = versionMajor;}
        void glVersionMinor(in int versionMinor){_glVersion.minor = versionMinor;}
    }//public

    private{
        int _height;
        int _width;
        armos.math.Vector2i _position;
        SemVer _glVersion = SemVer(3, 2, 0);
    }//private
}//interface WindowConfig
// WindowConfig should be able to handle float version.

unittest{
    auto config = new WindowConfig;
    config.glVersion = "3.3.0";
    assert(config.glVersionMajor == 3);
    assert(config.glVersionMinor == 3);
    assert(config.glVersion.to!string == "3.3.0");
}
