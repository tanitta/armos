module armos.app.basewindow;

import derelict.opengl3.gl;
import armos.events;
import armos.math;
import armos.app;

interface Window{
	armos.events.CoreEvents events();
	armos.math.Vector2i size();
	void pollEvents();
	void update();
	void close();
	bool shouldClose();
	float aspect();
	string name();
	void name(string str);
}

class WindowSettings{
	int width;
	int height;
	// position
	bool isPositionSet;
}

mixin template BaseWindow(){
	protected bool shouldClose_ = false;
	bool shouldClose(){return shouldClose_;}
	
	protected string name_ = "";
	string name(){return name_;}
	void name(string str){name_ = str;}
	
	private armos.app.baseapp.BaseApp app;
	private armos.events.CoreEvents core_events;
	protected armos.math.Vector2f windowSize_;
	
	void initEvents(armos.app.baseapp.BaseApp app){
		this.app = app;
		core_events = new armos.events.CoreEvents;
		assert(core_events);
		
		armos.events.addListener(core_events.setup, app, &app.setup);
		armos.events.addListener(core_events.update, app, &app.update);
		armos.events.addListener(core_events.draw, app, &app.draw);
		armos.events.addListener(core_events.keyPressed, app, &app.keyPressed);
		armos.events.addListener(core_events.mouseMoved, app, &app.mouseMoved);
		armos.events.addListener(core_events.mouseDragged, app, &app.mouseDragged);
		armos.events.addListener(core_events.mouseReleased, app, &app.mouseReleased);
		armos.events.addListener(core_events.mousePressed, app, &app.mousePressed);
	}
	
	armos.events.CoreEvents events(){
		assert(core_events);
		return core_events;
	}
	
	float aspect(){
		if(size[1]==0){
			return 0;
		}else{
			return cast(float)size[0]/cast(float)size[1];
		}
		
	}
}

class SDLWindow : Window{
	import derelict.sdl2.sdl;
	mixin BaseWindow;
	
	private SDL_Window* window;
	private SDL_GLContext glcontext;
	
	this(ref armos.app.BaseApp apprication){
		DerelictGL.load();
		DerelictSDL2.load();
		
		SDL_Init(SDL_INIT_VIDEO);
		window = SDL_CreateWindow(
			cast(char*)name_,
			SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
			800, 600,
			SDL_WINDOW_OPENGL|SDL_WINDOW_RESIZABLE
		);
		
		SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 4);
		SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 4);
		
		glcontext = SDL_GL_CreateContext(window);
		
		import std.stdio, std.conv;
		writefln("Vendor:   %s",   to!string(glGetString(GL_VENDOR)));
		writefln("Renderer: %s",   to!string(glGetString(GL_RENDERER)));
		writefln("Version:  %s",   to!string(glGetString(GL_VERSION)));
		writefln("GLSL:     %s\n", to!string(glGetString(GL_SHADING_LANGUAGE_VERSION)));
		
		
		DerelictGL.reload();
		
		glClearColor(32.0/255.0, 32.0/255.0, 32.0/255.0, 1);
		glClear(GL_COLOR_BUFFER_BIT);
		
		SDL_GL_SwapWindow(window);
		initEvents(apprication);
		
	}
	
	void pollEvents(){
		SDL_Event event;
		while (SDL_PollEvent(&event))
		{
			switch (event.type)
			{
				case SDL_QUIT:
					shouldClose_ = true;
					break;
					
				case SDL_KEYDOWN:
					events.notifyKeyPressed(event.key.keysym.sym );
					break;
				case SDL_KEYUP:
					events.notifyKeyReleased(event.key.keysym.sym );
					break;
				case SDL_MOUSEMOTION:
					import std.math;
					int button = cast(int)fmax(0, log2( cast(float)event.motion.state*2));
					events.notifyMouseMoved(event.motion.x, event.motion.y, button);
					break;
				case SDL_MOUSEBUTTONDOWN:
					events.notifyMousePressed(event.button.x, event.button.y, event.button.button);
					break;
				case SDL_MOUSEBUTTONUP:
					events.notifyMouseReleased(event.button.x, event.button.y, event.button.button);
					break;
					
				default:
					// events.notify...
					break;
			}
		}
	}
	
	void close(){
		SDL_GL_DeleteContext(glcontext); 
		closeWindow();
	}
	
	private void closeWindow(){
		SDL_DestroyWindow(window);
		SDL_Quit();
	};	
	
	void update(){
		SDL_GL_SwapWindow(window);
	}
	
	armos.math.Vector2i size(){
		int w, h;
		SDL_GetWindowSize(window, &w, &h);
		// windowSize_ = armos.math.Vector2i(w, h);
		// return windowSize_;
		return armos.math.Vector2i(w, h);
	}
}

class GLFWWindow : Window{
	import derelict.glfw3.glfw3;
	mixin BaseWindow;
	
	private GLFWwindow* window;
	
	this(ref armos.app.BaseApp apprication){
		DerelictGL.load();
		DerelictGLFW3.load();
		
		if( !glfwInit() ){}
		window = glfwCreateWindow(640, 480, cast(char*)name_, null, null);
		if(!window){close;}
		
		glfwMakeContextCurrent(window);
		DerelictGL.reload();
		
		initEvents(apprication);
		initGLFWEvents();
		
		glfwSwapInterval(1);
		glfwSwapBuffers(window);
	}
	
	private static extern(C) void keyCallbackFunction(GLFWwindow* window, int key, int scancode, int action, int mods){
		if(action == GLFW_PRESS){
			currentWindow.events.notifyKeyPressed(key);
		}else if(action == GLFW_RELEASE){
			currentWindow.events.notifyKeyReleased(key);
		}
	}
	
	private static extern(C) void cursorPositionFunction(GLFWwindow* window, double xpos, double ypos){
		currentWindow.events.notifyMouseMoved(cast(int)xpos, cast(int)ypos, 0);
	}
	
	private static extern(C ) void mouseButtonFunction(GLFWwindow* window, int button, int action, int mods){
		double xpos, ypos;
		glfwGetCursorPos(window, &xpos, &ypos);
		
		if(action == GLFW_PRESS){
			currentWindow.events.notifyMousePressed(cast(int)xpos, cast(int)ypos, button);
		}else if(action == GLFW_RELEASE){
			currentWindow.events.notifyMouseReleased(cast(int)xpos, cast(int)ypos, button);
		}
	}
	
	private void initGLFWEvents(){
		// glfwSetKeyCallback(window, &keyCallbackFunction);
		glfwSetKeyCallback(window, cast(GLFWkeyfun)&keyCallbackFunction);
		glfwSetCursorPosCallback(window, cast(GLFWcursorposfun)&cursorPositionFunction);
		glfwSetMouseButtonCallback(window, cast(GLFWmousebuttonfun)&mouseButtonFunction);
	}
	
	armos.math.Vector2i size(){
		auto vec = armos.Vector2i();
		glfwGetWindowSize(window, &vec[0], &vec[1]);
		return vec;
	}
	
	void pollEvents(){
		glfwPollEvents();
	}
	
	void update(){
		glfwSwapBuffers(window);
	}

	void close(){
		glfwTerminate();
	}
}

armos.app.Window currentWindow(){
	return armos.app.mainLoop.window;
}


armos.math.Vector2i windowSize(){
	return currentWindow.size;
}

float windowAspect(){
	return currentWindow.aspect;
}

// armos.math.Vector2f screenSize(){
// 	return currentWindow.screenSize;
// }

