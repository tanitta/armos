module armos.app.baseapp;
import armos.events.event;
class BaseApp{
	void setup(ref EventArg arg){
		setup();
	}
	void update(ref EventArg arg){
		update();
	}
	void draw(ref EventArg arg){
		draw();
	}
	
	void setup(){};
	
	void update(){};
	
	void draw(){};
	
	void keyPressed(ref KeyPressedEventArg m) {
		keyPressed(m.str);
	}
	
	void keyPressed(string str) {
	}
}
