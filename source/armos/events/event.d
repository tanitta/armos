module armos.events.event;
import core.sync.mutex;
import std.array;
import std.stdio;
// class Function(ArgumentType){
// 	private
// 		void delegate(ArgumentType) func;
// 	public
// 		this(void delegate(ArgumentType) f){
// 			func = f;
// 		}
// 	void run(ArgumentType arg){
// 		func(arg);
// 	}
// }

class Event(ArgumentType) {
	protected
		void delegate(ref ArgumentType)[] functions;
	bool enabled = true;
	bool notifying = false;
	// Mutex mutex;
	void remove(void delegate(ref ArgumentType) func){
	};

	void add(void delegate(ref ArgumentType) func){
		functions~=func;
	};

	void notify(ref ArgumentType arg){
		foreach (func; functions) {
			func(arg);
		}
	};

	public
		this(){
			// mutex = new Mutex;
		};
}

void addListener(EventType, ListenerClass, FunctionType)(ref EventType event, ref ListenerClass listener, FunctionType listenerFunc){
	event.remove(listenerFunc);
	event.add(listenerFunc);
};
void notifyEvent(EventType, ArgType)(ref EventType event, ref ArgType arg){
	event.notify(arg);
}

class EventArg{}

class KeyPressedEventArg : EventArg{
	string str;
};

class CoreEvents {
	private
		EventArg voidEventArg;
	public
		Event!(EventArg) setup;
	Event!(EventArg) update;
	Event!(EventArg) draw;
	Event!(KeyPressedEventArg) keyPressed;
	this(){
		setup = new Event!(EventArg);
		update= new Event!(EventArg);
		draw = new Event!(EventArg);
		keyPressed = new Event!(KeyPressedEventArg);
	}
	void notifySetup(){
		notifyEvent(setup, voidEventArg);
	};

	void notifyUpdate(){};
	void notifyDraw(){};
	void notifyKeyPressed(){
		writeln("notifyKeyPressed");
		auto obj = new KeyPressedEventArg;
		// obj.a = 2;
		notifyEvent(keyPressed, obj);

	}
}

unittest{
	import std.stdio;
	import armos.app;
	
	auto core_events = new CoreEvents;

	class Hoge : armos.app.BaseApp {
		//i want to write like c++. the following is verbose...
		alias armos.app.BaseApp.setup setup;
		alias armos.app.BaseApp.update update;
		alias armos.app.BaseApp.draw draw;
		alias armos.app.BaseApp.keyPressed keyPressed;
		
		void setup(){}
		void update(){}
		void draw(){}

		void keyPressed(string str) {
			writeln(str);
		}
		
	}
	
	auto hoge = new Hoge;
	addListener(core_events.setup, hoge, &hoge.setup);
	addListener(core_events.keyPressed, hoge, &hoge.keyPressed);
	core_events.notifyKeyPressed();
}
