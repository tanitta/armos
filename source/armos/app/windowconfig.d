module armos.app.windowconfig;

static import armos.math;

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
    }//public

    private{
        int _height;
        int _width;
        armos.Vector2i _position;
    }//private
}//interface WindowConfig

/++
+/
import std.conv;
class GLFWWindowConfig : WindowConfig{
    public{
        int glVersionMajor()const{return _glVersionMajor;}
        int glVersionMinor()const{return _glVersionMinor;}
        
        float glVersion()const{return _glVersionMajor.to!float + _glVersionMinor.to!float*0.1f;}
        void glVersion(in float v){
            _glVersionMajor = v.to!int;
            _glVersionMinor = (v%_glVersionMajor).to!int;
        }
        
        void glVersionMajor(in int versionMajor){_glVersionMajor = versionMajor;}
        void glVersionMinor(in int versionMinor){_glVersionMinor = versionMinor;}
    }//public

    private{
        int _glVersionMajor = 3;
        int _glVersionMinor = 2;
    }//private
}//class GLFWWindowConfig
// WindowConfig should be able to handle float version.
unittest{
    auto config = new GLFWWindowConfig;
    config.glVersion = 2.1;
    assert(config.glVersionMajor == 2);
    assert(config.glVersionMinor == 1);
    assert(config.glVersion == 2.1);
}
