module armos.app.runner;
import armos.app;
import armos.utils;
import armos.events;
import armos.graphics;

class Loop {
	private bool isLoop = true;
	private armos.utils.FpsCounter fpscounter;
	armos.app.basewindow.Window window;
	armos.graphics.Renderer renderer;
	armos.app.BaseApp* application;

	this(){
		fpscounter = new armos.utils.FpsCounter;
	}

	void createWindow(WindowType)(ref armos.app.BaseApp app){
		window = new WindowType(app);
		renderer = new armos.graphics.Renderer;
		application = &app;
		assert(window);
		renderer.setup();
	};

	void run(WindowType)(ref armos.app.BaseApp app){
		createWindow!(WindowType)(app);
	};

	void loop(){
		window.events.notifySetup();
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
		window.pollEvents();
		window.update();
	}

	double fpsUseRate(){
		return fpscounter.fpsUseRate;
	}
	void targetFps(double fps){
		fpscounter.targetFps = fps;
	}
}

Loop mainLoop() @property
{
	static __gshared Loop instance;
	import std.concurrency : initOnce;
	return initOnce!instance(new Loop);
}

void run(WindowType)(armos.app.BaseApp app){
	mainLoop.run!(WindowType)(app);
	mainLoop.loop();
}

void run(armos.app.BaseApp app){
	run!(armos.app.GLFWWindow)(app);
};

double fpsUseRate(){
	return mainLoop.fpsUseRate;
}

void targetFps(double fps){
	mainLoop.targetFps(fps);
}
