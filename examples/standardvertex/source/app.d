static import ar = armos;
// import armos.graphics;
import std.stdio, std.math;

alias V4 = ar.math.Vector4f;
class TestApp : ar.app.BaseApp{
    override void setup(){
        _camera = (new ar.graphics.PerspCamera).position(ar.math.Vector3f(0.5, 0.0, 0.5))
                                               .target(ar.math.Vector3f.zero);
        _vertices = [
            ar.graphics.StandardVertex().position(V4(-0.5, -0.5, 0, 1)), 
            ar.graphics.StandardVertex().position(V4(0.5, -0.5, 0, 1)),
            ar.graphics.StandardVertex().position(V4(0, 0.5, 0, 1)),
        ];

        _indices = [0, 1, 2];
    }

    override void update(){
        _counter += 0.1;
        _camera.position = ar.math.Vector3f(5.0*cos(_counter*0.05),
                                            0,
                                            5.0*sin(_counter*0.05));
    }

    override void draw(){
        import armos.graphics.renderer;
        import armos.graphics.standardrenderer;
        auto cr = armos.graphics.currentRenderer;
        cr.backgroundColor(0.2, 0.2, 0.2, 1.).fillBackground;

        cr.projectionMatrix(_camera.projectionMatrix)
          .viewMatrix(_camera.viewMatrix)
          .vertices(_vertices)
          .indices(_indices)
          .diffuse(1f-cos(_counter*0.5)*0.5f,
                   1f-cos(_counter*0.51)*0.5f,
                   1f-cos(_counter*0.52)*0.5f,
                   1f)
          .render();
    }

    private{
        float _counter = 0f;
        ar.graphics.Camera _camera;
        ar.graphics.StandardVertex[] _vertices;
        int[] _indices;
    }
}

void main(){
    version(unittest){
    }else{
        ar.app.run(new TestApp);
    }
}
