import armos, std.stdio, std.math;

class TestApp : ar.BaseApp{
	float c = 0;
	ar.Camera camera = new ar.Camera();
	
	void setup(){
		camera.position = ar.Vector3f(0, 0, -40);
		camera.target= ar.Vector3f(0, 0, 0);
	}
	
	void update(){
		c += 1;
		camera.position = ar.Vector3f(20.0*cos(c*0.05), 20.0*sin(c*0.05), -40.0);
	}
	
	void draw(){
		camera.begin;
		ar.pushMatrix;
		ar.setColor(ar.Color(0xFF1F37));
		ar.boxPrimitive(
				ar.Vector3f(0, 0, 0),
				ar.Vector3f(20, 20, 20)
		).drawFill();
		camera.end;
	}
}

void main(){ar.run(new TestApp);}
