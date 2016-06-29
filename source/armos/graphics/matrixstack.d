module armos.graphics.matrixstack;
import armos.app;
import armos.types;
import std.array;
static import armos.math;

/++
RendererでのMatrixを管理するclassです．
Deprecated: 現在使用されていません．
+/
class MatrixStack {
    // armos.app.Window  _currentWindow;
    //
    // this(armos.app.Window window){
    //     _currentWindow = window;
    // }
    //
    // armos.types.Rectangle currentViewport(){
    //     return _currentViewport;
    // }

    // void pushViewportMatrix(armos.math.Matrix4f matrix){
    //     _viewportMatrixStack ~= matrix;
    // }
    
    void pushModelViewMatrix(armos.math.Matrix4f matrix){
        _modelViewMatrixStack ~= matrix;
    }
    
    void pushProjectionMatrix(armos.math.Matrix4f matrix){
        _projectionMatrixStack ~= matrix;
    }
    
    void pushTextureMatrix(armos.math.Matrix4f matrix){
        _textureMatrixStack ~= matrix;
    }

    // void popViewportMatrix(){
    //     _viewportMatrixStack.popBack;
    // }
    
    void popModelViewMatrix(){
        _modelViewMatrixStack.popBack;
    }
    
    void popProjectionMatrix(){
        _projectionMatrixStack.popBack;
    }
    
    void popTextureMatrix(){
        _textureMatrixStack.popBack;
    }

    void loadModelViewMatrix(in armos.math.Matrix4f matrix){
        _currentModelViewMatrix = matrix;

        // _modelViewProjectionMatrix = modelViewMatrix * orientedProjectionMatrix;
    }

    void loadProjectionMatrix(in armos.math.Matrix4f matrix){
        _currentProjectionMatrix = matrix;
        updatedRelatedMatrices();
    }

    void loadTextureMatrix(armos.math.Matrix4f matrix){
        _currentTextureMatrix= matrix;
    }

    void updatedRelatedMatrices(){}

    // armos.math.Vector2f renderSurfaceSize(){
    //     return cast(armos.math.Vector2f)_currentWindow.size();
    // }

    // void viewport(float x, float y, float width, float height, bool vflip){
    //     auto position = armos.math.Vector2f(x, y);
    //     auto size = armos.math.Vector2f(width, height);
    //     if(width < 0 || height < 0){
    //         size = renderSurfaceSize();
    //         // width = getRenderSurfaceWidth();
    //         // height = getRenderSurfaceHeight();
    //         // vflip = isVFlipped();
    //     }
    //
    //     if (vflip){
    //         position[1] = renderSurfaceSize[1] - (y + height);
    //     }
    //
    //     currentViewport.set(position, size);
    // };

    // armos.types.Rectangle nativeViewport(){
    //     return currentViewport;
    // }

    void push(armos.math.Matrix4f){}
    
    private{
        armos.types.Rectangle[] _viewportHistory;
        armos.math.Matrix4f[]   _viewportMatrixStack;
        armos.math.Matrix4f[]   _modelViewMatrixStack;
        armos.math.Matrix4f[]   _projectionMatrixStack;
        armos.math.Matrix4f[]   _textureMatrixStack;

        // armos.types.Rectangle   _currentViewport         = armos.types.Rectangle();
        // armos.math.Matrix4f     _currentViewportMatrix   = armos.math.Matrix4f();
        armos.math.Matrix4f     _currentModelViewMatrix  = armos.math.Matrix4f();
        armos.math.Matrix4f     _currentProjectionMatrix = armos.math.Matrix4f();
        armos.math.Matrix4f     _currentTextureMatrix    = armos.math.Matrix4f();

        armos.math.Matrix4f _modelViewProjectionMatrix = armos.math.Matrix4f();
    }
}
