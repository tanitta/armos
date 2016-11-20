static import ar = armos;
import std.stdio, std.math;
import derelict.opengl3.gl;

class TestApp : ar.app.BaseApp{
	override void setup(){
		_fbo = (new ar.graphics.Fbo);
		_fbo.begin;
			ar.graphics.fillBackground(32, 32, 32);
		_fbo.end;
        
		_circle = ar.graphics.circlePrimitive(ar.math.Vector3f(0, 0, 0), 1);
	}
	
	override void update(){
		_angle += 1;
		float deltaTime = 1;
		
		with(_particle){
			ar.math.Vector2f d = cast(ar.math.Vector2f)_mouse.currentPos - position;
			ar.math.Vector2f force;
			if( d.norm < 20 ){
				force = ar.math.Vector2f(0, 0);
			}else{
				force = mass/( d.norm*d.norm )*d.normalized;
			}
			force = force - speed * 0.01;
			speed = ( speed + force )*deltaTime;
			position = ( position + speed )*deltaTime;
		}
		
		_mouse.oldPos = _mouse.currentPos;
	}
	
	override void draw(){
		_fbo.begin;
		ar.graphics.color(255.0*sin(_angle*0.1), 255.0*sin(_angle*0.11+0.1), 255, 1);
		ar.graphics.pushMatrix;
			ar.graphics.translate(_particle.position[0], _particle.position[1], 0);
			ar.graphics.scale(6+5.0*sin(_angle*0.1));
			_circle.drawFill;
		ar.graphics.popMatrix;
		_fbo.end;
		
		ar.graphics.color(255);
		_fbo.draw;
	}
	override void keyPressed(ar.utils.KeyType key){
		_fbo.resize(ar.app.currentWindow.size);
		_fbo.begin;
			ar.graphics.background(32, 32, 32);
		_fbo.end;
		_particle.position = ar.math.Vector2f(0, 0);
		_particle.speed = ar.math.Vector2f(0, 0);
	}
	
	override void mouseMoved(ar.math.Vector2i vec, int button){
		_mouse.currentPos = vec;
	}

    private{
        ar.graphics.Fbo _fbo;
        ar.graphics.Mesh _circle;
        
        float _angle = 0;

        struct Mouse{
            ar.math.Vector2i oldPos;
            ar.math.Vector2i currentPos;
        }
        Mouse _mouse;
        
        struct Particle{
            float mass = 1000.0;
            ar.math.Vector2f position = ar.math.Vector2f.zero;
            ar.math.Vector2f speed = ar.math.Vector2f.zero;
        }
        Particle _particle;
	
    }
}

void main(){
    version(unittest){
    }else{
        ar.app.run(new TestApp);
    }
}
