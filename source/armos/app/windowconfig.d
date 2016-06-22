module armos.app.windowconfig;

static import armos.math;
import std.conv;

/++
+/
class WindowConfig {
    public{
        int height()const{return _height;}
        void height(in int h){_height = h;}
        
        int width()const{return _width;}
        void width(in int h){_width = h;}
        
        armos.Vector2i position()const{return _position;}
        void position(in armos.Vector2i p){_position = p;}
        
        int glVersionMajor()const{return _glVersionMajor;}
        int glVersionMinor()const{return _glVersionMinor;}
        
        float glVersion()const{return _glVersionMajor.to!float + _glVersionMinor.to!float*0.1f;}
        void glVersion(T)(in T v)if(__traits(isFloating, T)){
            _glVersionMajor = v.to!int;
            _glVersionMinor = ((v*10.0).to!int%10).to!int;
        }
        
        void glVersionMajor(in int versionMajor){_glVersionMajor = versionMajor;}
        void glVersionMinor(in int versionMinor){_glVersionMinor = versionMinor;}
    }//public

    private{
        int _height;
        int _width;
        armos.Vector2i _position;
        int _glVersionMajor = 3;
        int _glVersionMinor = 2;
    }//private
}//interface WindowConfig
// WindowConfig should be able to handle float version.
unittest{
    auto config = new WindowConfig;
    config.glVersion = 3.3;
    assert(config.glVersionMajor == 3);
    assert(config.glVersionMinor == 3);
    assert(config.glVersion == 3.3f);
}
