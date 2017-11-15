module armos.events;

public import armos.events.events;

import rx;

/++
+/
class CoreSubjects {
    public{
        SubjectObject!SetupEvent setup;
        SubjectObject!UpdateEvent update;
        SubjectObject!DrawEvent draw;
        SubjectObject!ExitEvent exit;
        SubjectObject!WindowResizeEvent windowResize;
        SubjectObject!KeyPressedEvent keyPressed;
        SubjectObject!KeyReleasedEvent keyReleased;
        SubjectObject!UnicodeInputtedEvent unicodeInputted;
        SubjectObject!MouseDraggedEvent mouseDragged;
        SubjectObject!MouseEnteredEvent mouseEntered;
        SubjectObject!MouseMovedEvent mouseMoved;
        SubjectObject!MousePressedEvent mousePressed;
        SubjectObject!MouseReleasedEvent mouseReleased;
        SubjectObject!MouseScrolledEvent mouseScrolled;
        SubjectObject!TouchCancelledEvent touchCancelled;
        SubjectObject!TouchDoubleTapEvent touchDoubleTap;
        SubjectObject!TouchDownEvent touchDown;
        SubjectObject!TouchMovedEvent touchMoved;
        SubjectObject!TouchUpEvent touchUp;

        this(){
            setup           = new SubjectObject!SetupEvent;
            update          = new SubjectObject!UpdateEvent;
            draw            = new SubjectObject!DrawEvent;
            exit            = new SubjectObject!ExitEvent;
            windowResize    = new SubjectObject!WindowResizeEvent;
            keyPressed      = new SubjectObject!KeyPressedEvent;
            keyReleased     = new SubjectObject!KeyReleasedEvent;
            unicodeInputted = new SubjectObject!UnicodeInputtedEvent;
            mouseDragged    = new SubjectObject!MouseDraggedEvent;
            mouseEntered    = new SubjectObject!MouseEnteredEvent;
            mouseMoved      = new SubjectObject!MouseMovedEvent;
            mousePressed    = new SubjectObject!MousePressedEvent;
            mouseReleased   = new SubjectObject!MouseReleasedEvent;
            mouseScrolled   = new SubjectObject!MouseScrolledEvent;
            touchCancelled  = new SubjectObject!TouchCancelledEvent;
            touchDoubleTap  = new SubjectObject!TouchDoubleTapEvent;
            touchDown       = new SubjectObject!TouchDownEvent;
            touchMoved      = new SubjectObject!TouchMovedEvent;
            touchUp         = new SubjectObject!TouchUpEvent;

            mousePressed.doSubscribe!((MousePressedEvent pressedEvent){
                            auto disposable = mouseMoved.doSubscribe!((MouseMovedEvent movedEvent){
                                auto draggedEvent = MouseDraggedEvent();
                                    draggedEvent.firstX = pressedEvent.x;
                                    draggedEvent.firstY = pressedEvent.y;
                                    draggedEvent.x = movedEvent.x;
                                    draggedEvent.y = movedEvent.y;
                                    draggedEvent.button = pressedEvent.button;
                                    import std.range:put;
                                    put(mouseDragged, draggedEvent);
                                });
                            mouseReleased.doSubscribe!(event => disposable.dispose());
                        });
        }

        CoreObservables opCast(CoreObservables)(){
            return CoreObservables(this);
        }
    }//public

    private{
    }//private
}//class CoreSubjects

/++
+/
struct CoreObservables {
    public{
        this(CoreSubjects s){
            setup           = s.setup;
            update          = s.update;
            draw            = s.draw;
            exit            = s.exit;
            windowResize    = s.windowResize;
            keyPressed      = s.keyPressed;
            keyReleased     = s.keyReleased;
            unicodeInputted = s.unicodeInputted;
            mouseDragged    = s.mouseDragged;
            mouseEntered    = s.mouseEntered;
            mouseMoved      = s.mouseMoved;
            mousePressed    = s.mousePressed;
            mouseReleased   = s.mouseReleased;
            mouseScrolled   = s.mouseScrolled;
            touchCancelled  = s.touchCancelled;
            touchDoubleTap  = s.touchDoubleTap;
            touchDown       = s.touchDown;
            touchMoved      = s.touchMoved;
            touchUp         = s.touchUp;
        }

        Observable!SetupEvent setup;
        Observable!UpdateEvent update;
        Observable!DrawEvent draw;
        Observable!ExitEvent exit;
        Observable!WindowResizeEvent windowResize;
        Observable!KeyPressedEvent keyPressed;
        Observable!KeyReleasedEvent keyReleased;
        Observable!UnicodeInputtedEvent unicodeInputted;
        Observable!MouseDraggedEvent mouseDragged;
        Observable!MouseEnteredEvent mouseEntered;
        Observable!MouseMovedEvent mouseMoved;
        Observable!MousePressedEvent mousePressed;
        Observable!MouseReleasedEvent mouseReleased;
        Observable!MouseScrolledEvent mouseScrolled;
        Observable!TouchCancelledEvent touchCancelled;
        Observable!TouchDoubleTapEvent touchDoubleTap;
        Observable!TouchDownEvent touchDown;
        Observable!TouchMovedEvent touchMoved;
        Observable!TouchUpEvent touchUp;
    }//public

    private{
    }//private
}//struct CoreObservables

CoreObservables currentObservables(){
    import armos.app.window;
    return currentWindow.observables;
}
