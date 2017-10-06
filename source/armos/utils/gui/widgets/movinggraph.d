module armos.utils.gui.widgets.movinggraph;

import armos.utils.gui.widgets.widget;

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
            _lines = new Mesh();

            import armos.graphics.renderer:PrimitiveMode;

            _lines.primitiveMode = PrimitiveMode.LineStrip;
            foreach (int i, v; _buffer) {
                v = _varMin;
                _lines.addVertex(i.to!float/_bufferSize.to!float, v, 0);
                _lines.addIndex(i);
            }

            import armos.events;
            import armos.app;
            import rx;

            currentObservables.update.doSubscribe!(event => this.update(event));
        }

        override void update(ref armos.events.UpdateEvent arg){
            for (int i = 0; i < _bufferSize -1; i++) {
                _buffer[i] = _buffer[i+1];
            }
            _buffer[$-1] = *_var;
        };

        override void draw(){
            import armos.graphics.renderer:color,
                                           drawRectangle;
            color(_style.colors["background"]);
            drawRectangle(0, 0, _style.width, _style.font.height*16);

            import std.format:format;
            import std.conv;
            string varString = "";
            static if(__traits(isIntegral, *_var)){
                varString = format("%d", *_var).to!string;
            }else if(__traits(isFloating, *_var)){
                varString = format("%f", *_var).to!string;
            }
            _style.font.material.uniform("diffuse", _style.colors["font1"]);
            _style.font.draw(_name ~ " : " ~ varString, _style.font.width, 0);

            color(_style.colors["base1"]);
            drawRectangle(_style.font.width, _style.font.height, _style.width - _style.font.width*2, _style.font.height*14);

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
        Mesh _lines;

        void drawLine(){
            import std.conv;
            import armos.graphics.renderer:color;
            color(_style.colors["font1"]);
            foreach (i, v; _buffer) {
                import armos.math:map;
                immutable x = map( i.to!float, 0f, 30f, _style.font.width.to!float, _style.width.to!float);
                immutable y = map( _varMax - v, _varMin, _varMax, _style.font.height.to!float, _style.font.height.to!float*15);
                _lines.vertices[i][0] = x;
                _lines.vertices[i][1] = y;
                // y = map.map( v, _varMin, _varMax, _style.font.width.to!float, _style.width.to!float - _style.font.width.to!float);
            }
            _lines.drawWireFrame;
        }
    }//private
}//class MovingGraph
