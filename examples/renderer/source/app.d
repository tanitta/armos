import armos.app;
import armos.math;
import armos.graphics;
// import armos.graphics;
import std.stdio, std.math;

class TestApp : BaseApp{
    override void setup(){
        _camera = (new PerspCamera).position(vec3f(0, 0, 2.0))
                                                 .target(vec3f.zero);
        _indexBuffer = new Buffer(BufferType.ElementArray);
        _colorBuffer = new Buffer();
        _positionBuffer = new Buffer();
    }

    override void update(){
        _counter += 0.1;
        _camera.position = vec3f(2.0*cos(_counter*0.05),
                                 0,
                                 2.0*sin(_counter*0.05));
        _colorBuffer.array([vec4f(1.0, 0.0, 0.0, 1),
                            vec4f(0.0, 1.0, 0.0, 1),
                            vec4f(0.0, 0.0, 1.0, 1)]);
        _positionBuffer.array([vec4f(-0.5, -0.5, 0, 1),
                               vec4f(0.5, -0.5, 0, 1),
                               vec4f(0, 0.5, 0, 1)]);
        _indexBuffer.array([0, 1, 2]);
    }

    override void draw(){
        auto cr = currentRenderer;
        cr.backgroundColor(0.2, 0.2, 0.2, 1.)
          .fillBackground;

        cr.camera(_camera)
          .positions(_positionBuffer)
          .colors(_colorBuffer)
          .indices(_indexBuffer)
          // .diffuse(1f-cos(_counter*0.5)*0.5f,
          //          1f-cos(_counter*0.51)*0.5f,
          //          1f-cos(_counter*0.52)*0.5f,
          //          1f)
          .diffuse(1f, 1f, 1f, 1f)
          .render();
    }

    private{
        float _counter = 0f;
        Camera _camera;
        Buffer _indexBuffer;
        Buffer _positionBuffer;
        Buffer _colorBuffer;
    }
}

void main(){
    version(unittest){
    }else{
        run(new TestApp);
    }
}
