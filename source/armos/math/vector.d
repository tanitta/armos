module armos.math.vector;
import armos.math;
import core.vararg;
import std.math;

class Vector(T, int Dimention){
	alias Vector!(T, Dimention) VectorType;

	T[Dimention] array;
	this(T[] arr ...){
		if(arr.length == 0){
			foreach (ref var; array) {
				var = cast(T)0;
			}
			return;
		}
		if(arr.length == Dimention){
			array = arr;
		}else{
			assert(0);
		}
	}

	pure const T opIndex(in int index){
		return array[index];
	}

	ref T opIndex(in int index){
		return array[index];
	}
	unittest{
		auto vec = new Vector3d(1, 2, 3);
		assert(vec[0] == 1.0);
		assert(vec[1] == 2.0);
		assert(vec[2] == 3.0);
	}

	pure const bool opEquals(Object vec){
		foreach (int index, T v; (cast(VectorType)vec).array) {
			if(v != this.array[index]){
				return false;
			}
		}
		return true;
	}
	unittest{
		auto vec1 = new Vector3d(1, 2, 3);
		auto vec2 = new Vector3d(1, 2, 3);
		assert(vec1 == vec2);
	}	
	unittest{
		auto vec1 = new Vector3d(1, 2, 3);
		auto vec2 = new Vector3d(2, 2, 1);
		assert(vec1 != vec2);
	}

	VectorType opNeg(){
		auto result = this;
		foreach (ref var; result.array) {
			var = -var;
		}
		return result;
	};
	unittest{
		auto vec1 = new Vector3d;
		vec1[0] = 1.5;
		assert(vec1[0] == 1.5);
		assert((-vec1)[0] == -1.5);
	}

	const VectorType opAdd(in VectorType r){
		auto result = new VectorType;
		foreach (int index, const T var; r.array) {
			result[index] = this[index] + var;
		}
		return result;
	}
	unittest{	
		auto vec1 = new Vector3d;
		vec1[0] = 1.5;

		auto vec2 = new Vector3d;
		vec2[1] = 0.2;
		vec2[0] = 0.2;
		assert((vec1+vec2)[0] == 1.7);
	}

	const VectorType opSub(in VectorType r){
		auto result = new VectorType;
		foreach (int index, const T var; r.array) {
			result[index] = this[index] - var;
		}
		return result;
	}
	unittest{
		auto result = new Vector3d(3, 2, 1) - new Vector3d(1, 2, 3);
		assert(result == new Vector3d(2, 0, -2));
	}

	const VectorType opAdd(in T v){
		auto result = new VectorType;
		foreach (int index, const T var; array) {
			result[index] = this[index]+v;
		}
		return result;
	}
	unittest{
		auto result = new Vector3d(3.0, 2.0, 1.0);
		assert(result+2.0 == new Vector3d(5.0, 4.0, 3.0));
		assert(2.0+result == new Vector3d(5.0, 4.0, 3.0));
	}

	const VectorType opSub(in T v){
		auto result = new VectorType;
		foreach (int index, const T var; array) {
			result[index] = this[index]-v;
		}
		return result;
	}
	unittest{
		auto result = new Vector3d(3.0, 2.0, 1.0);
		assert(result-2.0 == new Vector3d(1.0, 0.0, -1.0));
	}

	const VectorType opMul(in T v){
		auto result = new VectorType;
		foreach (int index, const T var; array) {
			result[index] = this[index]*v;
		}
		return result;
	}
	unittest{
		auto result = new Vector3d(3.0, 2.0, 1.0);
		assert(result*2.0 == new Vector3d(6.0, 4.0, 2.0));
		assert(2.0*result == new Vector3d(6.0, 4.0, 2.0));
	}

	const VectorType opDiv(in T v){
		auto result = new VectorType;
		foreach (int index, const T var; array) {
			result[index] = this[index]/v;
		}
		return result;
	}
	unittest{
		auto result = new Vector3d(3.0, 2.0, 1.0);
		assert(result/2.0 == new Vector3d(1.5, 1.0, 0.5));
	}

	const T norm(){
		T sum_of_squar = cast(T)0;
		foreach (var; this.array) {
			sum_of_squar += var*var;
		}
		return sqrt( sum_of_squar );
	}
	unittest{
		auto result = new Vector3d(3.0, 2.0, 1.0);
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
		auto vec1 = new Vector3d(3.0, 2.0, 1.0);
		auto vec2 = new Vector3d(2.0, 1.0, 0.0);
		assert(vec1.dotProduct(vec2) == 8.0);
	}

	const VectorType normalized(){
		return this/this.norm();
	}
	unittest{
		auto vec1 = new Vector3d(3.0, 2.0, 1.0);
		assert(vec1.normalized().norm() == 1.0);
	}

	void normalize(){
		this.array = this.normalized().array;
	}
	unittest{
		auto vec1 = new Vector3d(3.0, 2.0, 1.0);
		vec1.normalize();
		assert(vec1.norm() == 1.0);
	}
	
	// opCast(armos.math.Matrix!())
}

alias Vector!(float, 2) Vector2f;
alias Vector!(float, 3) Vector3f;
alias Vector!(float, 4) Vector4f;
alias Vector!(double, 2) Vector2d;
alias Vector!(double, 3) Vector3d;
alias Vector!(double, 4) Vector4d;

