module armos.app.runner;
import armos.app;
import armos.utils;
import armos.events;
import armos.graphics;
class Loop {
	private bool isLoop = true;
	private armos.utils.FpsCounter fpscounter;
	armos.app.basewindow.BaseGLWindow window;
	armos.graphics.Renderer renderer;
	armos.app.BaseApp* application;
	
	this(){
		fpscounter = new armos.utils.FpsCounter;
	}
	
	
	void createWindow(ref armos.app.BaseApp app){
		window = new armos.app.basewindow.BaseGLWindow(app);
		renderer = new armos.graphics.Renderer;
		application = &app;
		assert(window);
		renderer.setup();
	};
	
	void run(ref armos.app.BaseApp app){
		createWindow(app);
		
	};
	
	void loop(){
		window.events().notifySetup();
		while(isLoop){
			loopOnce();
			fpscounter.adjust();
			fpscounter.newFrame();
			isLoop = !window.shouldClose;
		}
		
		window.close();
	}
	
	void loopOnce(){
		window.events().notifyUpdate();
		renderer.startRender();
		window.events().notifyDraw();
		renderer.finishRender();
		window.update();
		window.pollEvents();
	}
	
	double fpsUseRate(){
		return fpscounter.fpsUseRate;
	}
	void targetFps(double fps){
		fpscounter.targetFps = fps;
	}
	// keyPressed(){
	// 	ESC
	// }
}

// class Runner{
// 	this(App)(App app){
// 		auto loop = new Loop;
// 		loop.run(app);//addEventListener
// 		loop.loop();
// 	}
// }
class Hoge{}
const auto hoge = new Hoge;
private Loop mainLoop_;
void run(armos.app.BaseApp app){
		mainLoop_ = new Loop;
		mainLoop.run(app);//addEventListener
		mainLoop.loop();
};

Loop* mainLoop(){
	return &mainLoop_;
}


double fpsUseRate(){
	return mainLoop.fpsUseRate;
}

void targetFps(double fps){
	mainLoop.targetFps(fps);
}


