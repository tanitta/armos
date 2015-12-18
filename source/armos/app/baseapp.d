module armos.app.baseapp;
import armos.events;
import armos.math;
class BaseApp{
	void setup(ref armos.events.EventArg arg){
		setup();
	}
	void update(ref armos.events.EventArg arg){
		update();
	}
	void draw(ref armos.events.EventArg arg){
		draw();
	}
	
	void setup(){};
	
	void update(){};
	
	void draw(){};
	
	
	void exit(ref armos.events.EventArg arg){
		exit();
	};
	
	void exit(){};
	
	void keyPressed(ref armos.events.KeyPressedEventArg message) {
		keyPressed(message.key);
	}
	
	void keyPressed(int str) {
	}
	
	void keyReleased(ref armos.events.KeyReleasedEventArg message) {
		keyReleased(message.key);
	}
	
	void keyReleased(int str) {
	}
	
	int mouseX, mouseY;
	
	void mouseMoved(ref armos.events.MouseMovedEventArg message){
		mouseMoved(message.x, message.y, message.button );
		mouseMoved(armos.math.Vector2f(message.x, message.y), message.button);
		mouseMoved(armos.math.Vector2i(message.x, message.y), message.button);
	}
	void mouseMoved(int x, int y, int button){}
	void mouseMoved(armos.math.Vector2f position, int button){}
	void mouseMoved(armos.math.Vector2i position, int button){}
	
	void mouseDragged(ref armos.events.MouseDraggedEventArg message){
		mouseDragged(message.x, message.y, message.button );
		mouseDragged(armos.math.Vector2f(message.x, message.y), message.button);
		mouseDragged(armos.math.Vector2i(message.x, message.y), message.button);
	}
	void mouseDragged(int x, int y, int button){}
	void mouseDragged(armos.math.Vector2f position, int button){}
	void mouseDragged(armos.math.Vector2i position, int button){}
	
	void mouseReleased(ref armos.events.MouseReleasedEventArg message){
		mouseReleased(message.x, message.y, message.button );
		mouseReleased(armos.math.Vector2f(message.x, message.y), message.button);
		mouseReleased(armos.math.Vector2i(message.x, message.y), message.button);
	}
	void mouseReleased(int x, int y, int button){}
	void mouseReleased(armos.math.Vector2f position, int button){}
	void mouseReleased(armos.math.Vector2i position, int button){}
	
	void mousePressed(ref armos.events.MousePressedEventArg message){
		mousePressed(message.x, message.y, message.button );
		mousePressed(armos.math.Vector2f(message.x, message.y), message.button);
		mousePressed(armos.math.Vector2i(message.x, message.y), message.button);
	}
	void mousePressed(int x, int y, int button){}
	void mousePressed(armos.math.Vector2f position, int button){}
	void mousePressed(armos.math.Vector2i position, int button){}
}
