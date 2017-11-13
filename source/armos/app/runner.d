module armos.app.runner;

import std.algorithm;
import std.array;

import armos.app;
import armos.utils;
import armos.events;
import armos.graphics;
import armos.app.environment;


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
        Runner register(Environment env){
            env.window.initEvents(env.application);
            _envCollection.add(env);
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
            return _currentEnvironment.renderer;
        }
        
        ///
        Window currentWindow()
        out(window){
            assert(window);
        }body{
            return _currentEnvironment.window;
        }

        CoreObservables currentObservables(){
            return currentWindow.observables;
        }

        ///
        Runner loop(){
            foreach (winAndBundle; _envCollection.byPair) {
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
                isLoop = _envCollection.keys.length > 0;
            }

            foreach (winAndBundle; _envCollection.byPair) {
                auto window = winAndBundle[0];
                auto app    = winAndBundle[1].application;
                select(window);
            }
            return this;
        }

        void select(Window window){
            window.select;
            _currentEnvironment = _envCollection[window];
        }
    }//public

    private{
        Environment[Window] _envCollection;
        Environment _currentEnvironment;

        FpsCounter _fpsCounter;



        void loopOnce(){
            foreach (winAndBundle; _envCollection.byPair) {
                auto window = winAndBundle[0];
                auto app    = winAndBundle[1].application;
                select(window);
                window.update();
                window.draw();
            }

            import std.stdio;
            _envCollection.keys.each!(w => w.pollEvents());
            
            Window[] shouldRemoves;
            foreach (winAndBundle; _envCollection.byPair) {
                auto window = winAndBundle[0];
                auto app    = winAndBundle[1].application;

                if(window.shouldClose||app.shouldClose){
                    window.close;
                    shouldRemoves ~= window;
                }
            }
            shouldRemoves.each!(w => _envCollection.remove(w));
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
void run(Env = GLFWEnvironment)(Application app, WindowConfig config = null){
    if(!config){
        config = new WindowConfig();
        with(config){
            glVersion = SemVer(3, 3, 0);
            width = 640;
            height = 480;
        }
    }
    import armos.graphics.defaultrenderer:DefaultRenderer;
    import armos.graphics.embeddedrenderer:EmbedddedRenderer;
    Renderer r = (new DefaultRenderer).renderer(new EmbedddedRenderer);
    Environment env = (new Env)
                     .application(app)
                     .windowConfig(config)
                     .renderer(r)
                     .build;
    mainLoop.register(env)
            .loop;
}

void run(Environment env){
    mainLoop.register(env)
            .loop;
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

Context currentContext()
out(context){
    assert(context);
}body{
    return mainLoop._currentEnvironment.context;
}

Renderer currentRenderer()
out(renderer){
    assert(renderer);
}body{
    return mainLoop._currentEnvironment.renderer;
}
