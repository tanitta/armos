module armos.app.glfwwindow;

import armos.app;
import armos.events;
import derelict.opengl3.gl;
import armos.app.window;
import armos.math;
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
            Windowのframw bufferのサイズを返します．
        +/
        Vector2i frameBufferSize(){
            auto vec = Vector2i();
            glfwGetFramebufferSize(_window, &vec[0], &vec[1]);
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

        /// VerticalSync
        void verticalSync(in bool f){
            glfwSwapInterval(f);
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
            currentEvents.notifyWindowResize(cast(int)width, cast(int)height);
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
            addListener(events.windowResize, app, &app.windowResized);
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
