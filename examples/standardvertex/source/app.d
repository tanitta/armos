import armos.app;
import armos.graphics;
import armos.math;
import std.math;

class TestApp : BaseApp{
    override void setup(){
        _camera = (new PerspCamera).position(vec3f(0.5, 0.0, 0.5))
                                   .target(vec3f.zero);
        _vertices = [
            StandardVertex().position(vec4f(-0.5, -0.5, 0, 1)), 
            StandardVertex().position(vec4f(0.5, -0.5, 0, 1)),
            StandardVertex().position(vec4f(0, 0.5, 0, 1)),
        ];

        _indices = [0, 1, 2];
    }

    override void update(){
        _counter += 0.1;
        _camera.position = vec3f(5.0*cos(_counter*0.05),
                                 0,
                                 5.0*sin(_counter*0.05));
    }

    override void draw(){
        auto cr = currentRenderer;
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
        Camera _camera;
        StandardVertex[] _vertices;
        uint[] _indices;
    }
}

void main(){
    version(unittest){
    }else{
        run(new TestApp);
    }
}
