module armos.events.event;
import core.sync.mutex;
import std.array;

/++
+/
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

/++
イベントにイベントハンドラを登録します．
Params:
event = 登録先のイベントを表します．
listenerFunc = 登録されるイベントを表します．
+/
void addListener(EventType, ListenerClass, FunctionType)(ref EventType event, ref ListenerClass listener, FunctionType listenerFunc){
    event.remove(listenerFunc);
    event.add(listenerFunc);
};

/++
イベントが発生した際に実行される通知です．
Params:
event = 発生したイベントを指定します．
listenerFunc = イベントのメッセージを指定します．
+/
void notifyEvent(EventType, ArgType)(ref EventType event, ref ArgType arg){
    event.notify(arg);
}

class EventArg{}
