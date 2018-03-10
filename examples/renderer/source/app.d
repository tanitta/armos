static import ar = armos;
// import armos.graphics;
import std.stdio, std.math;

alias V4 = ar.math.Vector4f;
class TestApp : ar.app.BaseApp{
    override void setup(){
        _camera = (new ar.graphics.PerspCamera).position(ar.math.Vector3f(0, 0, 2.0))
                                                 .target(ar.math.Vector3f.zero);
        _model  = (new ar.graphics.Model).load("data/bunny.fbx");
        _index = new ar.graphics.Buffer(ar.graphics.BufferType.ElementArray);
        _vertex = new ar.graphics.Buffer();
        import armos.graphics.embeddedrenderer;

    }

    override void update(){
        _counter += 0.1;
        _camera.position = ar.math.Vector3f(5.0*cos(_counter*0.05),
                                            0,
                                            5.0*sin(_counter*0.05));
        _vertex.array([V4(-0.5, -0.5, 0, 1),
                       V4(0.5, -0.5, 0, 1),
                       V4(0, 0.5, 0, 1)]);
        _index.array([0, 1, 2]);
    }

    override void draw(){
        import armos.graphics.renderer;
        import armos.graphics.standardrenderer;
        auto cr = armos.graphics.currentRenderer;
        cr.backgroundColor(0.2, 0.2, 0.2, 1.).fillBackground;

        cr.projectionMatrix(_camera.projectionMatrix)
          .viewMatrix(_camera.viewMatrix)
          .attribute("vertex", _vertex)
          .indices(_index)
          .diffuse(1f-cos(_counter*0.5)*0.5f,
                   1f-cos(_counter*0.51)*0.5f,
                   1f-cos(_counter*0.52)*0.5f,
                   1f)
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
