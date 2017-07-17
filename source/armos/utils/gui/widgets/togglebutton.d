module armos.utils.gui.widgets.togglebutton;

public import armos.utils.gui.widgets.widget;

///
class ToggleButton : Widget{
    public{
        this(in string name, ref bool v){
            _v = &v;
            _name = name;

            static import armos.events;
            static import armos.app;
            armos.events.addListener(armos.app.currentEvents.mouseReleased, this, &this.mouseReleased);
            armos.events.addListener(armos.app.currentEvents.mousePressed, this, &this.mousePressed);

            _height = 32;
        }

        /++
        +/
        override void draw(){
            import armos.graphics:color,
                                  drawRectangle;
            color(_style.colors["background"]);
            drawRectangle(0, 0, _style.width, _style.font.height*4);

            _style.font.material.uniform("diffuse", _style.colors["font1"]);
            _style.font.draw(_name, _style.font.width, 0);

            if(*_v){
                color(_style.colors["base2"]);
            }else{
                color(_style.colors["base1"]);
            }

            drawRectangle(_style.font.width, _style.font.height, _style.font.width*2, _style.font.height*2);
        }

        /++
        +/
        override void mousePressed(ref armos.events.MousePressedEventArg message){
            _isPressing = isOnMouse(message.x, message.y);
        }

        /++
        +/
        override void mouseReleased(ref armos.events.MouseReleasedEventArg message){
            if(_isPressing){
                *_v = !(*_v);
                _isPressing = false;
            }
        }
    }//public

    private{
        bool* _v;
        string _name;
        bool _isPressing = false;

        bool isOnMouse(in int x, in int y){
            immutable int localX = x-_position[0];
            immutable int localY = y-_position[1];
            if(_style.font.width<localX && localX<_style.font.width*3){
                if(_style.font.height<localY && localY<_style.font.height*3){
                    return true;
                }
            }
            return false;
        }
    }//private
}//class ToggleButton
