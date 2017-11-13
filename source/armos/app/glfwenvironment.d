module armos.app.glfwenvironment;

import derelict.opengl3.gl;

import armos.app.environment;
import armos.app.application;
import armos.graphics.gl.context;
import armos.app.window;
import armos.app.windowconfig;
import armos.app.glfwwindow;
import armos.graphics.renderer;

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
        GLFWEnvironment renderer(Renderer renderer){
            _renderer = renderer;
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
        GLFWEnvironment build(){
            _window = new GLFWWindow(_windowConfig, _windowContext);
            if(!_context)_context = new Context;

            import rx;
            _window.observables.setup.doSubscribe!(event => renderer.setup());
            _window.observables.windowResize.doSubscribe!(event => renderer.target.resize(_window.frameBufferSize));
            return this;
        }

        ///
        Application application(){return _application;}

        ///
        Window window(){return _window;}

        ///
        Context context(){return _context;}

        ///
        Renderer renderer(){return _renderer;}
    }//public

    private{
        Application _application;
        GLFWWindow  _window;
        Renderer    _renderer;
        Context     _context;
        GLFWwindow* _windowContext;
        WindowConfig _windowConfig;
    }//private
}//class GLFWEnvironment
