module armos.app.glfwenvironment;

import derelict.opengl3.gl;

import armos.app.environment;
import armos.app.application;
import armos.graphics.gl.context;
import armos.app.window;
import armos.app.windowconfig;
import armos.app.glfwwindow;

///
class GLFWEnvironment: Environment{
    import derelict.glfw3.glfw3:GLFWwindow;
    public{
        ///
        GLFWEnvironment application(Application app){
            _application = app;
            return this;
        }

        ///
        GLFWEnvironment windowConfig(WindowConfig config){
            _windowConfig = config;
            return this;
        }

        ///
        GLFWEnvironment sharedContextFrom(GLFWEnvironment otherEnv){
            _windowContext = otherEnv._window.context;
            _context       = otherEnv.context;
            return this;
        }

        ///
        Environment build(){
            _window = new GLFWWindow(_windowConfig, _windowContext);
            if(!_context)_context = new Context;
            return this;
        }

        ///
        Application application(){return _application;}

        ///
        Window window(){return _window;}

        ///
        Context context(){return _context;}
    }//public

    private{
        Application _application;
        GLFWWindow _window;
        Context     _context;
        GLFWwindow* _windowContext;
        WindowConfig _windowConfig;
    }//private
}//class GLFWEnvironment
