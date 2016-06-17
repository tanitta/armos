module armos.app.runner;
static import armos.app;
static import armos.utils;
static import armos.events;
static import armos.graphics;
/++
armosのアプリケーションの更新を行うclassです．
+/
class Loop {
    public{
        armos.app.basewindow.Window window;
        armos.graphics.Renderer renderer;
        armos.app.BaseApp* application;

        /++
        +/
        this(){
            fpscounter = new armos.utils.FpsCounter;
        }

        /++
            イベントループに入ります．
            Params:
            app = 更新されるアプリケーションです．
        +/
        void run(WindowType)(ref armos.app.BaseApp app){
            createWindow!(WindowType)(app);
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
        armos.utils.FpsCounter fpscounter;

        void createWindow(WindowType)(ref armos.app.BaseApp app){
            window = new WindowType(app);
            renderer = new armos.graphics.Renderer;
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
void run(WindowType = armos.app.GLFWWindow)(armos.app.BaseApp app){
    mainLoop_ = new Loop;
    mainLoop.run!(WindowType)(app);
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
