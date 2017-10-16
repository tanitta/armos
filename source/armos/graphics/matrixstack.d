module armos.graphics.matrixstack;

import std.array;
import armos.app;
import armos.types;
import armos.math;

private alias M4 = Matrix4f;

/++
RendererでのMatrixを管理するclassです．
Deprecated: 現在使用されていません．
+/

/++
+/
class MatrixStack {
    public{
        M4 matrix()const{
            return _matrices[$-1];
        }
        
        void push(){
            _matrices ~= _matrices[$-1];
        }
        
        void pop(){
            _matrices.popBack;
        }
        
        void load(in M4 matrix){
            _matrices[$-1] = matrix;
        }
        
        void mult(in M4 matrix){
            _matrices[$-1] = _matrices[$-1] * matrix;
        }
    }//public

    private{
        M4[] _matrices = [M4.identity];
    }//private
}//class MatrixStack

unittest{
    immutable m1 = M4.array(
        [
            [1f, 0f, 0f, 10f], 
            [0f, 1f, 0f, 0f], 
            [0f, 0f, 1f, 0f], 
            [0f, 0f, 0f, 1f], 
        ]
    );
        
    immutable m2 = M4.array(
        [
            [1f, 0f, 0f, 0f], 
            [0f, 1f, 0f, 20f], 
            [0f, 0f, 1f, 0f], 
            [0f, 0f, 0f, 1f], 
        ]
    );
    
    immutable m3 = M4.array(
        [
            [1f, 0f, 0f, 0f], 
            [0f, 1f, 0f, 0f], 
            [0f, 0f, 1f, 30f], 
            [0f, 0f, 0f, 1f], 
        ]
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
    immutable m1 = M4.array(
        [
            [1, 0, 0, 10], 
            [0, 1, 0, 0], 
            [0, 0, 1, 0], 
            [0, 0, 0, 1], 
        ]
    );
        
    immutable m2 = M4.array(
        [
            [1, 0, 0, 0], 
            [0, 1, 0, 20], 
            [0, 0, 1, 0], 
            [0, 0, 0, 1], 
        ]
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
        import armos.app.runner:currentScene;
        import std.string;
        /// Matrix4f nameMatrix()
        mixin("
        Matrix4f " ~ Name.toLower ~ "Matrix(){
          return currentScene." ~ Name.toLower ~ "MatrixStack.matrix();
        }
        ");
        
        /// void pushNameMatrix(in Matrix4f newMatrix = Matrix4f.identity)
        mixin("
        void push" ~ Name ~ "Matrix(){
            currentScene." ~ Name.toLower ~ "MatrixStack.push();
        }
        ");

        /// Matrix4f popNameMatrix()
        mixin( "
        void pop" ~ Name ~ "Matrix(){
            currentScene." ~ Name.toLower ~ "MatrixStack.pop();
        }
        ");

        /// void multNameMatrix(in Matrix4f matrix)
        mixin("
        void mult" ~ Name ~ "Matrix(in Matrix4f matrix){
            currentScene." ~ Name.toLower ~ "MatrixStack.mult(matrix);
        }
        ");

        /// void loadNameMatrix(in Matrix4f matrix)
        mixin( "
        void load" ~ Name ~ "Matrix(in Matrix4f matrix){
            currentScene." ~ Name.toLower ~ "MatrixStack.load(matrix);
        }
        ");

    }
}

package mixin template MatrixStackManipulator(string Name){
    import armos.math.matrix;
    import armos.graphics.matrixstack;
    public{
        import std.string;
        mixin("
        Matrix4f " ~ Name.toLower ~ "Matrix()const{
          return _" ~ Name.toLower ~ "MatrixStack.matrix;
        }
        ");
        
        ///
        mixin("
        void push" ~ Name ~ "Matrix(){
            _" ~ Name.toLower ~ "MatrixStack.push();
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
        void mult" ~ Name ~ "Matrix(in Matrix4f matrix){
          _" ~ Name.toLower ~ "MatrixStack.mult(matrix);
        }
        ");

        ///
        mixin( "
        void load" ~ Name ~ "Matrix(in Matrix4f matrix){
            _" ~ Name.toLower ~ "MatrixStack.load(matrix);
        }
        ");
    }
    
    private{
        mixin("MatrixStack _" ~ Name.toLower ~ "MatrixStack = new MatrixStack();");
    }
}
