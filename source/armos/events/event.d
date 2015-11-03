module armos.events.event;
import core.sync.mutex;

class Function{

}
class BaseEvent(Func) {
	protected
		Func[] functions;
		bool enabled = true;
		bool notifying = false;
		auto mutex = new Mutex;
		
		void remove(void function(EventType)){};
		void add(){};
		
	public
		this(){

		};
}

void addListener(EventType, ArgumentType, ListenerClass)(
		ref EventType event, ListenerClass* listener, void function(EventType) listenerFunc){
	event.remove(listener, listenerFunc);
	event.add(listener, listenerFunc);
};
