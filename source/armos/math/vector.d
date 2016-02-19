module armos.math.vector;
import armos.math;
import core.vararg;
import std.math;

/++
	ベクトル計算を行うstructです
++/
struct Vector(T, int Dimention){
	alias Vector!(T, Dimention) VectorType;
	
	T[Dimention] data = T(0);
	
	/++
		Vectorのinitializerです．引数はDimentionと同じ個数の要素を取ります．
	++/
	this(T[] arr ...){
		if(arr.length == 0)
			data[] = T(0);
		else if(arr.length == Dimention)
			data = arr;
		else
			assert(false);
	}

	/++
	++/
	pure T opIndex(in int index)const{
		return data[index];
	}

	/++
	++/
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
	
	/++
	+/
	static zero(){
		auto v =  VectorType();
		for (int i = 0; i < Dimention; i++) {
			v[i] = T(0);
		}
		return v;
	}

	/++
	+/
	VectorType opNeg()const{
		auto result = VectorType();
		result.data[] = -data[];
		return result;
	};
	unittest{
		auto vec1 = Vector3d();
		vec1[0] = 1.5;
		assert(vec1[0] == 1.5);
		assert((-vec1)[0] == -1.5);
	}

	/++
	++/
	VectorType opAdd(in VectorType r)const{
		auto result = VectorType();
		result.data[] = data[] + r.data[];
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

	/++
	++/
	VectorType opSub(in VectorType r)const{
		auto result = VectorType();
		result.data[] = data[] - r.data[];
		return result;
	}
	unittest{
		auto result = Vector3d(3, 2, 1) - Vector3d(1, 2, 3);
		assert(result == Vector3d(2, 0, -2));
	}

	/++
	++/
	VectorType opAdd(in T v)const{
		auto result = VectorType();
		result.data[] = data[] + v;
		return result;
	}
	unittest{
		auto result = Vector3d(3.0, 2.0, 1.0);
		assert(result+2.0 == Vector3d(5.0, 4.0, 3.0));
		assert(2.0+result == Vector3d(5.0, 4.0, 3.0));
	}

	/++
	++/
	VectorType opSub(in T v)const{
		auto result = VectorType();
		result.data[] = data[] - v;
		return result;
	}
	unittest{
		auto result = Vector3d(3.0, 2.0, 1.0);
		assert(result-2.0 == Vector3d(1.0, 0.0, -1.0));
	}

	/++
	++/
	VectorType opMul(in T v)const{
		auto result = VectorType();
		result.data[] = data[] * v;
		return result;
	}
	unittest{
		auto result = Vector3d(3.0, 2.0, 1.0);
		assert(result*2.0 == Vector3d(6.0, 4.0, 2.0));
		assert(2.0*result == Vector3d(6.0, 4.0, 2.0));
	}

	/++
	++/
	VectorType opDiv(in T v)const{
		auto result = VectorType();
		result.data[] = data[] / v;
		return result;
	}
	unittest{
		auto result = Vector3d(3.0, 2.0, 1.0);
		assert(result/2.0 == Vector3d(1.5, 1.0, 0.5));
	}
	
	/++
	++/
	VectorType opMod(in T v)const{
		auto result = VectorType();
		result.data[] = data[] % v;
		return result;
	}
	unittest{
		auto result = Vector3d(4.0, 2.0, 1.0);
		assert(result%2.0 == Vector3d(0.0, 0.0, 1.0));
	}
	
	/++
	++/
	VectorType opMul(in VectorType v)const{
		auto result = VectorType();
		result.data[] = data[] * v.data[];
		return result;
	}
	unittest{
		auto vec1 = Vector3d(3.0, 2.0, 1.0);
		auto vec2 = Vector3d(2.0, 1.0, 0.0);
		assert(vec1*vec2 == Vector3d(6.0, 2.0, 0.0));
	}
	
	/++
	++/
	VectorType opDiv(in VectorType v)const{
		auto result = VectorType();
		result.data[] = data[] / v.data[];
		return result;
	}
	unittest{
		auto vec1 = Vector3d(4.0, 2.0, 1.0);
		auto vec2 = Vector3d(2.0, 1.0, 1.0);
		assert(vec1/vec2 == Vector3d(2.0, 2.0, 1.0));
	}
	
	/++
	++/
	VectorType opMod(in VectorType v)const{
		auto result = VectorType();
		result.data[] = data[] % v.data[];
		return result;
	}
	unittest{
		auto vec1 = Vector3d(3.0, 2.0, 1.0);
		auto vec2 = Vector3d(2.0, 1.0, 1.0);
		assert(vec1%vec2 == Vector3d(1.0, 0.0, 0.0));
	}
	
	/++
		Vectorのノルムを返します．
	++/
	T norm()const{
		import std.numeric : dotProduct;
		T sumsq = dotProduct(data, data);

		static if( is(T == int ) )
			return cast(int)sqrt(cast(float)sumsq);
		else
			return sqrt(sumsq);
	}
	unittest{
		auto result = Vector3d(3.0, 2.0, 1.0);
		assert(result.norm() == ( 3.0^^2.0+2.0^^2.0+1.0^^2.0 )^^0.5);
	}

	/++
		Vectorのドット積を返します．
	++/
	T dotProduct(const VectorType v)const{
		import std.numeric : dotProduct;
		return dotProduct(data, v.data);
	}
	unittest{
		auto vec1 = Vector3d(3.0, 2.0, 1.0);
		auto vec2 = Vector3d(2.0, 1.0, 2.0);
		assert(vec1.dotProduct(vec2) == 10.0);
	}
	
	unittest{
		auto vec1 = Vector3d(0.4, 0.1, 0.3);
		auto vec2 = Vector3d(0.2, 0.5, 2.0);
		assert(vec1.dotProduct(vec2) == 0.73);
	}

	/++
		Vectorのベクトル積(クロス積，外積)を返します．
		Dimentionが3以上の場合のみ使用できます．
	++/
	static if (Dimention >= 3)
	VectorType vectorProduct(VectorType[] arg ...)const{
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

	/++
		正規化したVectorを返します．
	++/
	VectorType normalized()const{
		return this/this.norm();
	}
	unittest{
		auto vec1 = Vector3d(3.0, 2.0, 1.0);
		assert(vec1.normalized().norm() == 1.0);
	}

	/++
		Vectorを正規化します．
	++/
	void normalize(){
		this.data[] /= this.norm();
	}
	unittest{
		auto vec1 = Vector3d(3.0, 2.0, 1.0);
		vec1.normalize();
		assert(vec1.norm() == 1.0);
	}
	
	/++
		Vectorの要素を一次元配列で返します．
	++/
	T[Dimention] array()const{
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
	
	/++
		Vectorを標準出力に渡します
	++/
	void print()const{
		import std.stdio;
		for (int i = 0; i < Dimention ; i++) {
			static if( is(T == int ) )
				writef("%d\t", data[i]);
			else
				writef("%f\t", data[i]);
		}
		writef("\n");
	}
	
	/++
		自身を別の型のVectorへキャストしたものを返します．キャスト後の型は元のVectorと同じ次元である必要があります．
	++/
	CastType opCast(CastType)()const{
		auto vec = CastType();
		if (vec.data.length != data.length) {
			assert(0);
		}else{
			foreach (int index, const T var; data) {
				vec.data[index] = cast( typeof( vec.data[0] ) )data[index];
			}
			return vec;
		}
	}
	unittest{
		auto vec_f = Vector3f(2.5, 0, 0);
		auto vec_i = Vector3i(0, 0, 0);

		vec_i = cast(Vector3i)vec_f;

		assert(vec_i[0] == 2);
	}
}

/// int型の2次元ベクトルです．
alias Vector!(int, 2) Vector2i;
/// int型の3次元ベクトルです．
alias Vector!(int, 3) Vector3i;
/// int型の4次元ベクトルです．
alias Vector!(int, 4) Vector4i;
/// float型の2次元ベクトルです．
alias Vector!(float, 2) Vector2f;
/// float型の3次元ベクトルです．
alias Vector!(float, 3) Vector3f;
/// float型の4次元ベクトルです．
alias Vector!(float, 4) Vector4f;
/// double型の2次元ベクトルです．
alias Vector!(double, 2) Vector2d;
/// double型の3次元ベクトルです．
alias Vector!(double, 3) Vector3d;
/// double型の4次元ベクトルです．
alias Vector!(double, 4) Vector4d;
