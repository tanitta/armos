module armos.utils.gui.widgets.movinggraphxy;

import armos.utils.gui.widgets.widget;
import armos.math.vector;
import armos.graphics.mesh;

///
class MovingGraphXY(T) : Widget{
    public{
        this(in string nameX, ref T varX, in T minX, in T maxX, in string nameY, ref T varY, in T minY, in T maxY){
            _nameX = nameX;
            _nameY = nameY;
            _varX = &varX;
            _varY = &varY;
            _varMin = Vector!(T, 2)(minX, minY);
            _varMax = Vector!(T, 2)(maxX, maxY);

            _height = 128+16;
            _lines = new Mesh();
            import armos.graphics.renderer:PrimitiveMode;
            _lines.primitiveMode = PrimitiveMode.LineStrip;
            foreach (int i, v; _buffer) {
                v = _varMin;
                _lines.addVertex(0, 0, 0);
                _lines.addIndex(i);
            }
            static import armos.events;
            static import armos.app;
            armos.events.addListener(armos.app.currentEvents.update, this, &this.update);
        }

        override void update(ref armos.events.EventArg arg){
            for (int i = 0; i < _bufferSize -1; i++) {
                _buffer[i] = _buffer[i+1];
            }
            _buffer[$-1] = Vector!(T, 2)(*_varX, *_varY);
        };

        override void draw(){
            import armos.graphics.renderer:color,
                                           drawRectangle;
            color(_style.colors["background"]);
            drawRectangle(0, 0, _style.width, _style.font.height*18);

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

            color(_style.colors["base1"]);
            drawRectangle(_style.font.width, _style.font.height*2, _style.width - _style.font.width*2, _style.font.height*15);

            drawLine;
        }
    }//public

    private{
        string _nameX;
        string _nameY;
        T* _varX;
        T* _varY;
        Vector!(T, 2) _varMin;
        Vector!(T, 2) _varMax;
        enum int _bufferSize = 30;
        Vector!(T, 2)[_bufferSize] _buffer;
        Mesh _lines;

        void drawLine(){
            import std.conv;
            import armos.graphics.renderer:color;
            color(_style.colors["font1"]);
            foreach (i, v; _buffer) {
                import armos.math:map;
                immutable x = map( v[0], _varMin[0], _varMax[0], _style.font.width.to!float, _style.width - _style.font.width);
                immutable y = map(  - v[1], _varMin[1], _varMax[1], _style.font.height.to!float*2, _style.font.height.to!float*17);
                _lines.vertices[i].x = x;
                _lines.vertices[i].y = y;
                // y = map.map( v, _varMin, _varMax, _style.font.width.to!float, _style.width.to!float - _style.font.width.to!float);
            }
            _lines.drawWireFrame;
        }
    }//private
}//class MovingGraph
