import std.stdio, std.math, std.conv;
import armos.graphics.easycam;

static import ar = armos;

class TestApp : ar.app.BaseApp{
    override void setup(){
        _camera = new EasyCam();
    }

    override void update(){
        _camera.update;
    }

    override void draw(){
        _camera.begin;
        ar.utils.drawAxis(100.0);
        _camera.end;
    }

    EasyCam _camera;
}

void main(){
    version(unittest){
    }else{
        ar.app.run(new TestApp);
    }
}
