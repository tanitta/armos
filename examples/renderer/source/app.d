static import ar = armos;
import armos.graphics;
import std.stdio, std.math;

alias V4 = ar.math.Vector4f;
class TestApp : ar.app.BaseApp{
    override void setup(){
        // ar.graphics.enableDepthTest;
        _camera = (new ar.graphics.DefaultCamera).position(ar.math.Vector3f(0, 0, -40))
                                                 .target(ar.math.Vector3f.zero);

        _model  = (new ar.graphics.Model).load("data/bunny.fbx");

        _index = new ar.graphics.Buffer(ar.graphics.BufferType.ElementArray);
        _vertex = new ar.graphics.Buffer();
    }

    override void update(){
        _counter += 0.1;
        _camera.position = ar.math.Vector3f(20.0*cos(_counter*0.05), 10.0, 20.0*sin(_counter*0.05));
        _vertex.array([V4(-0.5, -0.5, 0, 1), V4(0.5, -0.5, 0, 1), V4(0, 0.5, 0, 1)]);
        _index.array([0, 1, 2]);
    }

    override void draw(){
        alias r = ar.graphics.currentRenderer;
        r
            // .viewMatrix(_camera.viewMatrix)
         // .projectionMatrix(_camera.projectionMatrix)
         // .viewMatrix(_camera.viewMatrix)
         .attribute("vertex", _vertex)
         .indices(_index)
         .render();
    }

    private{
        float _counter = 0f;
        ar.graphics.Camera _camera;
        ar.graphics.Model  _model;
        ar.graphics.Buffer _index;
        ar.graphics.Buffer _vertex;
    }
}

void main(){
    version(unittest){
    }else{
        ar.app.run(new TestApp);
    }
}
