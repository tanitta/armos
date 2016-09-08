module armos.app.runner;
import armos.app;
import armos.utils;
import armos.events;
import armos.graphics;

/++
armosのアプリケーションの更新を行うclassです．
+/
class Loop {
    public{
        Window window;
        Renderer renderer;
        BaseApp* application;

        /++
        +/
        this(){
            fpscounter = new FpsCounter;
        }

        /++
            イベントループに入ります．
            Params:
            app = 更新されるアプリケーションです．
        +/
        void run(WindowType)(BaseApp app, WindowConfig config){
            createWindow!(WindowType)(app, config);
            loop();
        };

        /++
            現在のFPS(Frame Per Second)の使用率を返します．
        +/
        double fpsUseRate(){
            return fpscounter.fpsUseRate;
        }

        /++
            FPS(Frame Per Second)を指定します．
        +/
        void targetFps(double fps){
            fpscounter.targetFps = fps;
        }
    }//public

    private{
        bool isLoop = true;
        FpsCounter fpscounter;

        void createWindow(WindowType)(BaseApp app, WindowConfig config){
            window = new WindowType(app, config);
            renderer = new Renderer;
            application = &app;
            assert(window);
            renderer.setup();
        };

        void loop(){
            window.events.notifySetup();
            while(isLoop){
                loopOnce();
                fpscounter.adjust();
                fpscounter.newFrame();
                isLoop = !window.shouldClose;
            }
            window.events().notifyExit();
            window.close();
        }

        void loopOnce(){
            window.events().notifyUpdate();
            renderer.startRender();
            window.events().notifyDraw();
            renderer.finishRender();
            window.pollEvents();
            window.update();
        }

    }//private
}
private Loop mainLoop_;
Loop mainLoop() @property
{
    return mainLoop_;
    // static __gshared Loop instance;
    // import std.concurrency : initOnce;
    // return initOnce!instance(new Loop);
}

/++
    armosのアプリケーションを実行します．
    Params:
    WindowType = 立ち上げるWindowの型を指定します．省略可能です．
    app = 立ち上げるアプリケーションを指定します．
+/
void run(WindowType = GLFWWindow)(BaseApp app, WindowConfig config = null){
    mainLoop_ = new Loop;
    if(!config){
        config = new WindowConfig();
        with(config){
            glVersion = SemVer(3, 3, 0);
            width = 640;
            height = 480;
        }
    }
    mainLoop.run!(WindowType)(app, config);
}

/++
    現在のFPS(Frame Per Second)の使用率を返します．
+/
double fpsUseRate(){
    return mainLoop.fpsUseRate;
}

/++
    FPS(Frame Per Second)を指定します．
+/
void targetFps(double fps){
    mainLoop.targetFps(fps);
}
