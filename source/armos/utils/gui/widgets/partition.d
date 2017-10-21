module armos.utils.gui.widgets.partition;

import armos.utils.gui.widgets.widget;

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
            pragma(msg, __FILE__, "(", __LINE__, "): ",
                   "TODO: enable to work");
            // import armos.graphics.renderer:color,
            //                                drawRectangle;
            //
            // color(_style.colors["background"]);
            // drawRectangle(0, 0, _style.width, _style.font.height*2);
            // _style.font.material.uniform("diffuse", _style.colors["font2"]);
            // string str;
            // for (int i = 0; i < _style.width/_style.font.width/_str.length; i++) {
            //     str ~= _str;
            // }
            // _style.font.draw(str, 0, 0);
        };

    }//public

    private{
        string _str;
    }//private
}//class Partition
