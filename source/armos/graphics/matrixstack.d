module armos.graphics.matrixstack;
import armos.app;
import armos.types;
import std.array;
static import armos.math;

private alias M4 = armos.math.Matrix4f;

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

    // void pushViewportMatrix(M4 matrix){
    //     _viewportMatrixStack ~= matrix;
    // }
    M4 modelViewMatrix()const{
        return _currentModelViewMatrix;
    }
    
    M4 projectionMatrix()const{
        return _currentProjectionMatrix;
    }
    
    M4 textureMatrix()const{
        return _currentTextureMatrix;
    }
    
    void pushModelViewMatrix(in M4 matrix){
        pushMatrix(matrix, _modelViewMatrixStack, _currentModelViewMatrix);
    }
    
    void pushProjectionMatrix(in M4 matrix){
        pushMatrix(matrix, _projectionMatrixStack, _currentProjectionMatrix);
    }
    
    void pushTextureMatrix(in M4 matrix){
        pushMatrix(matrix, _textureMatrixStack, _currentTextureMatrix);
    }

    // void popViewportMatrix(){
    //     _viewportMatrixStack.popBack;
    // }
    
    void popModelViewMatrix(){
        popMatrix(_modelViewMatrixStack, _currentModelViewMatrix);
    }
    
    void popProjectionMatrix(){
        popMatrix(_projectionMatrixStack, _currentProjectionMatrix);
    }
    
    void popTextureMatrix(){
        popMatrix(_textureMatrixStack, _currentTextureMatrix);
    }

    void loadModelViewMatrix(in M4 matrix){
        loadMatrix(matrix, _modelViewMatrixStack, _currentModelViewMatrix);
    }

    void loadProjectionMatrix(in M4 matrix){
        loadMatrix(matrix, _projectionMatrixStack, _currentProjectionMatrix);
    }

    void loadTextureMatrix(in M4 matrix){
        loadMatrix(matrix, _textureMatrixStack, _currentTextureMatrix);
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
    
    

    private{
        // armos.types.Rectangle[] _viewportHistory;
        // M4[]   _viewportMatrixStack;
        M4[]   _modelViewMatrixStack;
        M4[]   _projectionMatrixStack;
        M4[]   _textureMatrixStack;

        // armos.types.Rectangle   _currentViewport         = armos.types.Rectangle();
        // M4     _currentViewportMatrix   = armos.math.Matrix4f();
        M4     _currentModelViewMatrix  = armos.math.Matrix4f();
        M4     _currentProjectionMatrix = armos.math.Matrix4f();
        M4     _currentTextureMatrix    = armos.math.Matrix4f();

        M4 _modelViewProjectionMatrix = armos.math.Matrix4f();
        
    }
}

private{
    M4 updatedCurrentMatrix(in armos.math.Matrix4f[] stack){
        import std.algorithm;
        return M4.identity.reduce!"a*b"(stack);
    }
    
    void pushMatrix(in M4 matrix, ref armos.math.Matrix4f[] stack, ref armos.math.Matrix4f currentMatrix){
        stack ~= matrix;
        currentMatrix = stack.updatedCurrentMatrix;
    }
    
    void popMatrix(ref M4[] stack, ref armos.math.Matrix4f currentMatrix){
        stack.popBack;
        currentMatrix = stack.updatedCurrentMatrix;
    }
    
    void loadMatrix(in M4 matrix, ref armos.math.Matrix4f[] stack, ref armos.math.Matrix4f currentMatrix){
        stack = [];
        currentMatrix = matrix;
    }
}
unittest{
    immutable m1 = M4(
            [1, 0, 0, 10], 
            [0, 1, 0, 0], 
            [0, 0, 1, 0], 
            [0, 0, 0, 1], 
    );
        
    immutable m2 = M4(
            [1, 0, 0, 0], 
            [0, 1, 0, 20], 
            [0, 0, 1, 0], 
            [0, 0, 0, 1], 
    );
    
    immutable m3 = M4(
            [1, 0, 0, 0], 
            [0, 1, 0, 0], 
            [0, 0, 1, 30], 
            [0, 0, 0, 1], 
    );
    
    auto matrixStack = new MatrixStack;
    
    matrixStack.pushModelViewMatrix(m1);
    assert(matrixStack.modelViewMatrix == m1);
    
    matrixStack.pushModelViewMatrix(m2);
    assert(matrixStack.modelViewMatrix == m1*m2);
    
    matrixStack.popModelViewMatrix;
    assert(matrixStack.modelViewMatrix == m1);
    
    matrixStack.pushModelViewMatrix(m3);
    assert(matrixStack.modelViewMatrix == m1*m3);
    
    matrixStack.pushModelViewMatrix(m2);
    assert(matrixStack.modelViewMatrix == m1*m3*m2);
    
    matrixStack.loadModelViewMatrix(m2);
    assert(matrixStack.modelViewMatrix == m2);
}
