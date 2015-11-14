module armos.math.matrix;
import armos.math;

class Matrix(T, int RowSize, int ColSize){
	alias Matrix!(T, RowSize, ColSize) MatrixType;
	alias armos.math.Vector!(T, ColSize) VectorType;
	
	const int rowSize = RowSize;
	const int colSize = ColSize;

	VectorType[RowSize] array;

	this(T[][] arr ...){
		if(arr.length == 0){
			foreach (ref var; array) {
				var = VectorType();
			}
			return;
		}
		if(arr.length == RowSize){
			foreach (int index, ref VectorType vector; array) {
				vector = VectorType(arr[index]);
			}
		}else{
			assert(0);
		}
	}

	pure const VectorType opIndex(in int index){
		return cast(VectorType)array[index];
	}
	unittest{
		auto matrix = new Matrix2d;
		assert(matrix[0][0] == 0);
	}
	unittest{
		auto matrix = new Matrix2d(
				[1.0, 0.0],
				[0.0, 1.0]
				);
		assert(matrix[0][0] == 1.00);
	}

	ref VectorType opIndex(in int index){
		return cast(VectorType)array[index];
	}
	unittest{
		auto matrix = new Matrix2d;
		matrix[1][0] = 1.0;
		assert(matrix[1][0] == 1.0);
	}

	const bool opEquals(Object mat){
		// if(this.rowSize != (cast(MatrixType)mat_tmp).rowSize){return false;}
		// if(this.colSize != (cast(MatrixType)mat_tmp).colSize){return false;}
		foreach (int index, VectorType vec; (cast(MatrixType)mat).array) {
			if(vec != this.array[index]){
				return false;
			}
		}
		return true;
	}
	unittest{
		auto matrix1 = new Matrix2d(
				[2.0, 1.0],
				[1.0, 2.0]
				);
		
		auto matrix2 = new Matrix2d(
				[2.0, 1.0],
				[1.0, 2.0]
				);
		assert(matrix1 == matrix2);
	}
	unittest{
		auto matrix1 = new Matrix2d;
		matrix1[1][0] = 1.0;
		auto matrix2 = new Matrix2d;
		matrix2[1][0] = 1.0;
		auto matrix3 = new Matrix2d;
		matrix3[1][0] = 2.0;
		assert(matrix1 == matrix2);
		assert(matrix1 != matrix3);
	}
	unittest{
		auto matrix1 = new Matrix!(double, 1, 2)(
				[2.0, 1.0]
				);
		
		auto matrix2 = new Matrix!(double, 2, 1)(
				[2.0],
				[1.0]
				);
		// assert(matrix1 != matrix2);
	
	}

	MatrixType opNeg(){
		auto result = this;
		foreach (ref var; result.array) {
			var = -var;
		}
		return result;
	}
	unittest{
		auto matrix = new Matrix2d;
		matrix[0][0] = 1.0;
		assert((-matrix)[0][0] == -1.0);
	}		

	const MatrixType opAdd(in MatrixType r){
		auto result = new MatrixType;
		foreach (int index, const VectorType var; r.array) {
			result[index] = this[index] + var;
		}
		return result;
	}
	unittest{
		auto matrix1 = new Matrix2d;
		matrix1[0][0] = 1.0;
		auto matrix2 = new Matrix2d;
		matrix2[0][0] = 2.0;
		matrix2[0][1] = 1.0;
		auto matrix3 = matrix1 + matrix2;
		assert(matrix3[0][0] == 3.0);
		assert(matrix3[0][1] == 1.0);
	}		

	const MatrixType opSub(in MatrixType r){
		auto result = new MatrixType;
		foreach (int index, const VectorType var; r.array) {
			result[index] = this[index] - var;
		}
		return result;
	}
	unittest{
		auto matrix1 = new Matrix2d;
		matrix1[0][0] = 1.0;
		auto matrix2 = new Matrix2d;
		matrix2[0][0] = 2.0;
		matrix2[0][1] = 1.0;
		auto matrix3 = matrix1 - matrix2;
		assert(matrix3[0][0] == -1.0);
		assert(matrix3[0][1] == -1.0);
	}		


	const MatrixType opAdd(in T v){
		auto result = new MatrixType;
		foreach (int index, const VectorType var; array) {
			result[index] = this[index]+v;
		}
		return result;
	}
	unittest{
		auto matrix1 = new Matrix2d();
		auto matrix2 = matrix1 + 5.0;
		auto matrix3 = 3.0 + matrix1;
		assert(matrix2[1][0] == 5.0);
		assert(matrix3[1][1] == 3.0);
	}

	const MatrixType opSub(in T v){
		auto result = new MatrixType;
		foreach (int index, const VectorType var; array) {
			result[index] = this[index]-v;
		}
		return result;
	}
	unittest{
		auto matrix1 = new Matrix2d();
		auto matrix2 = matrix1 - 3.0;
		assert(matrix2[1][0] == -3.0);
	}
	
	const MatrixType opMul(in MatrixType mat_r){
		auto result = new MatrixType;
		for (int targetRow = 0; targetRow < array.length; targetRow++) {
			for (int targetCol = 0; targetCol < array[0].array.length; targetCol++) {
				T sum = cast(T)0;
				for (int dim = 0; dim < mat_r.array.length; dim++) {
					sum += this[targetRow][dim] * mat_r[dim][targetCol];
				}
				result[targetRow][targetCol] = sum;
			}
			
		}
		return result;
	}
	unittest{
		auto matrix1 = new Matrix2f(
				[2.0, 0.0],
				[1.0, 1.0]
				);
		
		auto matrix2 = new Matrix2f(
				[1.0, 1.0],
				[0.0, 1.0]
				);
		
		auto matrix3 = matrix1 * matrix2;
		
		auto matrix_answer = new Matrix2f(
				[2.0, 2.0],
				[1.0, 2.0]
				);
		
		assert(matrix3 == matrix_answer);
	}
	
	// const VectorType opMul(in VectorType vec_r){
	// 	auto mat_r
	// 	return result;
	// }
	
	const VectorType opMul(in VectorType vec_r){
		auto result = VectorType();
		for (int targetRow = 0; targetRow < array.length; targetRow++) {
			T sum = cast(T)0;
			for (int dim = 0; dim < rowSize; dim++) {
				sum += this[targetRow][dim] * vec_r[dim];
			}
			result[targetRow] = sum;
		}
		return result;
	}
	unittest{
		auto matrix1 = new Matrix2f(
				[2.0, 0.0],
				[1.0, 1.0]
				);
		auto vector1 = armos.math.Vector2f(1.0, 0.0);
		auto vector_answer = armos.math.Vector2f(2.0, 1.0);
		auto vector2 = matrix1 * vector1;
		assert(vector2 == vector_answer);
	}
	
	void setColumnVector(in int column, in VectorType vec){
		foreach (int i , ref VectorType v; array) {
			v[column] = vec[i];
		}
	}
	unittest{
		auto matrix = new Matrix2f;
		auto vec0 = armos.math.Vector2f(1, 2);
		auto vec1 = armos.math.Vector2f(3, 4);
		matrix.setColumnVector(0, vec0);
		matrix.setColumnVector(1, vec1);
		assert(matrix == new Matrix2f(
					[1, 3], 
					[2, 4]
					));
		
	}
	
	void setRowVector(in int row, in VectorType vec){
		this[row] = cast(VectorType)vec;
	}
	unittest{
		auto matrix = new Matrix2f;
		auto vec0 = armos.math.Vector2f(1, 2);
		auto vec1 = armos.math.Vector2f(3, 4);
		matrix.setRowVector(0, vec0);
		matrix.setRowVector(1, vec1);
		assert(matrix == new Matrix2f(
					[1, 2], 
					[3, 4]
					));
	}
	
	const T determinant(){
		T sum = cast(T)0;
		for (int i = 0; i < RowSize; i++) {
			T vp = cast(T)1;
			T v = cast(T)1;
			for (int j = 0; j < RowSize; j++) {
				if (i+j>=RowSize) {
					v *= this[i+j-RowSize][j];
				}else{
					v *= this[i+j][j];
				}
			}
			sum +=v;
			v = cast(T)1;
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
	unittest{
		auto matrix = new Matrix3f(
				[1, 2, 0], 
				[3, 2, 2], 
				[1, 4, 3]
				);
		assert(matrix.determinant == 6+4+0 - (8+18+0) );
	}
}

alias Matrix!(float, 2, 2) Matrix2f;
alias Matrix!(float, 3, 3) Matrix3f;
alias Matrix!(float, 4, 4) Matrix4f;
alias Matrix!(double, 2, 2) Matrix2d;
alias Matrix!(double, 3, 3) Matrix3d;
alias Matrix!(double, 4, 4) Matrix4d;
