module armos.events.events;
import armos.events.events;

class KeyPressedEventArg : armos.events.EventArg{
	int key;
};

class KeyReleasedEventArg : armos.events.EventArg{
	int  key;
};

@disable class messageReceivedEventArg :armos.events.EventArg {}

mixin template mouseEvent(){
	int x, y, button;
}

class mouseDraggedEventArg :armos.events.EventArg {mixin mouseEvent;}
class mouseEnteredEventArg :armos.events.EventArg {mixin mouseEvent;}
class mouseExitedEventArg :armos.events.EventArg {mixin mouseEvent;}
class mouseMovedEventArg :armos.events.EventArg {mixin mouseEvent;}
class mousePressedEventArg :armos.events.EventArg {mixin mouseEvent;}
class mouseReleasedEventArg :armos.events.EventArg {mixin mouseEvent;}
class mouseScrolledEventArg :armos.events.EventArg {mixin mouseEvent;}

mixin template touchEvent(){
	int x, y, id;
}

class touchCancelled{mixin touchEvent;}
class touchDoubleTap{mixin touchEvent;}
class touchDown{mixin touchEvent;}
class touchMoved{mixin touchEvent;}
class touchUp{mixin touchEvent;}

class windowResize{
	int w, h;
}

class CoreEvents {
	private
		armos.events.EventArg voidEventArg;
	public
		armos.events.Event!(armos.events.EventArg) setup;
	armos.events.Event!(armos.events.EventArg) update;
	armos.events.Event!(armos.events.EventArg) draw;
	armos.events.Event!(KeyPressedEventArg) keyPressed;
	this(){
		setup = new armos.events.Event!(armos.events.EventArg);
		update= new armos.events.Event!(armos.events.EventArg);
		draw = new armos.events.Event!(armos.events.EventArg);
		keyPressed = new armos.events.Event!(KeyPressedEventArg);
	}
	void notifySetup(){
		armos.events.notifyEvent(setup, voidEventArg);
	};

	void notifyUpdate(){};
	void notifyDraw(){};
	void notifyKeyPressed(int key){
		auto obj = new KeyPressedEventArg;
		obj.key = key;
		armos.events.notifyEvent(keyPressed, obj);
	}
}

unittest{
	import std.stdio;
	import armos.app;
	
	auto core_events = new CoreEvents;

	class TestApp: armos.app.BaseApp {
		//i want to write like c++. the following is verbose...
		//should i use template mixin instead alias?
		alias armos.app.BaseApp.setup setup;
		alias armos.app.BaseApp.update update;
		alias armos.app.BaseApp.draw draw;
		alias armos.app.BaseApp.keyPressed keyPressed;
		
		void setup(){
			writeln("setup");
		}
		void update(){}
		void draw(){}

		void keyPressed(int key) {
			char str_key = cast(char)key;
			writeln("keyPressed : ", str_key);
		}
		
	}
	
	auto app = new TestApp;
	armos.events.addListener(core_events.setup, app, &app.setup);
	armos.events.addListener(core_events.keyPressed, app, &app.keyPressed);
	core_events.notifySetup();
	core_events.notifyKeyPressed('a');
}
