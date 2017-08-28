module armos.events;
public import armos.events.event;
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
        }
    }//public

    private{
    }//private
}//class CoreSubjects

class CoreObserbable{
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
}
