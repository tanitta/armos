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
    M4 modelViewProjectionMatrix()const{
        return projectionMatrix*modelViewMatrix;
    }
    
    M4 modelViewMatrix()const{
        return _modelViewMatrixStack.updatedCurrentMatrix * _currentModelViewMatrix;
    }
    
    M4 projectionMatrix()const{
        return _projectionMatrixStack.updatedCurrentMatrix * _currentProjectionMatrix;
    }
    
    M4 textureMatrix()const{
        return _textureMatrixStack.updatedCurrentMatrix * _currentTextureMatrix;
    }
    
    // TODO change to no arg
    void pushModelViewMatrix(){
        pushMatrix(_currentModelViewMatrix, _modelViewMatrixStack);
    }
    
    void pushProjectionMatrix(){
        pushMatrix(_currentProjectionMatrix, _projectionMatrixStack);
    }
    
    void pushTextureMatrix(){
        pushMatrix(_currentTextureMatrix, _textureMatrixStack);
    }
    
    // TODO : Mult
    void multModelViewMatrix(in M4 matrix){
        _currentModelViewMatrix.multMatrix(matrix);
    }
    
    void multProjectionMatrix(in M4 matrix){
        _currentProjectionMatrix.multMatrix(matrix);
    }
    
    void multTextureMatrix(in M4 matrix){
        _currentTextureMatrix.multMatrix(matrix);
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
        M4     _currentModelViewMatrix  = armos.math.Matrix4f.identity;
        M4     _currentProjectionMatrix = armos.math.Matrix4f.identity;
        M4     _currentTextureMatrix    = armos.math.Matrix4f.identity;

        
    }
}

private{
    M4 updatedCurrentMatrix(in armos.math.Matrix4f[] stack){
        import std.algorithm;
        return M4.identity.reduce!"a*b"(stack);
    }
    
    void pushMatrix(ref armos.math.Matrix4f currentMatrix, ref armos.math.Matrix4f[] stack){
        stack ~= currentMatrix;
        currentMatrix = armos.math.Matrix4f.identity;
    }
    
    void popMatrix(ref M4[] stack, ref armos.math.Matrix4f currentMatrix){
        currentMatrix = stack.updatedCurrentMatrix;
        stack.popBack;
    }
    
    void loadMatrix(in M4 matrix, ref armos.math.Matrix4f[] stack, ref armos.math.Matrix4f currentMatrix){
        currentMatrix = matrix;
    }
    
    void multMatrix(ref armos.math.Matrix4f currentMatrix, in M4 matrix){
        currentMatrix = currentMatrix * matrix;
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
    
    matrixStack.pushModelViewMatrix;
    matrixStack.multModelViewMatrix(m1);
    assert(matrixStack.modelViewMatrix == m1);
    matrixStack.multModelViewMatrix(m2);
    assert(matrixStack.modelViewMatrix == m1*m2);
    matrixStack.pushModelViewMatrix;
    matrixStack.multModelViewMatrix(m2);
    assert(matrixStack.modelViewMatrix == m1*m2*m2);
    matrixStack.popModelViewMatrix;
    
    assert(matrixStack.modelViewMatrix == m1*m2);
    
    matrixStack.multModelViewMatrix(m3);
    assert(matrixStack.modelViewMatrix == m1*m2*m3);
    matrixStack.pushModelViewMatrix();
    assert(matrixStack.modelViewMatrix == m1*m2*m3);
    matrixStack.popModelViewMatrix();
    assert(matrixStack.modelViewMatrix == m1*m2*m3);
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
    
    auto matrixStack = new MatrixStack;
    
    //TODO
    matrixStack.pushModelViewMatrix;
    matrixStack.pushProjectionMatrix;
    
    matrixStack.multModelViewMatrix(m1);
    assert(matrixStack.modelViewMatrix == m1);
    
    matrixStack.multProjectionMatrix(m2);
    assert(matrixStack.projectionMatrix == m2);
    
    assert(matrixStack.modelViewProjectionMatrix == m2*m1);
    
    matrixStack.popProjectionMatrix;
    assert(matrixStack.modelViewProjectionMatrix == m1);
    
    matrixStack.popModelViewMatrix;
    assert(matrixStack.modelViewProjectionMatrix == M4.identity);
}
