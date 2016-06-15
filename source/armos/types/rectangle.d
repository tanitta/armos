module armos.types.rectangle;
import armos.math;
/++
長方形を表すstructです．
+/
struct Rectangle {
    armos.math.Vector2f position;
    armos.math.Vector2f size;

    // this(){
    // 	// auto position = new armos.math.Vector2f;
    // 	// auto size = new armos.math.Vector2f;
    // };

    /++
        開始点と終了点を指定して初期化します．
    +/
    this(armos.math.Vector2f p, armos.math.Vector2f s){
        position = p;
        size = s;
    }

    /++
        開始点と終了点を指定します．
    +/
    void set(in float x, in float y, in float width, in float height){
        position = armos.math.Vector2f(x, y);
        size = armos.math.Vector2f(width, height);
    }

    /++
        開始点と終了点を指定します．
    +/
    void set(in armos.math.Vector2f p, in armos.math.Vector2f s){
        position = cast( armos.math.Vector2f )p;
        size = cast( armos.math.Vector2f )s;
    }

    /++
        開始点のX座標のプロパティです．
    +/
    float x(){return position[0];}
    void x(float x_){position[0] = x_;}

    /++
        開始点のY座標のプロパティです．
    +/
    float y(){return position[1];}
    void y(float y_){position[1] = y_;}


    /++
        終了点のX座標のプロパティです．
    +/
    float width(){return size[0];}
    void width(float width_){size[0] = width_;}

    /++
        終了点のY座標のプロパティです．
    +/
    float height(){return size[1];}
    void height(float height_){size[1] = height_;}
}

