module armos.events.event;
import core.sync.mutex;
import std.array;
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
