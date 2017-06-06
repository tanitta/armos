module armos.utils.gui;

// import armos.graphics;
import armos.types.color;
import armos.app;
import armos.math;
import armos.events;
import armos.graphics.bitmapfont;

public import armos.utils.gui.style;
public import armos.utils.gui.widgets;

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
            _style.font = new BitmapFont;
            _style.font.load("font.png", 8, 8);
            _style.colors["font1"] = Color(200.0/255.0, 200.0/255.0, 200.0/255.0);
            _style.colors["font2"] = Color(105.0/255.0, 105.0/255.0, 105.0/255.0);
            _style.colors["background"] = Color(40.0/255.0, 40.0/255.0, 40.0/255.0, 200.0/255.0);
            _style.colors["base1"] = Color(0.25, 0.25, 0.25);
            _style.colors["base2"] = Color(150.0/255.0, 150.0/255.0, 150.0/255.0);
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
            import armos.graphics.renderer;
            pushStyle;
            blendMode(BlendMode.Alpha);
            disableDepthTest;

            int currentWidth = 0;
            foreach (list; _lists) {
                pushMatrix;
                translate(currentWidth, 0, 0);
                list.draw(currentWidth);
                popMatrix;
                currentWidth += list.width + _style.font.width;
            }
            popStyle;
        }

    }//public

    private{
        List[] _lists;
        Style _style;
    }//private
}//class Gui


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
                import armos.graphics;
                pushMatrix;
                translate(0, currentHeight, 0);
                widget.position = Vector2i(posX, currentHeight);
                widget.draw();
                popMatrix;
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
