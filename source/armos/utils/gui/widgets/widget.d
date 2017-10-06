module armos.utils.gui.widgets.widget;

import armos.events;

import armos.utils.gui.style;
import armos.math.vector;
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
        void position(Vector2i pos){_position = pos;}

        /++
        +/
        void update(ref armos.events.UpdateEvent arg){}

        /++
            マウスが動いた時に呼ばれるイベントハンドラです．
        +/
        void mouseMoved(ref armos.events.MouseMovedEvent message){}

        /++
            マウスのボタンが離された時に呼ばれるイベントハンドラです．
        +/
        void mouseReleased(ref armos.events.MouseReleasedEvent message){}

        /++
            マウスのボタンが押された時に呼ばれるイベントハンドラです．
        +/
        void mousePressed(ref armos.events.MousePressedEvent message){}
    }//public

    private{
    }//private

    protected{
        int _height = 128;
        Vector2i _position;
        Style _style;
    }//protected
}//class Widget
