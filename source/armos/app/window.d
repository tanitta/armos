module armos.app.window;

import armos.events;
import armos.math;
import armos.app;

/++
armosで用いるWindowsの雛形となるinterfaceです．新たにWindowを実装する際はこのinterfaceを継承することでrunnerから実行できます．
+/
interface Window{
    public{
        enum bool hasRenderer = false;
        /++
            Windowsが実行するイベントを表すプロパティです．
        +/
        // CoreEvents events();

        /++
            サイズのプロパティです
        +/
        void size(Vector2i size);

        /++
            サイズのプロパティです．
        +/
        Vector2i size();

        /++
            サイズのプロパティです．
        +/
        Vector2i frameBufferSize();

        /++
            イベントが発生している場合，登録されたイベントを実行します
        +/
        void pollEvents();

        /++
            Windowを更新します．
        +/
        void update();

        /++
            Windowを閉じます．
        +/
        void close();

        /++
            Windowがフレームの最後に閉じる場合trueになります．
        +/
        bool shouldClose();

        /++
            Windowのアスペクト比を表します
        +/
        float aspect();

        /++
            Windowのタイトル文字列のプロパティです．
        +/
        string name();

        /++
            Windowのタイトル文字列のプロパティです．
        +/
        void name(in string str);
        
        ///
        // void initEvents(BaseApp, CoreEvents);
        void select();

        /// VerticalSync
        void verticalSync(in bool);
    }//public
}

mixin template BaseWindow(){
    public{
        /++
        +/
        bool shouldClose(){return _shouldClose;}

        /++
        +/
        string name(){return _name;}

        /++
        +/
        void name(in string str){_name = str;}

        /++
        +/
        // CoreEvents events(){
        //     assert(_coreEvents);
        //     return _coreEvents;
        // }

        /++
        +/
        float aspect(){
            if(size[1]==0){
                return 0;
            }else{
                return cast(float)size[0]/cast(float)size[1];
            }

        }
        
    }//public

    protected{
        bool _shouldClose = false;
        string _name = "";
        Vector2f _windowSize;
        
    }//protected
}

/++
    現在のWindowを返す関数です．
+/
Window currentWindow(){
    return mainLoop.window;
}

/++
    現在のWindowの大きさを変更する関数です.
+/
void windowSize(Vector2i size){
    currentWindow.size(size);
}

/++
    現在のWindowの大きさを返す関数です．
+/
Vector2i windowSize(){
    return currentWindow.size;
}

/++
    現在のWindowのアスペクト比を返す関数です．
+/
float windowAspect(){
    return currentWindow.aspect;
}

/++
+/
void windowTitle(in string str){
    currentWindow.name = str;
}

/++
+/
string windowTitle(){
    return currentWindow.name;
}

///
void verticalSync(in bool f){
    currentWindow.verticalSync = f;
}
