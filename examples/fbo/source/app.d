import armos, std.stdio, std.math;
import derelict.opengl3.gl;
class TestApp : ar.BaseApp{
	ar.Fbo fbo;
	ar.Mesh circle;
	ar.Camera camera = new ar.Camera;
	
	float angle = 0;

	struct Mouse{
		ar.Vector2i oldPos;
		ar.Vector2i currentPos;
	}
	Mouse mouse;
	
	struct Particle{
		float mass = 1000.0;
		ar.Vector2f position;
		ar.Vector2f speed;
	}
	Particle particle;
	
	void setup(){
		fbo = new ar.Fbo;
		camera.position = ar.Vector3f(0, 0, -40);
		circle = ar.circlePrimitive(ar.math.Vector3f(0, 0, 0), 1);
		fbo.begin;
			ar.setBackground(32, 32, 32);
		fbo.end;
	}
	
	void update(){
		angle += 1;
		float deltaTime = 1;
		
		with(particle){
			ar.Vector2f d = cast(ar.Vector2f)mouse.currentPos - position;
			ar.Vector2f force;
			if( d.norm == 0 ){
				force = ar.Vector2f(0, 0);
			}else{
				force = mass/( d.norm*d.norm )*d.normalized;
			}
			force = force - speed * 0.001;
			speed = ( speed + force )*deltaTime;
			position = ( position + speed )*deltaTime;
		}
		
		mouse.oldPos = mouse.currentPos;
	}
	
	void draw(){
		fbo.begin;
		ar.setColor(255.0*sin(angle*0.1), 255.0*sin(angle*0.11+0.1), 255, 1);
		ar.pushMatrix;
			ar.translate(particle.position[0], particle.position[1], 0);
			ar.scale(6+5.0*sin(angle*0.1));
			circle.drawFill;
		ar.popMatrix;
		fbo.end;
		
		ar.setColor(255);
		fbo.draw;
		
		( ar.fpsUseRate*100 ).writeln;
	}
	void keyPressed(int key){
		fbo.resize(ar.currentWindow.size);
		fbo.begin;
			ar.setBackground(32, 32, 32);
		fbo.end;
		particle.position = ar.Vector2f(0, 0);
		particle.speed = ar.Vector2f(0, 0);
	}
	
	void mouseMoved(ar.Vector2i vec, int button){
		mouse.currentPos = vec;
		
	}

}

void main(){ar.run(new TestApp);}
