module armos.app.baseapp;
import armos.app.application;
import armos.events;
import armos.math;
import armos.utils.keytype;

/++
armosの中心となるクラスです．プロジェクトを作成する際はこのクラスを継承して処理を記述していきます．
+/
class BaseApp: Application{
    /++
        事前処理を記述するメンバ関数です．initializerによる初期化が行われた後，一度だけ実行されます．
    +/
    void setup(ref SetupEvent arg){
        this.initHeldKeys;
        setup();
    }

    /++
        毎フレーム実行されるメンバ関数です．
    +/
    void update(ref UpdateEvent arg){
        update();
    }

    /++
        毎フレーム実行されるメンバ関数です．updateの次に呼ばれます．描画処理を記述します．
    +/
    void draw(ref DrawEvent arg){
        draw();
        this.updateKeys;
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
    void exit(ref ExitEvent arg){
        exit();
    };

    /++
        終了時に一度だけ呼ばれるメンバ関数です．
    +/
    void exit(){};
    
    ///
    void windowResized(ref WindowResizeEvent message){
        windowResized(message.w, message.h);
        windowResized(Vector2i(message.w, message.h));
        windowResized;
    }
    
    ///
    void windowResized(){}
    
    ///
    void windowResized(int w, int h){}
    
    ///
    void windowResized(Vector2i size){}

    /++
        キーボードを押した際に呼ばれるメンバ関数です．
        Params:
        message = キーボードの状態が格納されたメッセージです．
    +/
    void keyPressed(ref KeyPressedEvent message){
        import std.conv;
        keyPressed(message.key);
        this.PressKey(message.key);
    }
    
    /++
        キーボードを押した際に呼ばれるメンバ関数です．
        Params:
        key = 押したキーの種類を表すarmos.utils.KeyTypeが格納されています．
    +/
    void keyPressed(KeyType key){}

    /++
        キーボードを離した際に呼ばれるメンバ関数です．
        Params:
        message = キーボードの状態が格納されたメッセージです．
    +/
    void keyReleased(ref KeyReleasedEvent message){
        import std.conv;
        keyReleased(message.key);
        this.ReleaseKey(message.key);
    }
    
    /++
        キーボードを離した際に呼ばれるメンバ関数です．
        Params: 
        key = 離したキーの種類を表すarmos.utils.KeyTypeが格納されています．
    +/
    void keyReleased(KeyType key){}
    
    ///
    void unicodeInputted(ref UnicodeInputtedEvent message){
        unicodeInputted(message.key);
    }
    
    ///
    void unicodeInputted(uint key){}

    /++
        マウス位置を表すプロパティです．
    +/
    int mouseX, mouseY;

    /++
        マウスが動いた際に呼ばれるメンバ関数です．
        Params:
        message = マウスの状態が格納されたメッセージです．
    +/
    void mouseMoved(ref MouseMovedEvent message){
        mouseMoved(message.x, message.y, message.button );
        mouseMoved(Vector2f(message.x, message.y), message.button);
        mouseMoved(Vector2i(message.x, message.y), message.button);
        mouseX = message.x;
        mouseY = message.y;
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
    void mouseMoved(Vector2f position, int button){}

    /++
        マウスが動いた際に呼ばれるメンバ関数です．
        Params:
        position = マウスの座標を表します．
    +/
    void mouseMoved(Vector2i position, int button){}

    /++
        マウスがドラッグされた際に呼ばれるメンバ関数です．
        Deprecated: 現在動作しません．
    +/
    void mouseDragged(ref MouseDraggedEvent message){
        mouseDragged(message.x, message.y, message.button );
        mouseDragged(message.firstX, message.firstY, message.x, message.y, message.button );
        mouseDragged(Vector2f(message.x, message.y), message.button);
        mouseDragged(Vector2f(message.firstX, message.firstY), Vector2f(message.x, message.y), message.button);
        mouseDragged(Vector2i(message.x, message.y), message.button);
        mouseDragged(Vector2i(message.firstX, message.firstY), Vector2f(message.x, message.y), message.button);
    }

    /++
        マウスがドラッグされた際に呼ばれるメンバ関数です．
        Deprecated: 現在動作しません．
    +/
    void mouseDragged(int currentX, int currentY, int button){}
    void mouseDragged(int firstX, int firstY, int currentX, int currentY, int button){}

    /++
        マウスがドラッグされた際に呼ばれるメンバ関数です．
        Deprecated: 現在動作しません．
    +/
    void mouseDragged(Vector2f currentPosition, int button){}
    void mouseDragged(Vector2f firstPosition, Vector2f currentPosition, int button){}

    /++
        マウスがドラッグされた際に呼ばれるメンバ関数です．
        Deprecated: 現在動作しません．
    +/
    void mouseDragged(Vector2i currentPosition, int button){}
    void mouseDragged(Vector2i firstPosition, Vector2i currentPosition, int button){}


    /++
        マウスのボタンが離れた際に呼ばれるメンバ関数です．
        Params:
        message = マウスの状態が格納されたメッセージです．
    +/
    void mouseReleased(ref MouseReleasedEvent message){
        mouseReleased(message.x, message.y, message.button );
        mouseReleased(Vector2f(message.x, message.y), message.button);
        mouseReleased(Vector2i(message.x, message.y), message.button);
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
    void mouseReleased(Vector2f position, int button){}

    /++
        マウスのボタンが離れた際に呼ばれるメンバ関数です．
        Params:
        position = マウスの座標を表します．
        button = 離れたマウスのボタンを表します．
    +/
    void mouseReleased(Vector2i position, int button){}

    /++
        マウスのボタンが押された際に呼ばれるメンバ関数です．
        Params:
        message = マウスの状態が格納されたメッセージです．
    +/
    void mousePressed(ref MousePressedEvent message){
        mousePressed(message.x, message.y, message.button );
        mousePressed(Vector2f(message.x, message.y), message.button);
        mousePressed(Vector2i(message.x, message.y), message.button);
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
    void mousePressed(Vector2f position, int button){}

    /++
        マウスのボタンが押された際に呼ばれるメンバ関数です．
        Params:
        position = マウスの座標を表します．
        button = 押されたマウスのボタンを表します．
    +/
    void mousePressed(Vector2i position, int button){}
    
    ///
    bool hasPressedKey(in KeyType key)const{
        return !_hasHeldKeysPrevious[key] && _hasHeldKeysCurrent[key];
    }
    
    ///
    bool hasHeldKey(in KeyType key)const{
        return _hasHeldKeysCurrent[key];
    }
    
    ///
    bool hasReleasedKey(in KeyType key)const{
        return _hasHeldKeysPrevious[key] && !_hasHeldKeysCurrent[key];
    }

    final void exitApp(){
        _shouldClose = true;
    }

    final bool shouldClose(){
        return _shouldClose;
    }

    
    private{
        bool[KeyType] _hasHeldKeysCurrent;
        bool[KeyType] _hasHeldKeysPrevious;
        bool _shouldClose = false;
    }
}

void initHeldKeys(BaseApp app){
    import std.traits:EnumMembers;
    foreach (elem; [EnumMembers!KeyType]) {
        app._hasHeldKeysCurrent[elem]  = false;
        app._hasHeldKeysPrevious[elem] = false;
    }
}

package void PressKey(BaseApp app, KeyType keyType){
    app._hasHeldKeysCurrent[keyType] = true;
}

package void ReleaseKey(BaseApp app, KeyType keyType){
    app._hasHeldKeysCurrent[keyType] = false;
}

package BaseApp updateKeys(BaseApp app){
    import std.traits:EnumMembers;
    foreach (elem; [EnumMembers!KeyType]) {
        app._hasHeldKeysPrevious[elem] = app._hasHeldKeysCurrent[elem];
    }
    return app;
}

unittest{
    auto app = new BaseApp;
    app.initHeldKeys;
    
    assert(!app.hasHeldKey(KeyType.A));
    assert(!app.hasPressedKey(KeyType.A));
    assert(!app.hasReleasedKey(KeyType.A));
    
    app.updateKeys
       .PressKey(KeyType.A);
    
    assert(app.hasHeldKey(KeyType.A));
    assert(app.hasPressedKey(KeyType.A));
    assert(!app.hasReleasedKey(KeyType.A));
    
    app.updateKeys;
    
    assert(app.hasHeldKey(KeyType.A));
    assert(!app.hasPressedKey(KeyType.A));
    assert(!app.hasReleasedKey(KeyType.A));
    
    app.updateKeys
       .ReleaseKey(KeyType.A);
    
    assert(!app.hasHeldKey(KeyType.A));
    assert(!app.hasPressedKey(KeyType.A));
    assert(app.hasReleasedKey(KeyType.A));
}
