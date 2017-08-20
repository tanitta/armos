module armos.app.windowconfig;

import armos.math;
import armos.utils.semver;
import std.conv;

/++
+/
class WindowConfig {
    public{
        ///
        int height()const{return _height;}

        ///
        typeof(this) height(in int h){_height = h;return this;}
        
        ///
        int width()const{return _width;}

        ///
        typeof(this) width(in int h){_width = h;return this;}
        
        ///
        Vector2i position()const{return _position;}

        ///
        typeof(this) position(in Vector2i p){_position = p;return this;}

        ///
        Vector2i size()const{return Vector2i(_height, _width);}

        ///
        typeof(this) size(in Vector2i p){
            _width = p.y;
            _height = p.x;
            return this;
        }
        
        ///
        int glVersionMajor()const{return _glVersion.major;}

        ///
        int glVersionMinor()const{return _glVersion.minor;}
        
        ///
        SemVer glVersion()const{
            return _glVersion;
        }
        
        ///
        typeof(this) glVersion(in string v){
            import std.algorithm;
            import std.array;
            const digits = v.split(".").map!(n => n.to!int).array;
            glVersion = SemVer(digits[0], digits[1], digits[2]);
            return this;
        }
        
        ///
        typeof(this) glVersion(in SemVer v){
            _glVersion = v;
            return this;
        }
        
        ///
        typeof(this) glVersionMajor(in int versionMajor){_glVersion.major = versionMajor;return this;}

        ///
        typeof(this) glVersionMinor(in int versionMinor){_glVersion.minor = versionMinor;return this;}
    }//public

    private{
        int _height = 480;
        int _width = 640;
        Vector2i _position;
        SemVer _glVersion = SemVer(3, 3, 0);
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
