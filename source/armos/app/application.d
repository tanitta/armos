module armos.app.application;

import armos.events;
import armos.utils.keytype;
/++
armosの中心となるクラスです．プロジェクトを作成する際はこのクラスを継承して処理を記述していきます．
+/
interface Application{
    /++
        事前処理を記述するメンバ関数です．initializerによる初期化が行われた後，一度だけ実行されます．
    +/
    void setup(ref SetupEvent arg);

    /++
        毎フレーム実行されるメンバ関数です．
    +/
    void update(ref UpdateEvent arg);

    /++
        毎フレーム実行されるメンバ関数です．updateの次に呼ばれます．描画処理を記述します．
    +/
    void draw(ref DrawEvent arg);

    /++
        終了時に一度だけ呼ばれるメンバ関数です．
    +/
    void exit(ref ExitEvent arg);

    ///
    void windowResized(ref WindowResizeEvent message);

    /++
        キーボードを押した際に呼ばれるメンバ関数です．
        Params:
        message = キーボードの状態が格納されたメッセージです．
    +/
    void keyPressed(ref KeyPressedEvent message);

    /++
        キーボードを離した際に呼ばれるメンバ関数です．
        Params:
        message = キーボードの状態が格納されたメッセージです．
    +/
    void keyReleased(ref KeyReleasedEvent message);
    
    ///
    void unicodeInputted(ref UnicodeInputtedEvent message);

    /++
        マウスが動いた際に呼ばれるメンバ関数です．
        Params:
        message = マウスの状態が格納されたメッセージです．
    +/
    void mouseMoved(ref MouseMovedEvent message);
    /++
        マウスがドラッグされた際に呼ばれるメンバ関数です．
    +/
    void mouseDragged(ref MouseDraggedEvent message);

    ///
    void mouseScrolled(ref MouseScrolledEvent message);

    /++
        マウスのボタンが離れた際に呼ばれるメンバ関数です．
        Params:
        message = マウスの状態が格納されたメッセージです．
    +/
    void mouseReleased(ref MouseReleasedEvent message);

    /++
        マウスのボタンが押された際に呼ばれるメンバ関数です．
        Params:
        message = マウスの状態が格納されたメッセージです．
    +/
    void mousePressed(ref MousePressedEvent message);

    ///
    bool hasPressedKey(in KeyType key)const;

    ///
    bool hasHeldKey(in KeyType key)const;

    ///
    bool hasReleasedKey(in KeyType key)const;

    ///
    void exitApp();

    ///
    bool shouldClose();
}

