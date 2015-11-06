module armos.app.runner;
import armos.app.basewindow;
import armos.app.baseapp;
import armos.utils;
import armos.events;
class Loop {
	private bool isLoop = true;
	private armos.utils.FpsCounter fpscounter;
	armos.app.basewindow.BaseGLWindow window;
	
	this(){
		fpscounter = new armos.utils.FpsCounter;
	}
	
	
	void createWindow(ref armos.app.BaseApp app){
		window = new armos.app.basewindow.BaseGLWindow(app);
		assert(window);
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
		window.events().notifyDraw();
		window.pollEvents();
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

void run(armos.app.BaseApp app){
		auto loop = new Loop;
		loop.run(app);//addEventListener
		loop.loop();
};
