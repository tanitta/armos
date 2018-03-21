module armos.app.glfwwindow;

import armos.app;
import armos.events;
import derelict.opengl3.gl;
import armos.app.window;
import armos.math;
import armos.graphics.gl.fbo:Fbo;
/++
    GLFWを利用したWindowです．armosではデフォルトでこのclassを元にWindowが生成されます．
+/
class GLFWWindow : Window{
    import derelict.glfw3.glfw3;
    import std.range:put;
    mixin BaseWindow;

    public{
        enum bool hasRenderer = true;
        /++
            Params:
            apprication = Windowとひも付けされるアプリケーションです．
        +/
        this(WindowConfig config = new WindowConfig, GLFWwindow* sharedContext = null){
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

            _window = glfwCreateWindow(config.width, config.height, cast(char*)_name, null, sharedContext);
            if(!_window){close;}

            GLFWWindow.glfwWindowToArmosGLFWWindow[_window] = this;

            glfwMakeContextCurrent(_window);

            if(config.glVersion >= SemVer("3.2.0")){
                DerelictGL3.reload();
            }else{
                DerelictGL.reload();
            }


            initGLFWEvents();
            _subjects = new CoreSubjects;


            glfwSwapInterval(0);
            glfwSwapBuffers(_window);
            
            writeVersion;
        }

        void allocateGlObjects(){
        }

        ~this(){
            GLFWWindow.glfwWindowToArmosGLFWWindow.remove(_window);
        }

        void size(Vector2i size){
            glfwSetWindowSize(_window, size[0], size[1]);
        }

        /++
            Windowのサイズを返します．
        +/
        Vector2i size()const{
            auto vec = Vector2i();
            glfwGetWindowSize(cast(GLFWwindow*)(_window), &vec[0], &vec[1]);
            return vec;
        }

        /++
            Windowのframw bufferのサイズを返します．
        +/
        Vector2i frameBufferSize()const{
            auto vec = Vector2i();
            glfwGetFramebufferSize(cast(GLFWwindow*)(_window), &vec[0], &vec[1]);
            return vec;
        }

        /++
            イベントが発生している場合，登録されたイベントを実行します
        +/
        void pollEvents(){
            glfwPollEvents();
        }

        void setup(){
            import rx;
            _screen = new Fbo(frameBufferSize);
            _subjects.windowResize.doSubscribe!((event){
                _screen.resize(this.frameBufferSize);
                _screenDrawer.resize(this.frameBufferSize.x, this.frameBufferSize.y);
            });

            _screenDrawer = new ScreenDrawer();
            put(_subjects.setup, SetupEvent());
            _screenDrawer.setup(_screen, frameBufferSize.x, frameBufferSize.y);
        }

        /++
            Windowを更新します．
        +/
        void update(){
            put(_subjects.update, UpdateEvent());
            _shouldClose = cast(bool)glfwWindowShouldClose(_window);
        }

        void draw(){
            put(_subjects.draw, DrawEvent());
            _screenDrawer.render();
            glfwSwapBuffers(_window);
        }

        /++
            Windowを閉じます．
        +/
        void close(){
            put(_subjects.exit, ExitEvent());
            _shouldClose = true;
            glfwDestroyWindow(_window);
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

        ///
        float pixelScreenCoordScale()const{
            return frameBufferSize.x / size.x;
        };

        ///
        Fbo screen(){
            return _screen;
        };

        void initEvents(Application app){
            assert(_subjects);
            import rx;
            _subjects.setup.doSubscribe!(event => app.setup(event));
            _subjects.update.doSubscribe!(event => app.update(event));
            _subjects.draw.doSubscribe!(event => app.draw(event));
            _subjects.exit.doSubscribe!(event => app.exit(event));
            _subjects.windowResize.doSubscribe!(event => app.windowResized(event));
            _subjects.keyPressed.doSubscribe!(event => app.keyPressed(event));
            _subjects.keyReleased.doSubscribe!(event => app.keyReleased(event));
            _subjects.unicodeInputted.doSubscribe!(event => app.unicodeInputted(event));
            _subjects.mouseMoved.doSubscribe!(event => app.mouseMoved(event));
            _subjects.mousePressed.doSubscribe!(event => app.mousePressed(event));
            _subjects.mouseDragged.doSubscribe!(event => app.mouseDragged(event));
            _subjects.mouseReleased.doSubscribe!(event => app.mouseReleased(event));
            _subjects.mouseScrolled.doSubscribe!(event => app.mouseScrolled(event));
        }

        CoreObservables observables(){
            import std.conv:to;
            return _subjects.to!CoreObservables;
        }

        GLFWwindow* context(){
            return _window;
        }
    }//public

    private{
        GLFWwindow* _window;
        CoreSubjects _subjects;
        Fbo _screen;
        ScreenDrawer _screenDrawer;

        static extern(C) void keyCallbackFunction(GLFWwindow* window, int key, int scancode, int action, int mods){
            auto currentGLFWWindow = GLFWWindow.glfwWindowToArmosGLFWWindow[window];
            mainLoop.select(currentGLFWWindow);
            import std.conv;
            import armos.utils.keytype;
            if(action == GLFW_PRESS){
                put(currentGLFWWindow._subjects.keyPressed, KeyPressedEvent(key.to!KeyType));
            }else if(action == GLFW_RELEASE){
                put(currentGLFWWindow._subjects.keyReleased, KeyReleasedEvent(key.to!KeyType));
            }
        }
        
        static extern(C) void charCallbackFunction(GLFWwindow* window, uint key){
            auto currentGLFWWindow = GLFWWindow.glfwWindowToArmosGLFWWindow[window];
            mainLoop.select(currentGLFWWindow);
            put(currentGLFWWindow._subjects.unicodeInputted, UnicodeInputtedEvent(key));
        }

        static extern(C) void cursorPositionFunction(GLFWwindow* window, double xpos, double ypos){
            auto currentGLFWWindow = GLFWWindow.glfwWindowToArmosGLFWWindow[window];
            mainLoop.select(currentGLFWWindow);
            put(currentGLFWWindow._subjects.mouseMoved, MouseMovedEvent(cast(int)xpos, cast(int)ypos, 0));
        }

        static extern(C ) void mouseButtonFunction(GLFWwindow* window, int button, int action, int mods){
            auto currentGLFWWindow = GLFWWindow.glfwWindowToArmosGLFWWindow[window];
            mainLoop.select(currentGLFWWindow);

            double xpos, ypos;
            glfwGetCursorPos(window, &xpos, &ypos);

            if(action == GLFW_PRESS){
                put(currentGLFWWindow._subjects.mousePressed, MousePressedEvent(cast(int)xpos, cast(int)ypos, button));
            }else if(action == GLFW_RELEASE){
                put(currentGLFWWindow._subjects.mouseReleased, MouseReleasedEvent(cast(int)xpos, cast(int)ypos, button));
            }
        }

        static extern(C ) void resizeWindowFunction(GLFWwindow* window, int width, int height){
            import armos.graphics;
            auto currentGLFWWindow = GLFWWindow.glfwWindowToArmosGLFWWindow[window];
            mainLoop.select(currentGLFWWindow);
            // if(currentRenderer.target)currentRenderer.target.resize(Vector2i(width, height));
            put(currentGLFWWindow._subjects.windowResize, WindowResizeEvent(cast(int)width, cast(int)height));
        }

        static extern(C ) void mouseScrolledCallback(GLFWwindow* window, double xOffset, double yOffset){
            import armos.graphics;
            auto currentGLFWWindow = GLFWWindow.glfwWindowToArmosGLFWWindow[window];
            mainLoop.select(currentGLFWWindow);
            put(currentGLFWWindow._subjects.mouseScrolled, MouseScrolledEvent(cast(int)xOffset, cast(int)yOffset));
        }
        
        void writeVersion(){
            import std.stdio, std.conv;
            writefln("Vendor:   %s",   to!string(glGetString(GL_VENDOR)));
            writefln("Renderer: %s",   to!string(glGetString(GL_RENDERER)));
            writefln("Version:  %s",   to!string(glGetString(GL_VERSION)));
            writefln("GLSL:     %s\n", to!string(glGetString(GL_SHADING_LANGUAGE_VERSION)));
        };
        


        void initGLFWEvents(){
            // glfwSetKeyCallback(window, &keyCallbackFunction);
            glfwSetKeyCallback(_window, cast(GLFWkeyfun)&keyCallbackFunction);
            glfwSetCharCallback(_window, cast(GLFWcharfun)&charCallbackFunction);
            glfwSetCursorPosCallback(_window, cast(GLFWcursorposfun)&cursorPositionFunction);
            glfwSetMouseButtonCallback(_window, cast(GLFWmousebuttonfun)&mouseButtonFunction);
            glfwSetWindowSizeCallback(_window, cast(GLFWwindowsizefun)&resizeWindowFunction);
            glfwSetScrollCallback(_window, cast(GLFWscrollfun)&mouseScrolledCallback);
        }

        static GLFWWindow[GLFWwindow*] glfwWindowToArmosGLFWWindow;

        void drawScreen(){

        }
    }//private
}

import armos.graphics.renderer:Renderer;
import armos.graphics.standardrenderer;
import armos.graphics.gl.buffer;
private class ScreenDrawer {
    public{
        this(){
            _renderer = new StandardRenderer();

            _position   = new Buffer();
            _texCoord = new Buffer();
            _index    = new Buffer(BufferType.ElementArray);
        }
        ~this(){}

        void resize(in int width, in int height){
            _position.array([
                Vector4f(-1.0, -1.0, 0.0, 1.0f),
                Vector4f(1.0,  -1.0, 0.0, 1.0f),
                Vector4f(1.0,  1.0,  0.0, 1.0f),
                Vector4f(-1.0, 1.0,  0.0, 1.0f),
            ]);
        }

        void setup(Fbo screen, in int width, in int height){
            import std.stdio;
            writeln(width, " ", height);
            _renderer.setup;

            _renderer.texture("tex0", screen.colorTexture);

            _texCoord.array([
                Vector4f(0f, 0f, 0.0, 1.0f),
                Vector4f(1f, 0,  0.0, 1.0f),
                Vector4f(1f, 1f, 0.0, 1.0f),
                Vector4f(0,  1f, 0.0, 1.0f),
            ]);
            _position.array([
                Vector4f(-1.0, -1.0, 0.0, 1.0f),
                Vector4f(1.0,  -1.0, 0.0, 1.0f),
                Vector4f(1.0,  1.0,  0.0, 1.0f),
                Vector4f(-1.0, 1.0,  0.0, 1.0f),
            ]);
            _index.array([
                0, 1, 2,
                2, 3, 0,
            ]);
        };

        void render(){
            _renderer.attribute("position", _position)
                     .attribute("texCoord0", _texCoord)
                     .indices(_index)
                     .diffuse(1f, 1f, 1f, 1f)
                     .render();
        };
    }//public

    private{
        Renderer _renderer;
        Buffer _texCoord;
        Buffer _position;
        Buffer _index;
    }//private
}//class ScreenDrawer

