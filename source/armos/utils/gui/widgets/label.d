module armos.utils.gui.widgets.label;

import armos.utils.gui.widgets.widget;

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
            pragma(msg, __FILE__, "(", __LINE__, "): ",
                   "TODO: enable to work");
            // import armos.graphics.renderer:color,
            //                                drawRectangle;
            //
            // color(_style.colors["background"]);
            // drawRectangle(0, 0, _style.width, _style.font.height*2);
            // _style.font.material.uniform("diffuse", _style.colors["font1"]);
            // _style.font.draw(_str, _style.font.width, 0);
        };
    }//public

    private{
        string _str;
    }//private
}//class Label
