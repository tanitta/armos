module armos.app.basewindow;

import derelict.opengl3.gl;
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
    GLFWを利用したWindowです．armosではデフォルトでこのclassを元にWindowが生成されます．
+/
class GLFWWindow : Window{
    import derelict.glfw3.glfw3;
    mixin BaseWindow;

    public{
        enum bool hasRenderer = true;
        /++
            Params:
            apprication = Windowとひも付けされるアプリケーションです．
        +/
        this(BaseApp apprication, CoreEvents events, WindowConfig config){
            DerelictGL.load();
            DerelictGLFW3.load();

            if( !glfwInit() ){}

            glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, config.glVersionMajor);
            glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, config.glVersionMinor);
            
            import armos.utils.semver;
            if(config.glVersion >= SemVer("3.2.0")){
                glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
                glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
            }

            _window = glfwCreateWindow(config.width, config.height, cast(char*)_name, null, null);
            if(!_window){close;}

            glfwMakeContextCurrent(_window);

            if(config.glVersion >= SemVer("3.2.0")){
                DerelictGL3.reload();
            }else{
                DerelictGL.reload();
            }

            initEvents(apprication, events);
            initGLFWEvents();

            glfwSwapInterval(0);
            glfwSwapBuffers(_window);
            
            writeVersion;
        }

        void size(Vector2i size){
            glfwSetWindowSize(_window, size[0], size[1]);
        }

        /++
            Windowのサイズを返します．
        +/
        Vector2i size(){
            auto vec = Vector2i();
            glfwGetWindowSize(_window, &vec[0], &vec[1]);
            return vec;
        }

        /++
            イベントが発生している場合，登録されたイベントを実行します
        +/
        void pollEvents(){
            glfwPollEvents();
        }

        /++
            Windowを更新します．
        +/
        void update(){
            // glFlush();
            // glFinish();
            glfwSwapBuffers(_window);
            _shouldClose = cast(bool)glfwWindowShouldClose(_window);
        }

        /++
            Windowを閉じます．
        +/
        void close(){
            _shouldClose = true;
            glfwTerminate();
        }

        void name(in string str){
            import std.string;
            _name = str;
            glfwSetWindowTitle(_window, str.toStringz);
        }
        
        void select(){
            glfwMakeContextCurrent(_window);
        };
    }//public

    private{
        GLFWwindow* _window;

        static extern(C) void keyCallbackFunction(GLFWwindow* window, int key, int scancode, int action, int mods){
            import std.conv;
            import armos.utils.keytype;
            if(action == GLFW_PRESS){
                currentEvents.notifyKeyPressed(key.to!KeyType);
            }else if(action == GLFW_RELEASE){
                currentEvents.notifyKeyReleased(key.to!KeyType);
            }
        }
        
        static extern(C) void charCallbackFunction(GLFWwindow* window, uint key){
            currentEvents.notifyUnicodeInput(key);
            // if(action == GLFW_PRESS){
            //     currentEvents.notifyKeyPressed(key);
            // }else if(action == GLFW_RELEASE){
            //     currentEvents.notifyKeyReleased(key);
            // }
        }

        static extern(C) void cursorPositionFunction(GLFWwindow* window, double xpos, double ypos){
            currentEvents.notifyMouseMoved(cast(int)xpos, cast(int)ypos, 0);
        }

        static extern(C ) void mouseButtonFunction(GLFWwindow* window, int button, int action, int mods){
            double xpos, ypos;
            glfwGetCursorPos(window, &xpos, &ypos);

            if(action == GLFW_PRESS){
                currentEvents.notifyMousePressed(cast(int)xpos, cast(int)ypos, button);
            }else if(action == GLFW_RELEASE){
                currentEvents.notifyMouseReleased(cast(int)xpos, cast(int)ypos, button);
            }
        }

        static extern(C ) void resizeWindowFunction(GLFWwindow* window, int width, int height){
            import armos.graphics;
            currentRenderer.resize();
        }
        
        void writeVersion(){
            import std.stdio, std.conv;
            writefln("Vendor:   %s",   to!string(glGetString(GL_VENDOR)));
            writefln("Renderer: %s",   to!string(glGetString(GL_RENDERER)));
            writefln("Version:  %s",   to!string(glGetString(GL_VERSION)));
            writefln("GLSL:     %s\n", to!string(glGetString(GL_SHADING_LANGUAGE_VERSION)));
        };
        
        void initEvents(BaseApp app, CoreEvents events){
            assert(events);
            addListener(events.keyPressed, app, &app.keyPressed);
            addListener(events.keyReleased, app, &app.keyReleased);
            addListener(events.mouseMoved, app, &app.mouseMoved);
            addListener(events.mouseDragged, app, &app.mouseDragged);
            addListener(events.mouseReleased, app, &app.mouseReleased);
            addListener(events.mousePressed, app, &app.mousePressed);
            addListener(events.unicodeInputted, app, &app.unicodeInputted);
            
            import armos.utils:KeyType;
            addListener(events.keyPressed,  app, delegate(ref KeyPressedEventArg message){app.PressKey(message.key);});
            addListener(events.keyReleased, app, delegate(ref KeyReleasedEventArg message){app.ReleaseKey(message.key);});
        }


        void initGLFWEvents(){
            // glfwSetKeyCallback(window, &keyCallbackFunction);
            glfwSetKeyCallback(_window, cast(GLFWkeyfun)&keyCallbackFunction);
            glfwSetCharCallback(_window, cast(GLFWcharfun)&charCallbackFunction);
            glfwSetCursorPosCallback(_window, cast(GLFWcursorposfun)&cursorPositionFunction);
            glfwSetMouseButtonCallback(_window, cast(GLFWmousebuttonfun)&mouseButtonFunction);
            glfwSetWindowSizeCallback(_window, cast(GLFWwindowsizefun)&resizeWindowFunction);
        }
    }//private
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
