module armos.utils.gui.widgets.slider;

import armos.utils.gui.widgets.widget;

import armos.events;

/++
値を操作するSliderを表す，Widgetを継承したclassです．
+/
class Slider(T) : Widget{
    import std.format:format;
    import std.conv;
    public{
        /++
            初期化を行います．Slider固有の名前と操作する値，その上限下限を設定します．
        +/
        this(string name, ref T var, T min, T max){
            _var = &var;
            _varMin = min;
            _varMax = max;
            _name = name;
            _height = 32;

            static import armos.app;
            armos.events.addListener(armos.app.currentEvents.mouseMoved, this, &this.mouseMoved);
            armos.events.addListener(armos.app.currentEvents.mouseReleased, this, &this.mouseReleased);
            armos.events.addListener(armos.app.currentEvents.mousePressed, this, &this.mousePressed);
        };

        /++
        +/
        override void draw(){
            import armos.graphics.renderer:color,
                                           drawRectangle;

            color(_style.colors["background"]);
            drawRectangle(0, 0, _style.width, _style.font.height*4);

            string varString = "";
            static if(__traits(isIntegral, *_var)){
                varString = format("%d", *_var).to!string;
            }else if(__traits(isFloating, *_var)){
                varString = format("%f", *_var).to!string;
            }
            _style.font.material.attr("diffuse", _style.colors["font1"]);
            
            _style.font.draw(_name ~ " : " ~ varString, _style.font.width, 0);

            import armos.math:map;
            immutable int currentValueAsSliderPosition = map( ( *_var ).to!float, _varMin.to!float, _varMax.to!float, 0.0, _style.width.to!float - _style.font.width.to!float*2.0).to!int;
            color(_style.colors["base1"]);
            drawRectangle(_style.font.width, _style.font.height, _style.width - _style.font.width*2, _style.font.height*2);
            color(_style.colors["base2"]);
            drawRectangle(_style.font.width, _style.font.height, currentValueAsSliderPosition.to!int, _style.font.height*2);
        };

        /++
        +/
        override void mousePressed(ref armos.events.MousePressedEventArg message){
            _isPressing = isOnMouse(message.x, message.y);
        }

        /++
        +/
        override void mouseMoved(ref armos.events.MouseMovedEventArg message){
            if(_isPressing){
                import armos.math:map;
                *_var = map( 
                        ( message.x-_position[0]).to!float,
                        _style.font.width.to!float, _style.width.to!float - _style.font.width.to!float, 
                        _varMin.to!float, _varMax.to!float
                        , true).to!T;
            }
        }

        /++
        +/
        override void mouseReleased(ref armos.events.MouseReleasedEventArg message){
            if(_isPressing){
                import armos.math:map;
                *_var = map( 
                        ( message.x-_position[0]).to!float,
                        _style.font.width.to!float, _style.width.to!float - _style.font.width.to!float, 
                        _varMin.to!float, _varMax.to!float
                        , true).to!T;
                _isPressing = false;
            }
        }
    }//public

    private{
        string _name;
        T* _var;
        T _varMin;
        T _varMax;
        bool _isPressing = false;

        bool isOnMouse(int x, int y){
            immutable int localX = x-_position[0];
            immutable int localY = y-_position[1];
            if(_style.font.width<localX && localX<_style.width - _style.font.width){
                if(_style.font.height<localY && localY<_height - _style.font.height){
                    return true;
                }
            }
            return false;
        }
    }//private
}//class Slider
