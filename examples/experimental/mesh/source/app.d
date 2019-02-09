// import armos.graphics;
import armos.graphics.experimental.mesh;
import armos.app;
import armos.graphics.easycam;
import armos.graphics.defaultrenderer;
import armos.graphics.bufferbundle;
import armos.utils;
import armos.math;

class MainApp : BaseApp{
    this(){}

    override void setup(){
        _camera = (new EasyCam);
        (new Mesh!float).attr("vertex", [
                            Vector4f(-0.5, -0.5, 0, 1),
                            Vector4f(0.5, -0.5, 0, 1),
                            Vector4f(0, 0.5, 0, 1)])
                        .attr("index", [0, 1, 2]);
    }

    override void update(){
        _camera.update;
    }

    override void draw(){
        auto cr = armos.graphics.currentRenderer;
        cr.backgroundColor(0.2, 0.2, 0.2, 1.).fillBackground;
    }

    override void keyPressed(KeyType key){}

    override void keyReleased(KeyType key){}

    override void mouseMoved(Vector2i position, int button){}

    override void mousePressed(Vector2i position, int button){}

    override void mouseReleased(Vector2i position, int button){}

    EasyCam _camera;
    BufferBundle _bufferBundle;
}

void main(){run(new MainApp);}
