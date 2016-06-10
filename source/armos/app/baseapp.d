module armos.app.baseapp;
import armos.events;
import armos.math;

/++
armosの中心となるクラスです．プロジェクトを作成する際はこのクラスを継承して処理を記述していきます．
+/
class BaseApp{
    /++
        事前処理を記述するメンバ関数です．initializerによる初期化が行われた後，一度だけ実行されます．
        +/
        void setup(ref armos.events.EventArg arg){
            setup();
        }

    /++
        毎フレーム実行されるメンバ関数です．
        +/
        void update(ref armos.events.EventArg arg){
            update();
        }

    /++
        毎フレーム実行されるメンバ関数です．updateの次に呼ばれます．描画処理を記述します．
        +/
        void draw(ref armos.events.EventArg arg){
            draw();
        }

    /++
        事前処理を記述するメンバ関数です．initializerによる初期化が行われた後，一度だけ実行されます．
        +/
        void setup(){};

    /++
        毎フレーム実行されるメンバ関数です．
        +/
        void update(){};

    /++
        毎フレーム実行されるメンバ関数です．updateの次に呼ばれます．描画処理を記述します．
        +/
        void draw(){};


    /++
        終了時に一度だけ呼ばれるメンバ関数です．
        +/
        void exit(ref armos.events.EventArg arg){
            exit();
        };

    /++
        終了時に一度だけ呼ばれるメンバ関数です．
        +/
        void exit(){};

    /++
        キーボードを押した際に呼ばれるメンバ関数です．
        Params:
        message = キーボードの状態が格納されたメッセージです．
        +/
        void keyPressed(ref armos.events.KeyPressedEventArg message) {
            keyPressed(message.key);
        }

    /++
        キーボードを押した際に呼ばれるメンバ関数です．
        Params:
        str = 離したキーのascii番号が格納されています．
        +/
        void keyPressed(int str) {
        }

    /++
        キーボードを離した際に呼ばれるメンバ関数です．
        Params:
        message = キーボードの状態が格納されたメッセージです．
        +/
        void keyReleased(ref armos.events.KeyReleasedEventArg message) {
            keyReleased(message.key);
        }

    /++
        キーボードを離した際に呼ばれるメンバ関数です．
        Params: 
        str = 離したキーのascii番号が格納されています．
        +/
        void keyReleased(int str) {
        }

    /++
        マウス位置を表すプロパティです．
        +/
        int mouseX, mouseY;

    /++
        マウスが動いた際に呼ばれるメンバ関数です．
        Params:
        message = マウスの状態が格納されたメッセージです．
        +/
        void mouseMoved(ref armos.events.MouseMovedEventArg message){
            mouseMoved(message.x, message.y, message.button );
            mouseMoved(armos.math.Vector2f(message.x, message.y), message.button);
            mouseMoved(armos.math.Vector2i(message.x, message.y), message.button);
        }

    /++
        マウスが動いた際に呼ばれるメンバ関数です．
        Params:
        x = マウスのX座標です．
        y = マウスのY座標です．
        +/
        void mouseMoved(int x, int y, int button){}

    /++
        マウスが動いた際に呼ばれるメンバ関数です．
        Params:
        position = マウスの座標を表します．
        +/
        void mouseMoved(armos.math.Vector2f position, int button){}

    /++
        マウスが動いた際に呼ばれるメンバ関数です．
        Params:
        position = マウスの座標を表します．
        +/
        void mouseMoved(armos.math.Vector2i position, int button){}

    /++
        マウスがドラッグされた際に呼ばれるメンバ関数です．
        Deprecated: 現在動作しません．
        +/
        void mouseDragged(ref armos.events.MouseDraggedEventArg message){
            mouseDragged(message.x, message.y, message.button );
            mouseDragged(armos.math.Vector2f(message.x, message.y), message.button);
            mouseDragged(armos.math.Vector2i(message.x, message.y), message.button);
        }

    /++
        マウスがドラッグされた際に呼ばれるメンバ関数です．
        Deprecated: 現在動作しません．
        +/
        void mouseDragged(int x, int y, int button){}

    /++
        マウスがドラッグされた際に呼ばれるメンバ関数です．
        Deprecated: 現在動作しません．
        +/
        void mouseDragged(armos.math.Vector2f position, int button){}

    /++
        マウスがドラッグされた際に呼ばれるメンバ関数です．
        Deprecated: 現在動作しません．
        +/
        void mouseDragged(armos.math.Vector2i position, int button){}


    /++
        マウスのボタンが離れた際に呼ばれるメンバ関数です．
        Params:
        message = マウスの状態が格納されたメッセージです．
        +/
        void mouseReleased(ref armos.events.MouseReleasedEventArg message){
            mouseReleased(message.x, message.y, message.button );
            mouseReleased(armos.math.Vector2f(message.x, message.y), message.button);
            mouseReleased(armos.math.Vector2i(message.x, message.y), message.button);
        }

    /++
        マウスのボタンが離れた際に呼ばれるメンバ関数です．
        Params:
        x = マウスのX座標を表します．
        y = マウスのY座標を表します．
        button = 離れたマウスのボタンを表します．
        +/
        void mouseReleased(int x, int y, int button){}

    /++
        マウスのボタンが離れた際に呼ばれるメンバ関数です．
        Params:
        position = マウスの座標を表します．
        button = 離れたマウスのボタンを表します．
        +/
        void mouseReleased(armos.math.Vector2f position, int button){}

    /++
        マウスのボタンが離れた際に呼ばれるメンバ関数です．
        Params:
        position = マウスの座標を表します．
        button = 離れたマウスのボタンを表します．
        +/
        void mouseReleased(armos.math.Vector2i position, int button){}

    /++
        マウスのボタンが押された際に呼ばれるメンバ関数です．
        Params:
        message = マウスの状態が格納されたメッセージです．
        +/
        void mousePressed(ref armos.events.MousePressedEventArg message){
            mousePressed(message.x, message.y, message.button );
            mousePressed(armos.math.Vector2f(message.x, message.y), message.button);
            mousePressed(armos.math.Vector2i(message.x, message.y), message.button);
        }

    /++
        マウスのボタンが押された際に呼ばれるメンバ関数です．
        Params:
        x = マウスのX座標を表します．
        y = マウスのY座標を表します．
        button = 押されたマウスのボタンを表します．
        +/
        void mousePressed(int x, int y, int button){}

    /++
        マウスのボタンが押された際に呼ばれるメンバ関数です．
        Params:
        position = マウスの座標を表します．
        button = 押されたマウスのボタンを表します．
        +/
        void mousePressed(armos.math.Vector2f position, int button){}

    /++
        マウスのボタンが押された際に呼ばれるメンバ関数です．
        Params:
        position = マウスの座標を表します．
        button = 押されたマウスのボタンを表します．
        +/
        void mousePressed(armos.math.Vector2i position, int button){}
}
