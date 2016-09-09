static import ar = armos;
import std.stdio, std.math;

class TestApp : ar.app.BaseApp{
	override void setup(){
		_camera.position = ar.math.Vector3f(0, 0, -100);
		_camera.target= ar.math.Vector3f(0, 0, 0);
        ar.graphics.samples = 2;
        ar.graphics.enableDepthTest;
	}
	
	override void update(){
		counter += 0.01;
	}
	
	override void draw(){
		_camera.begin;
		
		drawPrimitiveExample(
			ar.math.Vector3f(-40, 0, 0),
			ar.graphics.boxPrimitive(
				ar.math.Vector3f(0, 0, 0),
				ar.math.Vector3f(20, 20, 20)
			),
			ar.types.Color(0xe4007f)
		);
		
		drawPrimitiveExample(
			ar.math.Vector3f(0, 0, 0),
			ar.graphics.circlePrimitive(
				ar.math.Vector3f(0, 0, 0),
				10
			),
			ar.types.Color(0xffdc00)
		);
		
		drawPrimitiveExample(
			ar.math.Vector3f(40, 0, 0),
			ar.graphics.planePrimitive(
				ar.math.Vector3f(0, 0, 0),
				ar.math.Vector2f(20, 20),
			),
			ar.types.Color(0x00a1e9)
		);
		
		_camera.end;
	}
    
    private{
        float counter = 0;
        ar.graphics.Camera _camera = new ar.graphics.Camera();

        void drawPrimitiveExample(ar.math.Vector3f position, ar.graphics.Mesh mesh, ar.types.Color color){
            ar.graphics.pushMatrix;
            ar.graphics.translate(position);
            ar.graphics.rotate(counter, ar.math.Vector3f(1, 1, 1));
            ar.graphics.color(color);
            // mesh.drawFill();
            // ar.graphics.color(ar.types.Color(0x16160e));
            mesh.drawWireFrame();
            ar.graphics.popMatrix;
        }
    }
}

void main(){ar.app.run(new TestApp);}
