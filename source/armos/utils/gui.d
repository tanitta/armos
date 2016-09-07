module armos.utils.gui;
static import armos.graphics;
static import armos.types.color;
static import armos.app;
static import armos.math;
static import armos.events;

/++
値にアクセスするGuiを表すclassです．

Examples:
---
class TestApp : ar.BaseApp{
    ar.Gui gui;
    float f=128;

    void setup(){
        gui = (new ar.Gui)
            .add(
                    (new ar.List)
                    .add(new ar.Partition)
                    .add(new ar.Label("some text"))
                    .add(new ar.Partition("*"))
                )
            .add(
                    (new ar.List)
                    .add(new ar.Partition)
                    .add(new ar.Slider!float("slider!float", f, 0, 255))
                );
    }

    void draw(){
        f.writeln;
        gui.draw;
    }
}
void main(){ar.run(new TestApp);}
---
+/
class Gui {
    public{
        /++
        +/
        this(){
            _style = new Style;
            _style.font = new armos.graphics.BitmapFont;
            _style.font.load("font.png", 8, 8);
            _style.colors["font1"] = armos.types.Color(200, 200, 200);
            _style.colors["font2"] = armos.types.Color(105, 105, 105);
            _style.colors["background"] = armos.types.Color(40, 40, 40, 200);
            _style.colors["base1"] = armos.types.Color(64, 64, 64);
            _style.colors["base2"] = armos.types.Color(150, 150, 150);
            _style.width = 256;
        }

        /++
            Listを自身に追加します．また自身を返すためメソッドチェインが可能です．
        +/
        Gui add(List list){
            _lists ~= list;
            list.style = _style;
            return this;
        };

        /++
            Guiの内部のウィジェットを再帰的に描画します．
        +/
        void draw(){
            armos.graphics.pushStyle;
            armos.graphics.blendMode(armos.graphics.BlendMode.Alpha);
            armos.graphics.disableDepthTest;

            int currentWidth = 0;
            foreach (list; _lists) {
                armos.graphics.pushMatrix;
                armos.graphics.translate(currentWidth, 0, 0);
                list.draw(currentWidth);
                armos.graphics.popMatrix;
                currentWidth += list.width + _style.font.width;
            }
            armos.graphics.popStyle;
        }

    }//public

    private{
        List[] _lists;
        Style _style;
    }//private
}//class Gui

class Style {
    public{
        this(){}

        int width = 256;
        armos.graphics.BitmapFont font;

        armos.types.color.Color[string] colors;
    }//public

    private{
    }//private
}//class Style

/++
Guiの構成要素でWidgetを複数格納するclassです．
+/
class List {
    public{

        /++
            Widgetを追加します．また自身を返すためメソッドチェインが可能です．
        +/
        List add(Widget widget){
            _widgets ~= widget;
            return this;
        }

        /++
        +/
        void style(Style stl){
            foreach (widget; _widgets) {
                widget.style = stl;
            }
        }

        /++
            Widgetを描画します．
        +/
        void draw(in int posX){
            int currentHeight= 0;
            foreach (widget; _widgets) {
                armos.graphics.pushMatrix;
                armos.graphics.translate(0, currentHeight, 0);
                widget.position = armos.math.Vector2i(posX, currentHeight);
                widget.draw();
                armos.graphics.popMatrix;
                currentHeight += widget.height;
            }
        }

        /++
        +/
        int width()const{
            return _width;
        }
    }//public

    private{
        Widget[] _widgets;
        int _width = 256;
    }//private
}//class List

/++
LabelやSlider等の基底クラスです．Listの構成要素となります．
+/
class Widget {
    public{
        /++
            描画を行います．
        +/
        void draw(){};

        /++
            Widgetの高さを返します．
        +/
        int height()const{return _height;}

        /++
        +/
        void style(Style stl){_style = stl;}

        /++
            Widgetの座標を返します．
        +/
        void position(armos.math.Vector2i pos){_position = pos;}

        /++
        +/
        void update(ref armos.events.EventArg arg){}

        /++
            マウスが動いた時に呼ばれるイベントハンドラです．
        +/
        void mouseMoved(ref armos.events.MouseMovedEventArg message){}

        /++
            マウスのボタンが離された時に呼ばれるイベントハンドラです．
        +/
        void mouseReleased(ref armos.events.MouseReleasedEventArg message){}

        /++
            マウスのボタンが押された時に呼ばれるイベントハンドラです．
        +/
        void mousePressed(ref armos.events.MousePressedEventArg message){}
    }//public

    private{
        int _height = 128;
    }//private

    protected{
        armos.math.Vector2i _position;
        Style _style;
    }//protected
}//class Widget

/++
文字列を表示するWidgetを継承したclassです．
+/
class Label : Widget{
    public{
        /++
            表示する文字列を指定して初期化を行います．
        +/
        this(string str){
            _str = str;
            _height = 16;
        };

        /++
        +/
        override void draw(){
            armos.graphics.color(_style.colors["background"]);
            armos.graphics.drawRectangle(0, 0, _style.width, _style.font.height*2);
            _style.font.material.attr("diffuse", _style.colors["font1"]);
            _style.font.draw(_str, _style.font.width, 0);
        };
    }//public

    private{
        string _str;
    }//private
}//class Label

/++
パーティションを表示するWidgetを継承したclassです．
+/
class Partition : Widget{
    public{
        /++
            初期化を行います．区切り文字を指定することもできます．
        +/
        this(string str = "/"){
            _str = str;
            _height = 16;
        };

        /++
        +/
        override void draw(){
            armos.graphics.color(_style.colors["background"]);
            armos.graphics.drawRectangle(0, 0, _style.width, _style.font.height*2);
            _style.font.material.attr("diffuse", _style.colors["font2"]);
            string str;
            for (int i = 0; i < _style.width/_style.font.width/_str.length; i++) {
                str ~= _str;
            }
            _style.font.draw(str, 0, 0);
        };

    }//public

    private{
        string _str;
    }//private
}//class Partition

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
            armos.events.addListener(armos.app.currentWindow.events.mouseMoved, this, &this.mouseMoved);
            armos.events.addListener(armos.app.currentWindow.events.mouseReleased, this, &this.mouseReleased);
            armos.events.addListener(armos.app.currentWindow.events.mousePressed, this, &this.mousePressed);
        };

        /++
        +/
        override void draw(){
            armos.graphics.color(_style.colors["background"]);
            armos.graphics.drawRectangle(0, 0, _style.width, _style.font.height*4);

            string varString = "";
            static if(__traits(isIntegral, *_var)){
                varString = format("%d", *_var).to!string;
            }else if(__traits(isFloating, *_var)){
                varString = format("%f", *_var).to!string;
            }
            _style.font.material.attr("diffuse", _style.colors["font1"]);
            
            _style.font.draw(_name ~ " : " ~ varString, _style.font.width, 0);

            immutable int currentValueAsSliderPosition = armos.math.map.map( ( *_var ).to!float, _varMin.to!float, _varMax.to!float, 0.0, _style.width.to!float - _style.font.width.to!float*2.0).to!int;
            armos.graphics.color(_style.colors["base1"]);
            armos.graphics.drawRectangle(_style.font.width, _style.font.height, _style.width - _style.font.width*2, _style.font.height*2);
            armos.graphics.color(_style.colors["base2"]);
            armos.graphics.drawRectangle(_style.font.width, _style.font.height, currentValueAsSliderPosition.to!int, _style.font.height*2);
        };

        /++
        +/
        void mousePressed(ref armos.events.MousePressedEventArg message){
            _isPressing = isOnMouse(message.x, message.y);
        }

        /++
        +/
        void mouseMoved(ref armos.events.MouseMovedEventArg message){
            if(_isPressing){
                *_var = armos.math.map.map( 
                        ( message.x-_position[0]).to!float,
                        _style.font.width.to!float, _style.width.to!float - _style.font.width.to!float, 
                        _varMin.to!float, _varMax.to!float
                        , true).to!T;
            }
        }

        /++
        +/
        void mouseReleased(ref armos.events.MouseReleasedEventArg message){
            if(_isPressing){
                *_var = armos.math.map.map( 
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

/++
+/
class MovingGraph(T) : Widget{
    import armos.graphics.mesh;
    import std.conv;
    public{
        this(in string name, ref T var, in T min, in T max){
            _name = name;
            _var = &var;
            _varMin = min;
            _varMax= max;
            _height = 128;
            _lines = new armos.graphics.Mesh();
            _lines.primitiveMode = armos.graphics.PrimitiveMode.LineStrip;
            foreach (int i, v; _buffer) {
                v = _varMin;
                _lines.addVertex(i.to!float/_bufferSize.to!float, v, 0);
                _lines.addIndex(i);
            }
            armos.events.addListener(armos.app.currentWindow.events.update, this, &this.update);
        }

        void update(ref armos.events.EventArg arg){
            for (int i = 0; i < _bufferSize -1; i++) {
                _buffer[i] = _buffer[i+1];
            }
            _buffer[$-1] = *_var;
        };

        override void draw(){
            armos.graphics.color(_style.colors["background"]);
            armos.graphics.drawRectangle(0, 0, _style.width, _style.font.height*16);

            import std.format:format;
            import std.conv;
            string varString = "";
            static if(__traits(isIntegral, *_var)){
                varString = format("%d", *_var).to!string;
            }else if(__traits(isFloating, *_var)){
                varString = format("%f", *_var).to!string;
            }
            _style.font.material.attr("diffuse", _style.colors["font1"]);
            _style.font.draw(_name ~ " : " ~ varString, _style.font.width, 0);

            armos.graphics.color(_style.colors["base1"]);
            armos.graphics.drawRectangle(_style.font.width, _style.font.height, _style.width - _style.font.width*2, _style.font.height*14);

            drawLine;
        }
    }//public

    private{
        string _name;
        T* _var;
        T _varMin;
        T _varMax;
        enum int _bufferSize = 30;
        T[_bufferSize] _buffer;
        armos.graphics.Mesh _lines;

        void drawLine(){
            import std.conv;
            armos.graphics.color(_style.colors["font1"]);
            foreach (i, v; _buffer) {
                immutable x = armos.math.map.map( i.to!float, 0f, 30f, _style.font.width.to!float, _style.width.to!float);
                immutable y = armos.math.map.map( _varMax - v, _varMin, _varMax, _style.font.height.to!float, _style.font.height.to!float*15);
                _lines.vertices[i][0] = x;
                _lines.vertices[i][1] = y;
                // y = armos.math.map.map( v, _varMin, _varMax, _style.font.width.to!float, _style.width.to!float - _style.font.width.to!float);
            }
            _lines.drawWireFrame;
        }
    }//private
}//class MovingGraph

import armos.graphics.mesh;
/++
+/
class MovingGraphXY(T) : Widget{
    public{
        this(in string nameX, ref T varX, in T minX, in T maxX, in string nameY, ref T varY, in T minY, in T maxY){
            _nameX = nameX;
            _nameY = nameY;
            _varX = &varX;
            _varY = &varY;
            _varMin = armos.math.Vector!(T, 2)(minX, minY);
            _varMax = armos.math.Vector!(T, 2)(maxX, maxY);

            _height = 128+16;
            _lines = new armos.graphics.Mesh();
            _lines.primitiveMode = armos.graphics.PrimitiveMode.LineStrip;
            foreach (int i, v; _buffer) {
                v = _varMin;
                _lines.addVertex(0, 0, 0);
                _lines.addIndex(i);
            }
            armos.events.addListener(armos.app.currentWindow.events.update, this, &this.update);
        }

        void update(ref armos.events.EventArg arg){
            for (int i = 0; i < _bufferSize -1; i++) {
                _buffer[i] = _buffer[i+1];
            }
            _buffer[$-1] = armos.math.Vector!(T, 2)(*_varX, *_varY);
        };

        override void draw(){
            armos.graphics.color(_style.colors["background"]);
            armos.graphics.drawRectangle(0, 0, _style.width, _style.font.height*18);

            import std.format:format;
            import std.conv;
            string varStringX = "";
            string varStringY = "";
            static if(__traits(isIntegral, T)){
                varStringX = format("%d", *_varX).to!string;
                varStringY = format("%d", *_varY).to!string;
            }else if(__traits(isFloating, T)){
                varStringX = format("%f", *_varX).to!string;
                varStringY = format("%f", *_varY).to!string;
            }
            _style.font.material.attr("diffuse", _style.colors["font1"]);
            _style.font.draw(_nameX ~ " : " ~ varStringX, _style.font.width, 0);
            _style.font.draw(_nameY ~ " : " ~ varStringY, _style.font.width, _style.font.height);

            armos.graphics.color(_style.colors["base1"]);
            armos.graphics.drawRectangle(_style.font.width, _style.font.height*2, _style.width - _style.font.width*2, _style.font.height*15);

            drawLine;
        }
    }//public

    private{
        string _nameX;
        string _nameY;
        T* _varX;
        T* _varY;
        armos.math.Vector!(T, 2) _varMin;
        armos.math.Vector!(T, 2) _varMax;
        enum int _bufferSize = 30;
        armos.math.Vector!(T, 2)[_bufferSize] _buffer;
        armos.graphics.Mesh _lines;

        void drawLine(){
            import std.conv;
            armos.graphics.color(_style.colors["font1"]);
            foreach (i, v; _buffer) {
                immutable x = armos.math.map.map( v[0], _varMin[0], _varMax[0], _style.font.width.to!float, _style.width - _style.font.width);
                immutable y = armos.math.map.map(  - v[1], _varMin[1], _varMax[1], _style.font.height.to!float*2, _style.font.height.to!float*17);
                _lines.vertices[i].x = x;
                _lines.vertices[i].y = y;
                // y = armos.math.map.map( v, _varMin, _varMax, _style.font.width.to!float, _style.width.to!float - _style.font.width.to!float);
            }
            _lines.drawWireFrame;
        }
    }//private
}//class MovingGraph

/++
+/
class Button : Widget{
    public{
        this(in string name, ref bool v){
            _v = &v;
            _name = name;

            armos.events.addListener(armos.app.currentWindow.events.mouseReleased, this, &this.mouseReleased);
            armos.events.addListener(armos.app.currentWindow.events.mousePressed, this, &this.mousePressed);

            _height = 32;
        }

        /++
        +/
        override void draw(){
            armos.graphics.color(_style.colors["background"]);
            armos.graphics.drawRectangle(0, 0, _style.width, _style.font.height*4);

            _style.font.material.attr("diffuse", _style.colors["font1"]);
            _style.font.draw(_name, _style.font.width, 0);

            if(*_v){
                armos.graphics.color(_style.colors["base2"]);
            }else{
                armos.graphics.color(_style.colors["base1"]);
            }

            armos.graphics.drawRectangle(_style.font.width, _style.font.height, _style.font.width*2, _style.font.height*2);
        }

        /++
        +/
        override void mousePressed(ref armos.events.MousePressedEventArg message){
            _isPressing = isOnMouse(message.x, message.y);
            if(_isPressing){
                *_v = true;
            }
        }

        /++
        +/
        override void mouseReleased(ref armos.events.MouseReleasedEventArg message){
            *_v = false;
            if(_isPressing){
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
}//class Button


/++
+/
class ToggleButton : Widget{
    public{
        this(in string name, ref bool v){
            _v = &v;
            _name = name;

            armos.events.addListener(armos.app.currentWindow.events.mouseReleased, this, &this.mouseReleased);
            armos.events.addListener(armos.app.currentWindow.events.mousePressed, this, &this.mousePressed);

            _height = 32;
        }

        /++
        +/
        override void draw(){
            armos.graphics.color(_style.colors["background"]);
            armos.graphics.drawRectangle(0, 0, _style.width, _style.font.height*4);

            _style.font.material.attr("diffuse", _style.colors["font1"]);
            _style.font.draw(_name, _style.font.width, 0);

            if(*_v){
                armos.graphics.color(_style.colors["base2"]);
            }else{
                armos.graphics.color(_style.colors["base1"]);
            }

            armos.graphics.drawRectangle(_style.font.width, _style.font.height, _style.font.width*2, _style.font.height*2);
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
