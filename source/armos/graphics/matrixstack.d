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

/++
+/
class MatrixStack {
    public{
        M4 matrix()const{
            return _stackedMatrix * _currentMatrix;
        }
        
        void push(in M4 newMatrix = M4.identity){
            _matrices ~= _currentMatrix;
            updateStackedMatrix;
            _currentMatrix = newMatrix;
        }
        
        void pop(){
            _currentMatrix = _matrices[$-1];
            _matrices.popBack;
            updateStackedMatrix;
        }
        
        void load(in M4 matrix){
            _currentMatrix = matrix;
        }
        
        void mult(in M4 matrix){
            _currentMatrix = _currentMatrix * matrix;
        }
    }//public

    private{
        M4[] _matrices;
        M4   _currentMatrix = armos.math.Matrix4f.identity;
        M4   _stackedMatrix;
        
        void updateStackedMatrix(){
            import std.algorithm;
            _stackedMatrix = M4.identity.reduce!"a*b"(_matrices);
        }
    }//private
}//class MatrixStack

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
    
    matrixStack.push;
    matrixStack.mult(m1);
    assert(matrixStack.matrix == m1);
    matrixStack.mult(m2);
    assert(matrixStack.matrix== m1*m2);
    matrixStack.push;
    matrixStack.mult(m2);
    assert(matrixStack.matrix == m1*m2*m2);
    matrixStack.pop;
    
    assert(matrixStack.matrix == m1*m2);
    
    matrixStack.mult(m3);
    assert(matrixStack.matrix == m1*m2*m3);
    matrixStack.push();
    assert(matrixStack.matrix == m1*m2*m3);
    matrixStack.pop();
    assert(matrixStack.matrix == m1*m2*m3);
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
    
    matrixStack.push;
    matrixStack.push;
    
    matrixStack.mult(m1);
    assert(matrixStack.matrix == m1);
    
    matrixStack.mult(m2);
    assert(matrixStack.matrix == m1*m2);
    
    // assert(matrixStack.modelViewProjectionMatrix == m2*m1);
    //
    // matrixStack.popProjectionMatrix;
    // assert(matrixStack.modelViewProjectionMatrix == m1);
    //
    // matrixStack.popModelViewMatrix;
    // assert(matrixStack.modelViewProjectionMatrix == M4.identity);
}

package mixin template MatrixStackFunction(string Name){
    public{
        import std.string;
        mixin("
        armos.math.Matrix4f " ~ Name.toLower ~ "Matrix(){
          return currentRenderer." ~ Name.toLower ~ "Matrix;
        }
        ");
        
        ///
        mixin("
        void push" ~ Name ~ "Matrix(in armos.math.Matrix4f newMatrix = armos.math.Matrix4f.identity){
            currentRenderer.push" ~ Name ~ "Matrix(newMatrix);
        }
        ");

        ///
        mixin( "
        void pop" ~ Name ~ "Matrix(){
            currentRenderer.pop" ~ Name ~ "Matrix;
        }
        ");

        ///
        mixin("
        void mult" ~ Name ~ "Matrix(in armos.math.Matrix4f matrix){
            currentRenderer.mult" ~ Name ~ "Matrix(matrix);
        }
        ");

        ///
        mixin( "
        void load" ~ Name ~ "Matrix(in armos.math.Matrix4f matrix){
            currentRenderer.load" ~ Name ~ "Matrix(matrix);
        }
        ");

    }
}

package mixin template MatrixStackManipulator(string Name){
    public{
        import std.string;
        mixin("
        armos.math.Matrix4f " ~ Name.toLower ~ "Matrix()const{
          return _" ~ Name.toLower ~ "MatrixStack.matrix;
        }
        ");
        
        ///
        mixin("
        void push" ~ Name ~ "Matrix(in armos.math.Matrix4f newMatrix = armos.math.Matrix4f.identity){
            _" ~ Name.toLower ~ "MatrixStack.push(newMatrix);
        }
        ");

        ///
        mixin( "
        void pop" ~ Name ~ "Matrix(){
            _" ~ Name.toLower ~ "MatrixStack.pop;
        }
        ");

        ///
        mixin("
        void mult" ~ Name ~ "Matrix(in armos.math.Matrix4f matrix){
          _" ~ Name.toLower ~ "MatrixStack.mult(matrix);
        }
        ");

        ///
        mixin( "
        void load" ~ Name ~ "Matrix(in armos.math.Matrix4f matrix){
            _" ~ Name.toLower ~ "MatrixStack.load(matrix);
        }
        ");
    }
    
    private{
        mixin("armos.graphics.MatrixStack _" ~ Name.toLower ~ "MatrixStack = new armos.graphics.MatrixStack();");
    }
}
