module armos.events.events;
import armos.events;
import armos.utils;

struct SetupEvent{}
struct UpdateEvent{}
struct DrawEvent{}
struct ExitEvent{}

struct KeyPressedEvent{
    this(in KeyType key){this.key = key;}
    KeyType key;
}

struct KeyReleasedEvent{
    this(in KeyType key){this.key = key;}
    KeyType key;
}
//
struct UnicodeInputtedEvent{
    this(in uint key){this.key = key;}
    uint  key;
}

private mixin template MouseEvent(){
    int x, y, button;
    this(in int x, in int y, in int button){
        this.x = x;
        this.y = y;
        this.button = button;
    };
}
//
struct MouseDraggedEvent{mixin MouseEvent;}
struct MouseEnteredEvent{mixin MouseEvent;}
struct MouseExitedEvent{mixin MouseEvent;}
struct MouseMovedEvent{mixin MouseEvent;}
struct MousePressedEvent{mixin MouseEvent;}
struct MouseReleasedEvent{mixin MouseEvent;}
struct MouseScrolledEvent{mixin MouseEvent;}

private mixin template TouchEvent(){
    int x, y, id;
    this(in int x, in int y, in int id){
        this.x = x;
        this.y = y;
        this.id = id;
    };
}
//
struct TouchCancelledEvent{mixin TouchEvent;}
struct TouchDoubleTapEvent{mixin TouchEvent;}
struct TouchDownEvent{mixin TouchEvent;}
struct TouchMovedEvent{mixin TouchEvent;}
struct TouchUpEvent{mixin TouchEvent;}

struct WindowResizeEvent{
    int w, h;
    this(in int w, in int h){
        this.w = w;
        this.h = h;
    }
}
