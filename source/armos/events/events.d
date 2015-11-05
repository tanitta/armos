module armos.events.events;
import armos.events.events;

class KeyPressedEventArg : armos.events.EventArg{
	int key;
};

class KeyReleasedEventArg : armos.events.EventArg{
	int  key;
};

@disable class MessageReceivedEventArg :armos.events.EventArg {}

mixin template MouseEvent(){
	int x, y, button;
	this(int x, int y, int button){
		this.x = x;
		this.y = y;
		this.button = button;
	};
}

class MouseDraggedEventArg :armos.events.EventArg {mixin MouseEvent;}
class MouseEnteredEventArg :armos.events.EventArg {mixin MouseEvent;}
class MouseExitedEventArg :armos.events.EventArg {mixin MouseEvent;}
class MouseMovedEventArg :armos.events.EventArg {mixin MouseEvent;}
class MousePressedEventArg :armos.events.EventArg {mixin MouseEvent;}
class MouseReleasedEventArg :armos.events.EventArg {mixin MouseEvent;}
class MouseScrolledEventArg :armos.events.EventArg {mixin MouseEvent;}

mixin template TouchEvent(){
	int x, y, id;
	this(int x, int y, int id){
		this.x = x;
		this.y = y;
		this.id = id;
	};
}

class TouchCancelledEventArg{mixin TouchEvent;}
class TouchDoubleTapEventArg{mixin TouchEvent;}
class TouchDownEventArg{mixin TouchEvent;}
class TouchMovedEventArg{mixin TouchEvent;}
class TouchUpEventArg{mixin TouchEvent;}

class WindowResizeEventArg{
	int w, h;
	this(int w, int h){
		this.w = w;
		this.h = h;
	}
}

class CoreEvents {
	private armos.events.EventArg voidEventArg;

	armos.events.Event!(armos.events.EventArg) setup;
	armos.events.Event!(armos.events.EventArg) update;
	armos.events.Event!(armos.events.EventArg) draw;
	armos.events.Event!(armos.events.EventArg) exit;
	
	armos.events.Event!(KeyPressedEventArg) keyPressed;
	armos.events.Event!(KeyReleasedEventArg) keyReleased;
	
	armos.events.Event!(MouseDraggedEventArg) mouseDragged;
	armos.events.Event!(MouseEnteredEventArg) mouseEntered;
	armos.events.Event!(MouseMovedEventArg) mouseMoved;
	armos.events.Event!(MousePressedEventArg) mousePressed;
	armos.events.Event!(MouseReleasedEventArg) mouseReleased;
	armos.events.Event!(MouseScrolledEventArg) mouseScrolled;
	
	armos.events.Event!(TouchCancelledEventArg) touchCancelled;
	armos.events.Event!(TouchDoubleTapEventArg) touchDoubleTap;
	armos.events.Event!(TouchDownEventArg) touchDown;
	armos.events.Event!(TouchMovedEventArg) touchMoved;
	armos.events.Event!(TouchUpEventArg) touchUp;
	
	armos.events.Event!(WindowResizeEventArg) windowResize;
	
	this(){
		setup = new armos.events.Event!(armos.events.EventArg);
		update= new armos.events.Event!(armos.events.EventArg);
		draw = new armos.events.Event!(armos.events.EventArg);
		exit = new armos.events.Event!(armos.events.EventArg);
		
		keyPressed = new armos.events.Event!(KeyPressedEventArg);
		keyReleased = new armos.events.Event!(KeyReleasedEventArg);
		
		mouseDragged = new armos.events.Event!(MouseDraggedEventArg);
		mouseEntered = new armos.events.Event!(MouseEnteredEventArg);
		mouseMoved = new armos.events.Event!(MouseMovedEventArg);
		mousePressed = new armos.events.Event!(MousePressedEventArg);
		mouseReleased = new armos.events.Event!(MouseReleasedEventArg);
		mouseScrolled = new armos.events.Event!(MouseScrolledEventArg);
		
		touchCancelled = new armos.events.Event!(TouchCancelledEventArg);
		touchDoubleTap = new armos.events.Event!(TouchDoubleTapEventArg);
		touchDown = new armos.events.Event!(TouchDownEventArg);
		touchMoved= new armos.events.Event!(TouchMovedEventArg);
		touchUp = new armos.events.Event!(TouchUpEventArg);
		
		windowResize = new armos.events.Event!(WindowResizeEventArg);
	}
	void notifySetup(){
		armos.events.notifyEvent(setup, voidEventArg);
	};

	void notifyUpdate(){
		armos.events.notifyEvent(update, voidEventArg);
	};
	
	void notifyDraw(){
		armos.events.notifyEvent(draw, voidEventArg);
	};
	
	void notifyExit(){
		armos.events.notifyEvent(exit, voidEventArg);
	};
	
	void notifyKeyPressed(int key){
		auto obj = new KeyPressedEventArg;
		obj.key = key;
		armos.events.notifyEvent(keyPressed, obj);
	}
	
	void notifyKeyReleased(int key){
		auto obj = new KeyReleasedEventArg;
		obj.key = key;
		armos.events.notifyEvent(keyReleased, obj);
	}
	
	void notifyMouseDragged(int x, int y, int button){
		auto obj = new MouseDraggedEventArg(x, y, button);
		armos.events.notifyEvent(mouseDragged, obj);
	}
	
	void notifyMouseEntered(int x, int y, int button){
		auto obj = new MouseEnteredEventArg(x, y, button);
		armos.events.notifyEvent(mouseEntered, obj);
	}
	
	void notifyMouseMoved(int x, int y, int button){
		auto obj = new MouseMovedEventArg(x, y, button);
		armos.events.notifyEvent(mouseMoved, obj);
	}
	
	void notifyMousePressed(int x, int y, int button){
		auto obj = new MousePressedEventArg(x, y, button);
		armos.events.notifyEvent(mousePressed, obj);
	}
	
	void notifyMouseReleased(int x, int y, int button){
		auto obj = new MouseReleasedEventArg(x, y, button);
		armos.events.notifyEvent(mouseReleased, obj);
	}
	
	void notifyMouseScrolled(int x, int y, int button){
		auto obj = new MouseScrolledEventArg(x, y, button);
		armos.events.notifyEvent(mouseScrolled, obj);
	}
	
	void notifyTouchCancelled(int x, int y, int id){
		auto obj = new TouchCancelledEventArg(x, y, id);
		armos.events.notifyEvent(touchCancelled, obj);
	}
	
	void notifyTouchDoubleTap(int x, int y, int id){
		auto obj = new TouchDoubleTapEventArg(x, y, id);
		armos.events.notifyEvent(touchDoubleTap, obj);
	}
	
	void notifyTouchDown(int x, int y, int id){
		auto obj = new TouchDownEventArg(x, y, id);
		armos.events.notifyEvent(touchDown, obj);
	}
	
	void notifyTouchMoved(int x, int y, int id){
		auto obj = new TouchMovedEventArg(x, y, id);
		armos.events.notifyEvent(touchMoved, obj);
	}
	
	void notifyTouchUp(int x, int y, int id){
		auto obj = new TouchUpEventArg(x, y, id);
		armos.events.notifyEvent(touchUp, obj);
	}
	
	void notifyWindowResize(int w, int h){
		auto obj = new WindowResizeEventArg(w, h);
		armos.events.notifyEvent(windowResize, obj);
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
