module armos.app.runner;
import armos.app.basewindow;
import armos.app.baseapp;
import std.stdio;
class Loop {
	private bool isLoop = true;
	armos.app.basewindow.BaseGLWindow window;
	
	void createWindow(armos.app.BaseApp app){
		window = new armos.app.basewindow.BaseGLWindow(app);
	};
	
	void run(armos.app.BaseApp app){
		createWindow(app);
		//EventListeners
		window.setup();
	};
	
	void loop(){
		if(isLoop){
			loopOnce();
		}
		window.exit();
	}
	
	void loopOnce(){
		window.update();
		window.draw();
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
