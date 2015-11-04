module armos.app.baseapp;
import armos.events;
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
	
	void keyPressed(ref armos.events.KeyPressedEventArg message) {
		keyPressed(message.key);
	}
	
	void keyPressed(int str) {
	}
	
	void exit(ref armos.events.EventArg arg){
		exit();
	};
	
	void exit(){};
	
	int mouseX, mouseY;
}
