module armos.app.runner;

import armos.app;
import armos.utils;
import armos.events;
import armos.graphics;

import std.algorithm;
import std.array;

/++
armosのアプリケーションの更新を行うclassです．
+/


class Runner {
    public{
        /++
        +/
        this(){
            _fpsCounter = new FpsCounter;
        }
        
        /++
            イベントループに入ります．
            Params:
            app = 更新されるアプリケーションです．
        +/
        Runner register(Application app, Window window){
            window.initEvents(app);
            import armos.graphics.scene;
            _appsCollection.add(window, app, new Scene);
            return this;
        };

        /++
            現在のFPS(Frame Per Second)の使用率を返します．
        +/
        double fpsUseRate(){
            return _fpsCounter.fpsUseRate;
        }

        /++
            FPS(Frame Per Second)を指定します．
        +/
        void targetFps(in double fps){
            _fpsCounter.targetFps = fps;
        }
        
        ///
        double targetFps()const{
            return _fpsCounter.targetFps;
        }
        
        ///
        double currentFps()const{
            return _fpsCounter.currentFps;
        }
        
        ///
        Renderer renderer()out(renderer){
            assert(renderer);
        }body{
            return currentWindow.renderer;
        }
        
        ///
        Window currentWindow()
        out(window){
            assert(window);
        }body{
            return _currentBundle.window;
        }

        CoreObservables currentObservables(){
            return currentWindow.observables;
        }

        ///
        Runner loop(){
            foreach (winAndBundle; _appsCollection.byPair) {
                auto window = winAndBundle[0];
                auto app    = winAndBundle[1].application;
                select(window);
                window.setup;
            }

            bool isLoop = true;
            while(isLoop){
                loopOnce();
                _fpsCounter.adjust();
                _fpsCounter.newFrame();
                import std.functional;
                isLoop = _appsCollection.keys.length > 0;
            }

            foreach (winAndBundle; _appsCollection.byPair) {
                auto window = winAndBundle[0];
                auto app    = winAndBundle[1].application;
                select(window);
            }
            return this;
        }

        void select(Window window){
            window.select;
            _currentBundle = _appsCollection[window];
        }
    }//public

    private{
        AppCollection _appsCollection;
        ApplicationBundle _currentBundle;

        FpsCounter _fpsCounter;



        void loopOnce(){
            foreach (winAndBundle; _appsCollection.byPair) {
                auto window = winAndBundle[0];
                auto app    = winAndBundle[1].application;
                select(window);
                window.update();
                window.draw();
            }

            import std.stdio;
            _appsCollection.keys.each!(w => w.pollEvents());
            
            Window[] shouldRemoves;
            foreach (winAndBundle; _appsCollection.byPair) {
                auto window = winAndBundle[0];
                auto app    = winAndBundle[1].application;

                if(window.shouldClose||app.shouldClose){
                    window.close;
                    shouldRemoves ~= window;
                }
            }
            shouldRemoves.each!(w => _appsCollection.remove(w));
        }

    }//private
}

Runner mainLoop() @property {
    static __gshared Runner instance;
    import std.concurrency : initOnce;
    return initOnce!instance(new Runner);
}

/++
    armosのアプリケーションを実行します．
    Params:
    WindowType = 立ち上げるWindowの型を指定します．省略可能です．
    app = 立ち上げるアプリケーションを指定します．
+/
void run(WindowType = GLFWWindow)(Application app, WindowConfig config = null){
    // mainLoop_ = new Runner;
    if(!config){
        config = new WindowConfig();
        with(config){
            glVersion = SemVer(3, 3, 0);
            width = 640;
            height = 480;
        }
    }

    Window window = new WindowType(config);
    mainLoop.register(app, window);
    mainLoop.loop;
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
void targetFps(in double fps){
    mainLoop.targetFps(fps);
}

double targetFps(){
    return mainLoop.targetFps;
}

CoreObservables currentObservables(){
    return mainLoop.currentObservables;
}

double currentFps(){
    return mainLoop.currentFps;
}

ulong currentFrames(){
    return mainLoop._fpsCounter.currentFrames();
}

Scene currentScene()
out(scene){
    assert(scene);
}body{
    return mainLoop._currentBundle.scene;
}

