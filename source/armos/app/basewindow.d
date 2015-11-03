module armos.app.basewindow;
import derelict.sdl2.sdl;
import derelict.opengl3.gl3;
import std.stdio;
template BaseWindow() {
	private SDL_Window* window;
	private string name;
	private armos.app.baseapp.BaseApp app;
	
	void setup(){
		app.setup();
	};
	
	void update(){app.update();};
	
	void draw(){app.draw();};
	
	void exit(){
		closeWindow();
	};
	
	void closeWindow(){
		SDL_DestroyWindow(window);
		SDL_Quit();
	};	
	
	// getWindowPosition();
	// setWindowPosition();
	// getScreenSize();
	// getWidth()
	// getHeight()
	// void setWindowTitle(string title){}
}

class WindowSettings{
	int width;
	int height;
	// position
	bool isPositionSet;
}

class BaseGLWindow {
	mixin BaseWindow;
	SDL_GLContext glcontext;
	
	this(App)(App apprication){
		DerelictSDL2.load();
		DerelictGL3.load();
		SDL_Init(SDL_INIT_VIDEO);
		app = apprication;
		window = SDL_CreateWindow(
				cast(char*)name,
				SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
				800, 600,
				SDL_WINDOW_OPENGL|SDL_WINDOW_RESIZABLE
				);
		glcontext = SDL_GL_CreateContext(window);
		glClearColor(32.0/255.0, 32.0/255.0, 32.0/255.0, 1);
		glClear(GL_COLOR_BUFFER_BIT);
		SDL_GL_SwapWindow(window);
	}
	void exit(){
		SDL_GL_DeleteContext(glcontext); 
		closeWindow();
	}
}
