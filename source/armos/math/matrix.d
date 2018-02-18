module armos.math.matrix;
import armos.math;

/++
行列を表すstructです．
+/
struct Matrix(T, int RowSize, int ColSize)if(__traits(isArithmetic, T) && RowSize > 0 && ColSize > 0){
    alias Matrix!(T, RowSize, ColSize) MatrixType;
    alias armos.math.Vector!(T, ColSize) VectorType;
    
    
    alias elementType = T;
    unittest{
        static assert(is(Matrix!(float, 3, 3).elementType == float));
    }

    /++
    +/
    enum int rowSize = RowSize;

    /++
    +/
    enum int colSize = ColSize;
    
    /++
    +/
    static if(RowSize == ColSize){
        enum int size = RowSize;
    }
    unittest{
        static assert(Matrix!(float, 3, 3).size == 3);
    }

    VectorType[RowSize] elements = VectorType();

    pragma(msg, __FILE__, "(", __LINE__, "): ",
           "TODO: implement ctor(T[RowSize*ColSize] ...)");
    /++
    +/
    deprecated("Use array(arr).")
    this(T[][] arr){
        if(arr.length != 0){
            if(arr.length == RowSize){
                foreach (int index, ref VectorType vector; elements) {
                    vector = VectorType(arr[index]);
                }
            }else{
                assert(0);
            }
        }
    }

    unittest{
        float[][] array = [
            [1f, 2f],
            [3f, 4f]
        ];
        auto m = Matrix2f.array(array);
    }

    static MatrixType array(Arr:E[][], E)(Arr arr){
        MatrixType m;
        foreach (int index, ref VectorType vector; m.elements) {
            vector = VectorType.array(arr[index]);
        }
        return m;
    }

    static MatrixType array(Arr:E[ColSize][RowSize], E)(Arr arr){
        MatrixType m;
        foreach (int index, ref VectorType vector; m.elements) {
            vector = VectorType.array(arr[index]);
        }
        return m;
    }

    unittest{
        float[][] array = [
            [1, 2],
            [3, 4]
        ];
        auto m = Matrix2f.array(array);
        assert(m[0][0] == array[0][0]);
        assert(m[0][1] == array[0][1]);
        assert(m[1][0] == array[1][0]);
        assert(m[1][1] == array[1][1]);
    }

    unittest{
        float[2][2] array = [
            [1f, 2f],
            [3f, 4f]
        ];
        auto m = Matrix2f.array(array);
        assert(m[0][0] == array[0][0]);
        assert(m[0][1] == array[0][1]);
        assert(m[1][0] == array[1][0]);
        assert(m[1][1] == array[1][1]);
    }

    unittest{
        float[2][2] array = [
            [1, 2],
            [3, 4]
        ];

        auto m = Matrix2f.array([
            [1, 2],
            [3, 4]
        ]);
        assert(m[0][0] == array[0][0]);
        assert(m[0][1] == array[0][1]);
        assert(m[1][0] == array[1][0]);
        assert(m[1][1] == array[1][1]);
    }

    // this(T[ColSize][RowSize] arr){
    //     if(arr.length != 0){
    //         if(arr.length == RowSize){
    //             foreach (int index, ref VectorType vector; elements) {
    //                 vector = VectorType(arr[index]);
    //             }
    //         }else{
    //             assert(0);
    //         }
    //     }
    // }

    /++
    +/
    pure VectorType opIndex(in size_t index)const{
        return elements[index];
    }
    unittest{
        auto matrix = Matrix2d.zero;
        assert(matrix[0][0] == 0);
    }
    unittest{
        auto matrix = Matrix2d.array([
            [1.0, 0.0],
            [0.0, 1.0]
        ]);
        assert(matrix[0][0] == 1.00);
    }

    /++
    +/
    ref VectorType opIndex(in size_t index){
        return elements[index];
    }
    unittest{
        auto matrix = Matrix2d();
        matrix[1][0] = 1.0;
        assert(matrix[1][0] == 1.0);
    }

    // const bool opEquals(Object mat){
    // 	// if(this.rowSize != (cast(MatrixType)mat_tmp).rowSize){return false;}
    // 	// if(this.colSize != (cast(MatrixType)mat_tmp).colSize){return false;}
    // 	foreach (int index, VectorType vec; (cast(MatrixType)mat).elements) {
    // 		if(vec != this.elements[index]){
    // 			return false;
    // 		}
    // 	}
    // 	return true;
    // }
    unittest{
        auto matrix1 = Matrix2d.array([
            [2.0, 1.0],
            [1.0, 2.0]
        ]);

        auto matrix2 = Matrix2d.array([
            [2.0, 1.0],
            [1.0, 2.0]
        ]);
        assert(matrix1 == matrix2);
    }
    unittest{
        auto matrix1 = Matrix2d();
        matrix1[1][0] = 1.0;
        auto matrix2 = Matrix2d();
        matrix2[1][0] = 1.0;
        auto matrix3 = Matrix2d();
        matrix3[1][0] = 2.0;
        assert(matrix1 == matrix2);
        assert(matrix1 != matrix3);
    }
    unittest{
        auto matrix1 = Matrix!(double, 1, 2).array([[2.0, 1.0]]);

        auto matrix2 = Matrix!(double, 2, 1).array([
            [2.0],
            [1.0]
        ]);
        // assert(matrix1 != matrix2);

    }

    static MatrixType init(){
        auto initMatrix = MatrixType();
        foreach (ref v; initMatrix.elements) {
            foreach (ref n; v.elements) {
                n = T();
            }
        }
        return initMatrix;
    }

    static MatrixType zero(){
        auto zeroMatrix = MatrixType();
        foreach (ref v; zeroMatrix.elements) {
            foreach (ref n; v.elements) {
                n = T( 0 );
            }
        }
        return zeroMatrix;
    }
    unittest{
        assert(Matrix!(float, 3, 3).zero == Matrix!(float, 3, 3).array([
                    [0, 0, 0],
                    [0, 0, 0],
                    [0, 0, 0]
                    ])
              );

    }

    static if(rowSize == colSize){
        static MatrixType identity(){
            auto identityMatrix = MatrixType.zero;
            for (int i = 0; i < MatrixType.rowSize; i++) {
                identityMatrix[i][i] = T(1);
            }
            return identityMatrix;
        }
    }

    unittest{
        assert(
                Matrix!(float, 3, 3).identity == Matrix!(float, 3, 3).array([
                    [1, 0, 0],
                    [0, 1, 0],
                    [0, 0, 1]
                    ])
              );
    }

    /++
    +/
    MatrixType opNeg()const{
        auto result = MatrixType();
        foreach (int index, ref var; result.elements) {
            var = -this[index];
        }
        return result;
    }
    unittest{
        auto matrix = Matrix2d();
        matrix[0][0] = 1.0;
        assert((-matrix)[0][0] == -1.0);
    }		

    /++
    +/
    MatrixType opAdd(in MatrixType r)const{
        auto result = MatrixType();
        foreach (int index, const VectorType var; r.elements) {
            result[index] = this[index] + var;
        }
        return result;
    }
    unittest{
        auto matrix1 = Matrix2d.zero;
        matrix1[0][0] = 1.0;
        auto matrix2 = Matrix2d.zero;
        matrix2[0][0] = 2.0;
        matrix2[0][1] = 1.0;
        auto matrix3 = matrix1 + matrix2;
        assert(matrix3[0][0] == 3.0);
        assert(matrix3[0][1] == 1.0);
    }		

    /++
    +/
    MatrixType opSub(in MatrixType r)const{
        auto result = MatrixType();
        foreach (int index, const VectorType var; r.elements) {
            result[index] = this[index] - var;
        }
        return result;
    }
    unittest{
        auto matrix1 = Matrix2d.zero;
        matrix1[0][0] = 1.0;
        auto matrix2 = Matrix2d.zero;
        matrix2[0][0] = 2.0;
        matrix2[0][1] = 1.0;
        auto matrix3 = matrix1 - matrix2;
        assert(matrix3[0][0] == -1.0);
        assert(matrix3[0][1] == -1.0);
    }		


    /++
    +/
    MatrixType opAdd(in T v)const{
        auto result = MatrixType();
        foreach (int index, const VectorType var; elements) {
            result[index] = this[index]+v;
        }
        return result;
    }
    unittest{
        auto matrix1 = Matrix2d.zero;
        auto matrix2 = matrix1 + 5.0;
        auto matrix3 = 3.0 + matrix1;
        assert(matrix2[1][0] == 5.0);
        assert(matrix3[1][1] == 3.0);
    }

    /++
    +/
    MatrixType opSub(in T v)const{
        auto result = MatrixType();
        foreach (int index, const VectorType var; elements) {
            result[index] = this[index]-v;
        }
        return result;
    }
    unittest{
        auto matrix1 = Matrix2d.zero;
        auto matrix2 = matrix1 - 3.0;
        assert(matrix2[1][0] == -3.0);
    }

    /++
    +/
    MatrixType opMul(in T v)const{
        auto result = MatrixType();
        foreach (int index, const VectorType var; elements) {
            result[index] = var*v;
        }
        return result;
    }
    unittest{
        auto matrix1 = Matrix2d.identity;
        auto matrix2 = matrix1 * 2.0;
        assert(matrix2[0][0] == 2.0);
        auto matrix3 = 2.0 * matrix2;
        assert(matrix3[1][1] == 4.0);
    }

    /++
    +/
    MatrixType opMul(in MatrixType mat_r)const{
        auto result = MatrixType();
        immutable mat_r_size = mat_r.rowSize;
        for (int targetRow = 0; targetRow < RowSize; targetRow++) {
            for (int targetCol = 0; targetCol < ColSize; targetCol++) {
                T sum = T(0);
                for (int dim = 0; dim < mat_r_size; dim++) {
                    sum += elements[targetRow][dim] * mat_r[dim][targetCol];
                }
                result[targetRow][targetCol] = sum;
            }

        }
        return result;
    }
    unittest{
        auto matrix1 = Matrix2f.array([
            [2.0, 0.0],
            [1.0, 1.0]
        ]);

        auto matrix2 = Matrix2f.array([
            [1.0, 1.0],
            [0.0, 1.0]
        ]);

        auto matrix3 = matrix1 * matrix2;

        auto matrix_answer = Matrix2f.array([
            [2.0, 2.0],
            [1.0, 2.0]
        ]);

        assert(matrix3 == matrix_answer);
    }

    /++
    +/
    VectorType opMul(in VectorType vec_r)const{
        auto result = VectorType();
        for (int targetRow = 0; targetRow < elements.length; targetRow++) {
            T sum = T(0);
            foreach (elem; (elements[targetRow] * vec_r).elements) {
                sum += elem;
            }
            result[targetRow] = sum;
        }
        return result;
    }
    unittest{
        auto matrix1 = Matrix2f.array([
            [2.0, 0.0],
            [1.0, 1.0]
        ]);
        auto vector1 = armos.math.Vector2f(1.0, 0.0);
        auto vector_answer = armos.math.Vector2f(2.0, 1.0);
        auto vector2 = matrix1 * vector1;
        assert(vector2 == vector_answer);
    }

    MatrixType opDiv(in T v)const{
        auto result = MatrixType();
        foreach (int index, const VectorType var; elements) {
            result[index] = this[index]/v;
        }
        return result;
    }
    unittest{
        auto matrix1 = Matrix2d.array([
            [2.0, 4.0],
            [3.0, 1.0]
        ]);
        auto matrix2 = matrix1 / 2.0;

        auto matrixA = Matrix2d.array([
            [1.0, 2.0],
            [1.5, 0.5]
        ]);
        assert(matrix2 == matrixA);
    }


    static if(RowSize == 3 && ColSize == 3 && ( is(T == double) || is(T == float) )){
        MatrixType inverse(){
            MatrixType mat = MatrixType.array([
                    [elements[1][1]*elements[2][2]-elements[1][2]*elements[2][1], elements[0][2]*elements[2][1]-elements[0][1]*elements[2][2], elements[0][1]*elements[1][2]-elements[0][2]*elements[1][1]],
                    [elements[1][2]*elements[2][0]-elements[1][0]*elements[2][2], elements[0][0]*elements[2][2]-elements[0][2]*elements[2][0], elements[0][2]*elements[1][0]-elements[0][0]*elements[1][2]],
                    [elements[1][0]*elements[2][1]-elements[1][1]*elements[2][0], elements[0][1]*elements[2][0]-elements[0][0]*elements[2][1], elements[0][0]*elements[1][1]-elements[0][1]*elements[1][0]]
                    ]);
            return mat/determinant;
        }
    }
    unittest{
        auto m= Matrix3f.array([
            [1, 2, 0], 
            [3, 2, 2], 
            [1, 4, 3]
        ]);

        auto mInv= m.inverse;

        auto mA= Matrix3f.array([
            [1, 0, 0], 
            [0, 1, 0], 
            [0, 0, 1]
        ]);
        assert(mInv*m == mA);
    }

    /++
    +/
    void setColumnVector(in int column, in VectorType vec){
        foreach (int i , ref VectorType v; elements) {
            v[column] = vec[i];
        }
    }
    unittest{
        auto matrix = Matrix2f();
        auto vec0 = armos.math.Vector2f(1, 2);
        auto vec1 = armos.math.Vector2f(3, 4);
        matrix.setColumnVector(0, vec0);
        matrix.setColumnVector(1, vec1);
        assert(matrix == Matrix2f.array([
                                      [1, 3], 
                                      [2, 4]
                                  ]));

    }

    /++
    +/
    void setRowVector(in int row, in VectorType vec){
        this[row] = vec;
    }
    unittest{
        auto matrix = Matrix2f();
        auto vec0 = armos.math.Vector2f(1, 2);
        auto vec1 = armos.math.Vector2f(3, 4);
        matrix.setRowVector(0, vec0);
        matrix.setRowVector(1, vec1);
        assert(matrix == Matrix2f.array([
                    [1, 2], 
                    [3, 4]
                    ]));
    }

    /++
    +/
    MatrixType setMatrix(M)(M mat, in int offsetR = 0, in int offsetC = 0)
        in{
            assert(M.rowSize<=this.rowSize);
            assert(M.colSize<=this.colSize);
            assert(offsetR + M.rowSize<=this.rowSize);
            assert(offsetC + M.colSize<=this.colSize);
        }body{
            for (int x = 0; x < mat.rowSize; x++) {
                for (int y = 0; y < mat.colSize; y++) {
                    this[x+offsetR][y+offsetC] = mat[x][y];
                }
            }
            return this;
        }
    unittest{
        auto mat44 = Matrix!(double, 4, 4).array([
            [1, 0, 0, 4],
            [0, 1, 0, 0],
            [0, 0, 1, 0],
            [0, 0, 0, 2]
        ]);
        auto mat33 = Matrix!(float, 3, 3).array([
            [2, 1, 0],
            [0, 1, 3],
            [0, 0, 3]
        ]);

        auto mat44A = Matrix!(double, 4, 4).array([
            [1, 2, 1, 0],
            [0, 0, 1, 3],
            [0, 0, 0, 3],
            [0, 0, 0, 2]
        ]);
        assert( mat44.setMatrix(mat33, 0, 1) == mat44A );
    }

    static if(RowSize == 3 && ColSize == 3 && ( is(T == double) || is(T == float) )){
        T determinant()const{
            return 
                elements[0][0] * elements[1][1] * elements[2][2] -
                elements[0][0] * elements[2][1] * elements[1][2] -
                elements[1][0] * elements[0][1] * elements[2][2] +
                elements[1][0] * elements[2][1] * elements[0][2] +
                elements[2][0] * elements[0][1] * elements[1][2] -
                elements[2][0] * elements[1][1] * elements[0][2];
        }
    }else{
        /++
        +/
        T determinant()const{
            import std.stdio;
            T sum = T(0);
            for (int i = 0; i < RowSize; i++) {
                T v = T(1);
                for (int j = 0; j < RowSize; j++) {
                    if (i+j>=RowSize) {
                        v *= this[i+j-RowSize][j];
                    }else{
                        v *= this[i+j][j];
                    }
                }
                sum +=v;
                v = T(1);
                for (int j = 0; j < RowSize; j++) {
                    if (i-j<0) {
                        v *= this[i-j+RowSize][j];
                    }else{
                        v *= this[i-j][j];
                    }
                }
                sum -=v;
            }
            return sum;
        }
    }
    unittest{
        // auto matrix = Matrix3f(
        // 		[1, 2, 0], 
        // 		[3, 2, 2], 
        // 		[1, 4, 3]
        // 		);
        // assert(matrix.determinant == 6+4+0 - (8+18+0) );
    }
    unittest{
        import std.stdio;
        import std.math;
        auto matrix = Matrix3f.array([
            [0.8, 0, 0],
            [0, 1.5, 0],
            [0, 0, 0.8]
        ]);
        assert( approxEqual(matrix.determinant, 0.96) );
    }

    /++
    +/
    auto array(size_t dimention = 1)()const{
        static if(dimention == 1){
            T[RowSize*ColSize] tmp;
            for (int i = 0; i < RowSize ; i++) {
                for (int j = 0; j < ColSize ; j++) {
                    tmp[i+j*RowSize] = elements[i][j];
                }
            }
            return tmp;
        }else static if(dimention == 2){
            T[ColSize][RowSize] tmp;
            foreach (size_t index, rowVector; elements) {
                tmp[index] = rowVector.array;
            }
            return tmp;
        }
    }
    unittest{
        auto matrix = Matrix3f.array([
            [1, 4, 7], 
            [2, 5, 8], 
            [3, 6, 9]
        ]);
        assert(matrix.array == [1, 2, 3, 4, 5, 6, 7, 8, 9]);
        assert(matrix.array!1 == [1, 2, 3, 4, 5, 6, 7, 8, 9]);
        assert(matrix.array!2 == [
                                     [1, 4, 7], 
                                     [2, 5, 8], 
                                     [3, 6, 9]
        ]);
    }

    T[ColSize][RowSize] nestedArray(){
        T[ColSize][RowSize] result;
        foreach (rowIndex, row; elements) {
            result[rowIndex] = row.elements;
        }
        return result;
    }
    pragma(msg, __FILE__, "(", __LINE__, "): ",
           "TODO: should test");
    unittest{
    }

    MatrixType transpose()() if(isSquareMatrix!(MatrixType)){
        MatrixType result;
        for(int i = 0; i<MatrixType.rowSize; i++){
            for(int j = 0; j<MatrixType.colSize; j++){
                result[j][i] = this[i][j];
            }
        }
        return result;
    }

    unittest{
        auto matrix = Matrix3f.array([
            [1, 4, 7], 
            [2, 5, 8], 
            [3, 6, 9]
        ]);

        auto ans = Matrix3f.array([
            [1, 2, 3], 
            [4, 5, 6], 
            [7, 8, 10]
        ]);
        assert(matrix.transpose == ans);
    }

    /++
        自身を別の型のMatrixへキャストしたものを返します．キャスト後の型は元のMatrixのRowSize, ColSizeが等しくある必要があります．
    +/
    CastedType opCast(CastedType)()const if(CastedType.rowSize == typeof(this).rowSize && CastedType.colSize == typeof(this).colSize){
        auto mat = CastedType();
        foreach (int index, const var; this.elements) {
            mat.elements[index] = cast(CastedType.VectorType)elements[index];
        }
        return mat;
    }
    unittest{
        auto m_f= Matrix3f.array([
            [1, 4, 7], 
            [2, 5, 8], 
            [3, 6, 9]
        ]);

        auto m_i= Matrix3i.zero;
        
        m_i = cast(Matrix3i)m_f;
        
        assert(m_i[0][0] == 1);

        //Invalid cast. Different size.
        assert(!__traits(compiles, {
            auto m_f= Matrix3f.array([
                [1, 4, 7], 
                [2, 5, 8], 
                [3, 6, 9]
            ]);
            auto m_i= Matrix4i.zero;
            vec_i = cast(Vector3i)vec_f;
        }));
    }
}

alias Matrix!(int, 2, 2) Matrix2i;
alias Matrix!(int, 3, 3) Matrix3i;
alias Matrix!(int, 4, 4) Matrix4i;
alias Matrix!(float, 2, 2) Matrix2f;
alias Matrix!(float, 3, 3) Matrix3f;
alias Matrix!(float, 4, 4) Matrix4f;
alias Matrix!(double, 2, 2) Matrix2d;
alias Matrix!(double, 3, 3) Matrix3d;
alias Matrix!(double, 4, 4) Matrix4d;

template SquareMatrix(T, int D){
    alias SquareMatrix = Matrix!(T, D, D);
}
unittest{
    static assert(isSquareMatrix!(SquareMatrix!(float, 4)));
}

/++
+/
template isMatrix(M) {
    public{
        enum bool isMatrix = __traits(compiles, (){
                static assert(is(M == Matrix!(typeof(M()[0][0]), M.rowSize, M.colSize)));
                });
    }//public
}//template isMatrix
unittest{
    static assert(isMatrix!(Matrix!(float, 3, 3)));
    static assert(!isMatrix!(float));
}

/++
+/
template isSquareMatrix(M){
    public{
        enum bool isSquareMatrix = __traits(compiles, (){
                static assert(M.rowSize == M.colSize);
                static assert(isMatrix!(M));
                });
    }//public
}//template isSquareMatrix
unittest{
    static assert(isSquareMatrix!(Matrix!(float, 3, 3)));
    static assert(!isSquareMatrix!(Matrix!(float, 2, 3)));
    static assert(!isSquareMatrix!(float));
}
