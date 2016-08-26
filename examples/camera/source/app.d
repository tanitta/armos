static import ar = armos;
import std.stdio, std.math;

class TestApp : ar.app.BaseApp{
	override void setup(){
		_camera.position = ar.math.Vector3f(0, 0, -40);
		_camera.target= ar.math.Vector3f(0, 0, 0);
	}
	
	override void update(){
		_counter += 1;
		_camera.position = ar.math.Vector3f(20.0*cos(_counter*0.05), 20.0*sin(_counter*0.05), -40.0);
	}
	
	override void draw(){
		_camera.begin;
		ar.graphics.pushMatrix;
		ar.graphics.color(ar.types.Color(0xFF1F37));
		ar.graphics.boxPrimitive(
				ar.math.Vector3f(0, 0, 0),
				ar.math.Vector3f(20, 20, 20)
		).drawFill();
		_camera.end;
	}
    
    private{
        float _counter = 0f;
        ar.graphics.Camera _camera = new ar.graphics.Camera();
	
    }
}

void main(){ar.app.run(new TestApp);}
