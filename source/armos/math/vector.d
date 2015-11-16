module armos.math.vector;
import armos.math;
import core.vararg;
import std.math;

struct Vector(T, int Dimention){
	alias Vector!(T, Dimention) VectorType;

	T[Dimention] data = cast(T)0;
	this(T[] arr ...){
		if(arr.length == 0){
			foreach (ref var; data) {
				var = cast(T)0;
			}
			return;
		}
		if(arr.length == Dimention){
			data = arr;
		}else{
			assert(0);
		}
	}

	pure const T opIndex(in int index){
		return data[index];
	}

	ref T opIndex(in int index){
		return data[index];
	}
	unittest{
		auto vec = Vector3d(1, 2, 3);
		assert(vec[0] == 1.0);
		assert(vec[1] == 2.0);
		assert(vec[2] == 3.0);
	}

	// pure const bool opEquals(Object vec){
	// 	foreach (int index, T v; (cast(VectorType)vec).data) {
	// 		if(v != this.data[index]){
	// 			return false;
	// 		}
	// 	}
	// 	return true;
	// }
	unittest{
		auto vec1 = Vector3d(1, 2, 3);
		auto vec2 = Vector3d(1, 2, 3);
		assert(vec1 == vec2);
	}	
	unittest{
		auto vec1 = Vector3d(1, 2, 3);
		auto vec2 = Vector3d(2, 2, 1);
		assert(vec1 != vec2);
	}

	VectorType opNeg(){
		auto result = this;
		foreach (ref var; result.data) {
			var = -var;
		}
		return result;
	};
	unittest{
		auto vec1 = Vector3d();
		vec1[0] = 1.5;
		assert(vec1[0] == 1.5);
		assert((-vec1)[0] == -1.5);
	}

	const VectorType opAdd(in VectorType r){
		auto result = VectorType();
		foreach (int index, const T var; r.data) {
			result[index] = this[index] + var;
		}
		return result;
	}
	unittest{	
		auto vec1 = Vector3d();
		vec1[0] = 1.5;

		auto vec2 = Vector3d();
		vec2[1] = 0.2;
		vec2[0] = 0.2;
		assert((vec1+vec2)[0] == 1.7);
	}

	const VectorType opSub(in VectorType r){
		auto result = VectorType();
		foreach (int index, const T var; r.data) {
			result[index] = this[index] - var;
		}
		return result;
	}
	unittest{
		auto result = Vector3d(3, 2, 1) - Vector3d(1, 2, 3);
		assert(result == Vector3d(2, 0, -2));
	}

	const VectorType opAdd(in T v){
		auto result = VectorType();
		foreach (int index, const T var; data) {
			result[index] = this[index]+v;
		}
		return result;
	}
	unittest{
		auto result = Vector3d(3.0, 2.0, 1.0);
		assert(result+2.0 == Vector3d(5.0, 4.0, 3.0));
		assert(2.0+result == Vector3d(5.0, 4.0, 3.0));
	}

	const VectorType opSub(in T v){
		auto result = VectorType();
		foreach (int index, const T var; data) {
			result[index] = this[index]-v;
		}
		return result;
	}
	unittest{
		auto result = Vector3d(3.0, 2.0, 1.0);
		assert(result-2.0 == Vector3d(1.0, 0.0, -1.0));
	}

	const VectorType opMul(in T v){
		auto result = VectorType();
		foreach (int index, const T var; data) {
			result[index] = this[index]*v;
		}
		return result;
	}
	unittest{
		auto result = Vector3d(3.0, 2.0, 1.0);
		assert(result*2.0 == Vector3d(6.0, 4.0, 2.0));
		assert(2.0*result == Vector3d(6.0, 4.0, 2.0));
	}

	const VectorType opDiv(in T v){
		auto result = VectorType();
		foreach (int index, const T var; data) {
			result[index] = this[index]/v;
		}
		return result;
	}
	unittest{
		auto result = Vector3d(3.0, 2.0, 1.0);
		assert(result/2.0 == Vector3d(1.5, 1.0, 0.5));
	}

	const T norm(){
		T sum_of_squar = cast(T)0;
		foreach (var; this.data) {
			sum_of_squar += var*var;
		}
		return sqrt( sum_of_squar );
	}
	unittest{
		auto result = Vector3d(3.0, 2.0, 1.0);
		assert(result.norm() == ( 3.0^^2.0+2.0^^2.0+1.0^^2.0 )^^0.5);
	}

	const T dotProduct(const VectorType v){
		T sum = cast(T)0;
		for (int i = 0; i < Dimention; i++) {
			sum += this[i]*v[i];
		}
		return sum;
	}
	unittest{
		auto vec1 = Vector3d(3.0, 2.0, 1.0);
		auto vec2 = Vector3d(2.0, 1.0, 0.0);
		assert(vec1.dotProduct(vec2) == 8.0);
	}

	static if (Dimention >= 3)
	const VectorType vectorProduct(VectorType[] arg ...){
		if(arg.length != Dimention-2){
			assert(0);
		}
		auto return_vector = VectorType();
		foreach (int i, ref T v; return_vector.data) {
			auto matrix = new armos.math.Matrix!(T, Dimention, Dimention);
			auto element_vector = VectorType();
			element_vector[i] = cast(T)1;
			matrix.setRowVector(0, element_vector);
			matrix.setRowVector(1, this);
			for (int j = 2; j < Dimention; j++) {
				matrix.setRowVector(j, arg[j-2]);
			}
			// matrix.setColumnVector(i+1, this);
			v = matrix.determinant;
		}
		return return_vector;
	}
	unittest{
		auto vector0 = Vector3f(1, 2, 3);
		auto vector1 = Vector3f(4, 5, 6);
		auto anser = Vector3f(-3, 6, -3);
		assert(vector0.vectorProduct(vector1) == anser);
	}

	const VectorType normalized(){
		return this/this.norm();
	}
	unittest{
		auto vec1 = Vector3d(3.0, 2.0, 1.0);
		assert(vec1.normalized().norm() == 1.0);
	}

	void normalize(){
		this.data = this.normalized().data;
	}
	unittest{
		auto vec1 = Vector3d(3.0, 2.0, 1.0);
		vec1.normalize();
		assert(vec1.norm() == 1.0);
	}
	
	// opCast(armos.math.Matrix!())
	const T[Dimention] array(){
		return data;
	}
	unittest{
		auto vector = Vector3f(1, 2, 3);
		float[3] array = vector.array;
		assert(array == [1, 2, 3]);
		array[0] = 4;
		assert(array == [4, 2, 3]);
		assert(vector == Vector3f(1, 2, 3));
	}
	const print(){
		import std.stdio;
		for (int i = 0; i < Dimention ; i++) {
				writef("%f\t", data[i]);
		}
		writef("\n");
	}
}

alias Vector!(float, 2) Vector2f;
alias Vector!(float, 3) Vector3f;
alias Vector!(float, 4) Vector4f;
alias Vector!(double, 2) Vector2d;
alias Vector!(double, 3) Vector3d;
alias Vector!(double, 4) Vector4d;

