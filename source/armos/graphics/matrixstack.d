module armos.graphics.matrixstack;
import armos.app;
import armos.types;
class MatrixStack {
	armos.app.BaseGLWindow*  currentWindow_;
	auto currentViewport = new armos.types.Rectangle;
	this(armos.app.BaseGLWindow* window){
		currentWindow_ = window;
	};
	
	void viewport(float x, float y, float width, float height, bool vflip){
	
	};
	
	armos.types.Rectangle getNativeViewport(){
		return currentViewport;
	}
}
