module armos.app.runner;
import armos.app;
import armos.utils;
import armos.events;
import armos.graphics;

import std.algorithm;
/++
armosのアプリケーションの更新を行うclassです．
+/


class Runner {
    public{
        /++
        +/
        this(){
            _fpsCounter = new FpsCounter;
            _events = new CoreEvents;
            _windowCollection = new WindowCollection;
        }
        
        /++
            イベントループに入ります．
            Params:
            app = 更新されるアプリケーションです．
        +/
        void register(WindowType)(BaseApp app, Window window){
            _application = app;
            addListener(events.setup, app, &app.setup);
            addListener(events.update, app, &app.update);
            addListener(events.draw, app, &app.draw);
            addListener(events.exit, app, &app.exit);
            
            {
                window.initEvents(_application, _events);
                _windowCollection.add("master", window);
                _windowCollection.select("master");
            }

            // {
            //     Window window = new WindowType(app, _events, config);
            //     _windowCollection.add("sub", window);
            //     _windowCollection.select("master");
            // }

            static if(WindowType.hasRenderer){
                _renderer = new Renderer;
            }

            if(_renderer){
                _renderer.setup();
            }

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
        Renderer renderer(){return _renderer;}
        
        ///
        CoreEvents events(){return _events;};

        ///
        Window currentWindow()out(window){
            assert(window);
        }body{
            return _windowCollection.current;
        }
    }//public

    private{
        BaseApp    _application;
        CoreEvents _events;
        Renderer   _renderer;
        WindowCollection     _windowCollection;

        bool _isLoop = true;
        FpsCounter _fpsCounter;



        void loop(){
            _application.initHeldKeys;
            
            _events.notifySetup();
            while(_isLoop){
                loopOnce();
                _fpsCounter.adjust();
                _fpsCounter.newFrame();
                import std.functional;
                _isLoop = _windowCollection.windows.map!(w => !w.shouldClose).fold!("a||b")(false)&&!_application.shouldClose;
            }
            _events.notifyExit();
            _windowCollection.windows.each!(w => w.close());
        }

        void loopOnce(){
            _events.notifyUpdate();
            if(_renderer){
                _renderer.startRender();
            }
            _events.notifyDraw();
            if(_renderer){
                _renderer.finishRender();
            }
            _application.updateKeys;
            _windowCollection.windows.each!(w => w.pollEvents());
            _windowCollection.windows.each!(w => w.update());
        }

    }//private
}
private Runner mainLoop_;
Runner mainLoop() @property
{
    return mainLoop_;
    // static __gshared Runner instance;
    // import std.concurrency : initOnce;
    // return initOnce!instance(new Runner);
}

/++
    armosのアプリケーションを実行します．
    Params:
    WindowType = 立ち上げるWindowの型を指定します．省略可能です．
    app = 立ち上げるアプリケーションを指定します．
+/
void run(WindowType = GLFWWindow)(BaseApp app, WindowConfig config = null){
    mainLoop_ = new Runner;
    if(!config){
        config = new WindowConfig();
        with(config){
            glVersion = SemVer(3, 3, 0);
            width = 640;
            height = 480;
        }
    }
    Window window = new WindowType(config);
    mainLoop.register!(WindowType)(app, window);
    mainLoop.loop;
}

// void run(WindowType = GLFWWindow)(BaseApp app, Window window){
//     mainLoop_ = new Runner;
//     if(!config){
//         config = new WindowConfig();
//         with(config){
//             glVersion = SemVer(3, 3, 0);
//             width = 640;
//             height = 480;
//         }
//     }
//     mainLoop.run!(WindowType)(app, config);
// }

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

CoreEvents currentEvents(){
    return mainLoop.events;
}

double currentFps(){
    return mainLoop.currentFps;
}
