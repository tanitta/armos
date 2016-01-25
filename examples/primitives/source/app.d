import armos, std.stdio, std.math;

class TestApp : ar.BaseApp{
	float c = 0;
	ar.Camera camera = new ar.Camera();
	
	void setup(){
		ar.enableDepthTest;
		camera.position = ar.Vector3f(0, 0, -100);
		camera.target= ar.Vector3f(0, 0, 0);
	}
	
	void update(){
		c += 1;
	}
	
	void drawPrimitiveExample(ar.Vector3f position, ar.Mesh mesh, ar.Color color){
		ar.pushMatrix;
		ar.translate(position);
		ar.rotate(c, ar.Vector3f(1, 1, 1));
		ar.setColor(color);
		mesh.drawFill();
		ar.setColor(ar.Color(0x16160e));
		mesh.drawWireFrame();
		ar.popMatrix;
	}
	
	void draw(){
		camera.begin;
		
		drawPrimitiveExample(
			ar.Vector3f(0, 0, 0),
			ar.boxPrimitive(
				ar.Vector3f(0, 0, 0),
				ar.Vector3f(20, 20, 20)
			),
			ar.Color(0xe4007f)
		);
		
		drawPrimitiveExample(
			ar.Vector3f(40, 0, 0),
			ar.circlePrimitive(
				ar.Vector3f(0, 0, 0),
				10
			),
			ar.Color(0xffdc00)
		);
		
		
		drawPrimitiveExample(
			ar.Vector3f(80, 0, 0),
			ar.planePrimitive(
				ar.Vector3f(0, 0, 0),
				ar.Vector2f(20, 20),
			),
			ar.Color(0x00a1e9)
		);
		
		camera.end;
	}
}

void main(){ar.run(new TestApp);}
