static import ar = armos;
import std.stdio, std.math;

class TestApp : ar.app.BaseApp{
	override void setup(){
        ar.graphics.enableDepthTest;
        ar.graphics.samples = 2;
        _camera = (new ar.graphics.BasicCamera).position(ar.math.Vector3f(0, 0, -40))
                                               .target(ar.math.Vector3f.zero);
        
        _model  = (new ar.graphics.Model).load("bunny.fbx");
	}
	
	override void update(){
		_counter += 0.1;
		_camera.position = ar.math.Vector3f(20.0*cos(_counter*0.05), 10.0, 20.0*sin(_counter*0.05));
	}
	
	override void draw(){
		_camera.begin;
		ar.graphics.pushMatrix;
        ar.graphics.drawAxis(10);
        ar.graphics.scale(100f);
        _model.drawWireFrame;
		ar.graphics.popMatrix;
		_camera.end;
	}
    
    private{
        float _counter = 0f;
        ar.graphics.Camera _camera;
        ar.graphics.Model  _model;
    }
}

void main(){ar.app.run(new TestApp);}
