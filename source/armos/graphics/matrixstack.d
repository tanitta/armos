module armos.graphics.matrixstack;
import armos.app;
import armos.types;
import std.array;

class MatrixStack {
	private{
	armos.types.Rectangle[] viewportHistory;
	armos.math.Matrix4f[] viewportMatrixStack;
	armos.math.Matrix4f[] modelViewMatrixStack;
	armos.math.Matrix4f[] projectionMatrixStack;
	armos.math.Matrix4f[] textureMatrixStack;
	
	armos.types.Rectangle currentViewport_ = armos.types.Rectangle();
	armos.math.Matrix4f currentViewportMatrix_ = armos.math.Matrix4f();
	armos.math.Matrix4f currentModelViewMatrix_ = armos.math.Matrix4f();
	armos.math.Matrix4f currentProjectionMatrix_ = armos.math.Matrix4f();
	armos.math.Matrix4f currentTextureMatrix_ = armos.math.Matrix4f();
	}
	
	armos.app.BaseGLWindow*  currentWindow_;
	
	this(armos.app.BaseGLWindow* window){
		currentWindow_ = window;
	}
	
	armos.types.Rectangle currentViewport(){
		return currentViewport_;
	}
	
	void pushViewportMatrix(armos.math.Matrix4f matrix){
		viewportMatrixStack ~= matrix;
	}
	void pushModelViewMatrix(armos.math.Matrix4f matrix){
		modelViewMatrixStack ~= matrix;
	}
	void pushProjectionMatrix(armos.math.Matrix4f matrix){
		projectionMatrixStack ~= matrix;
	}
	void pushTextureMatrix(armos.math.Matrix4f matrix){
		textureMatrixStack ~= matrix;
	}
	
	void popViewportMatrix(){
		viewportMatrixStack.popBack;
	}
	void popModelViewMatrix(){
		modelViewMatrixStack.popBack;
	}
	void popProjectionMatrix(){
		projectionMatrixStack.popBack;
	}
	void popTextureMatrix(){
		textureMatrixStack.popBack;
	}
	
	void loadModelViewMatrix(armos.math.Matrix4f matrix){
		currentModelViewMatrix_ = matrix;
		updatedRelatedMatrices();
	}
	
	void loadProjectionMatrix(armos.math.Matrix4f matrix){
		currentProjectionMatrix_= matrix;
		updatedRelatedMatrices();
	}
	
	void loadTextureMatrix(armos.math.Matrix4f matrix){
		currentTextureMatrix_= matrix;
	}
	
	void updatedRelatedMatrices(){}
	
	armos.math.Vector2f renderSurfaceSize(){
		return currentWindow_.windowSize();
	}
	
	void viewport(float x, float y, float width, float height, bool vflip){
		auto position = armos.math.Vector2f(x, y);
		auto size = armos.math.Vector2f(width, height);
		if(width < 0 || height < 0){
			size = renderSurfaceSize();
			// width = getRenderSurfaceWidth();
			// height = getRenderSurfaceHeight();
			// vflip = isVFlipped();
		}

		if (vflip){
			position[1] = renderSurfaceSize[1] - (y + height);
		}

		currentViewport.set(position, size);
	};
	
	armos.types.Rectangle nativeViewport(){
		return currentViewport;
	}
	
	void push(armos.math.Matrix4f){}
}
