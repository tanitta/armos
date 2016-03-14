module armos.math.quaternion;
import armos.math;
import std.math;
/++
クオータニオンを表すstructです．
+/
struct Quaternion(T)if(__traits(isArithmetic, T)){
	alias Quaternion!(T) Q;
	alias V4 = armos.armos.math.Vector!(T, 4);
	alias V3 = armos.armos.math.Vector!(T, 3);
	V4 vec = V4();
	
	/++
	+/
	this(in T x, in T y, in T z, in T w){
		this[0] = x;
		this[1] = y;
		this[2] = z;
		this[3] = w;
	}
	
	/++
	+/
	this(in T s, in V3 v){
		this[0] = s;
		this[1] = v[0];
		this[2] = v[1];
		this[3] = v[2];
	}
	
	/++
	+/
	this( in V4 v){
		this[0] = v[0];
		this[1] = v[1];
		this[2] = v[2];
		this[3] = v[3];
	}
	
	/++
	+/
	T opIndex(in int index)const{
		return vec[index];
	}
	
	/++
	+/
	ref  T opIndex(in int index){
		return vec[index];
	}
	unittest{
		Quaternion!(double) q = Quaternion!(double)(1, 2, 3, 4);
		assert(q[0]==1);
		assert(q[1]==2);
		assert(q[2]==3);
		assert(q[3]==4);
	}
	
	/++
	+/
	static Q zero(){
		return Q(T( 0 ), T( 0 ), T( 0 ), T( 0 ));
	}
	unittest{
		auto e = Quaternion!(double).zero;
		assert(e[0]==0);
		assert(e[1]==0);
		assert(e[2]==0);
		assert(e[3]==0);
	}
	
	/++
	+/
	static Q unit(){
		return Q(T( 1 ), T( 0 ), T( 0 ), T( 0 ));
	}
	unittest{
		auto e = Quaternion!(double).unit;
		assert(e[0]==1);
		assert(e[1]==0);
		assert(e[2]==0);
		assert(e[3]==0);
	}

	/++
	+/
	Q opMul(in Q r_quat)const{
		auto v_l = V3();
		T s_l  = this[0];
		v_l[0] = this[1];
		v_l[1] = this[2];
		v_l[2] = this[3];
		
		auto v_r = V3();
		T s_r  = r_quat[0];
		v_r[0] = r_quat[1];
		v_r[1] = r_quat[2];
		v_r[2] = r_quat[3];
		
		auto return_v = s_l*v_r + s_r*v_l + v_l.vectorProduct(v_r) ;
		auto return_s = ( s_l*s_r ) - ( v_l.dotProduct(v_r) );
		return Q(return_s, return_v[0], return_v[1], return_v[2]);
	}
	unittest{
		Quaternion!(double) q1      = Quaternion!(double)(1, 0, 0, 0);
		Quaternion!(double) q2      = Quaternion!(double)(1, 0, 0, 0);
		Quaternion!(double) qAnswer = Quaternion!(double)(1, 0, 0, 0);
		assert(q1*q2 == qAnswer);
	}
	unittest{
		V3 va = V3(0.5, 0.1, 0.4);
		V3 v = va.normalized;
		
		Quaternion!(double) q1      = Quaternion!(double)(cos(0.1), v[0]*sin(0.1), v[1]*sin(0.1), v[2]*sin(0.1));
		Quaternion!(double) q2      = Quaternion!(double)(cos(0.2), v[0]*sin(0.2), v[1]*sin(0.2), v[2]*sin(0.2));
		Quaternion!(double) qResult = q1 * q2;
		Quaternion!(double) qAnswer = Quaternion!(double)(cos(0.3), v[0]*sin(0.3), v[1]*sin(0.3), v[2]*sin(0.3));
		foreach (int i, value; qResult.vec.data) {
			assert( approxEqual(value, qAnswer[i]) );
		}
	}
	
	/++
	+/
	Q opNeg()const{
		return Q(-this[0], -this[1], -this[2], -this[3]);
	}
	unittest{
		Quaternion!(double) q = Quaternion!(double)(1, 1, 1, 1);
		Quaternion!(double) a = Quaternion!(double)(-1, -1, -1, -1);
		assert(-q == a);
	}
		
	/++
	+/
	Q opAdd(in Q q)const{
		auto return_quat = Q();
		return_quat.vec = vec + q.vec;
		return return_quat;
	}
	unittest{
		auto q1 = Quaternion!(double)(1, 2, 3, 4);
		auto q2 = Quaternion!(double)(2, 3, 4, 5);
		auto qA = Quaternion!(double)(3, 5, 7, 9);
		assert(q1+q2 == qA);
	}
	
	/++
	+/
	Q opMul(in T r)const{
		auto return_quat = Q();
		return_quat.vec = vec * r;
		return return_quat;
	}
	unittest{
		auto q = Quaternion!(double)(1, 2, 3, 4);
		auto qA = Quaternion!(double)(3, 6, 9, 12);
		assert(q*3 == qA);
	}
	
	/++
	+/
	Q opDiv(in T r)const {
		auto return_quat = Q();
		return_quat.vec = vec / r;
		return return_quat;
	}
	unittest{
		auto q = Quaternion!(double)(3, 6, 9, 12);
		auto qA = Quaternion!(double)(1, 2, 3, 4);
		assert(q/3 == qA);
	}
	
	/++
		Quaternionのノルムを返します．
	+/
	T norm()const {
		return sqrt(this[0]^^2.0 + this[1]^^2.0 + this[2]^^2.0 + this[3]^^2.0);
	}
	unittest{
		auto q = Quaternion!(double)(1, 2, 3, 4);
		assert(q.norm == sqrt(30.0));
	}
	
	/++
	+/
	Q normalized()const {
		return Q(vec.normalized);
	}
	unittest{
		// auto q = Quaternion!(double)(1, 2, 3, 4);
		// assert(q.norm == sqrt(30.0));
	}
	
	/++
		Quaternionの共役Quaternionを返します．
	+/
	Q conjugate()const{
		return Q(this[0], -this[1], -this[2], -this[3]);
	}
	unittest{
		auto q  = Quaternion!(double)(1, 2, 3, 4);
		auto qA = Quaternion!(double)(1, -2, -3, -4);
		assert(q.conjugate == qA);
	}
	
	/++
		
	+/
	Q inverse()const{
		return conjugate/(this[0]^^2.0 + this[1]^^2.0 + this[2]^^2.0 + this[3]^^2.0);
	}
	unittest{
		auto q  = Quaternion!(double)(1, 0, 1, 0);
		auto qR = q.inverse;
		auto qA = Quaternion!(double)(0.5, 0, -0.5, 0);
		
		foreach (int i, value; qR.vec.data) {
			assert( approxEqual(value, qA[i]) );
		}
	}
	
	/++
		自身の回転行列(4x4)を返します．
	+/
	armos.math.Matrix!(T, 4, 4) matrix44()const{
		return armos.math.Matrix!(T, 4, 4)(
			[this[0]^^2.0+this[1]^^2.0-this[2]^^2.0-this[3]^^2.0, 2.0*(this[1]*this[2]-this[0]*this[3]),               2.0*(this[1]*this[3]+this[0]*this[2]),               0],
			[2.0*(this[1]*this[2]+this[0]*this[3]),               this[0]^^2.0-this[1]^^2.0+this[2]^^2.0-this[3]^^2.0, 2.0*(this[2]*this[3]-this[0]*this[1]),               0],
			[2.0*(this[1]*this[3]-this[0]*this[2]),               2.0*(this[2]*this[3]+this[0]*this[1]),               this[0]^^2.0-this[1]^^2.0-this[2]^^2.0+this[3]^^2.0, 0],
			[0,                                                   0,                                                   0,                                                   1]
		);
	}
	unittest{
	}
	
	/++
		自身の回転行列(3x3)を返します．
	+/
	armos.math.Matrix!(T, 3, 3) matrix33()const{
		return armos.math.Matrix!(T, 3, 3)(
			[this[0]^^2.0+this[1]^^2.0-this[2]^^2.0-this[3]^^2.0, 2.0*(this[1]*this[2]-this[0]*this[3]),               2.0*(this[1]*this[3]+this[0]*this[2])              ],
			[2.0*(this[1]*this[2]+this[0]*this[3]),               this[0]^^2.0-this[1]^^2.0+this[2]^^2.0-this[3]^^2.0, 2.0*(this[2]*this[3]-this[0]*this[1])              ],
			[2.0*(this[1]*this[3]-this[0]*this[2]),               2.0*(this[2]*this[3]+this[0]*this[1]),               this[0]^^2.0-this[1]^^2.0-this[2]^^2.0+this[3]^^2.0]
		);
	}
		
	/++
		指定したベクトルを自身で回転させたベクトルを返します．
	+/
	V3 rotatedVector(V3 vec)const {
		if( norm^^2.0 < T.epsilon){
			return vec;
		}else{
			auto temp_quat = Q(1, vec[0], vec[1], vec[2]);
			auto return_quat= this*temp_quat*this.inverse;
			auto return_vector = V3(return_quat[1], return_quat[2], return_quat[3]);
			return return_vector;
		}
	}
	unittest{
		auto v = armos.math.Vector3d(1, 0, 0);
		double ang = PI*0.5*0.5;
		auto q  = Quaternion!(double)(cos(ang), 0*sin(ang), 0*sin(ang), 1*sin(ang));
		auto vR = q.rotatedVector(v);
		auto vA = armos.math.Vector3d(0, 1, 0);
		
		foreach (int i, value; vR.data) {
			assert( approxEqual(value, vA[i]) );
		}
	}
	
	/++
		指定した軸で自身を回転させます．
		Params:
		ang = 回転角
		axis = 回転軸
	+/
	static Q angleAxis(T ang, V3 axis){
		auto halfAngle = ang*T(0.5);
		return Q(cos(halfAngle), axis[0]*sin(halfAngle), axis[1]*sin(halfAngle), axis[2]*sin(halfAngle));
	}
	unittest{
		auto v = armos.math.Vector3d(1, 0, 0);
		auto q = Quaternion!(double).angleAxis(PI*0.5, armos.math.Vector3d(0, 0, 1));
		auto vR = q.rotatedVector(v);
		auto vA = armos.math.Vector3d(0, 1, 0);
		
		foreach (int i, value; vR.data) {
			assert( approxEqual(value, vA[i]) );
		}
	}
	
	Q productAngle(T gain){
		return slerp(Q.zero, this, gain);
	}
	
}

/++
球面線形補間(Sphercal Linear Interpolation)を行います．
Params:
from = tが0の時のQuaternion
to = tが1の時のQuaternion
t = 
+/
Q slerp(Q, T)(in Q from, in Q to,  T t){
	double omega, cos_omega, sin_omega, scale_from, scale_to;

	Q quatTo = to;
	cos_omega = from.vec.dotProduct(to.vec);

	if (cos_omega < T( 0.0 )) {
		cos_omega = -cos_omega;
		quatTo = -to;
	}

	if( (T( 1.0 ) - cos_omega) > T.epsilon ){
		omega = acos(cos_omega);
		sin_omega = sin(omega);
		scale_from = sin(( T( 1.0 ) - t ) * omega) / sin_omega;
		scale_to = sin(t * omega) / sin_omega;
	}else{
		scale_from = T( 1.0 ) - t;
		scale_to = t;
	}

	return ( from * scale_from ) + ( quatTo * scale_to  );
}
unittest{
	auto v = armos.math.Vector3d(1, 0, 0);
	auto qBegin= Quaternion!(double).angleAxis(0, armos.math.Vector3d(0, 0, 1));
	auto qEnd = Quaternion!(double).angleAxis(PI*0.5, armos.math.Vector3d(0, 0, 1));
	auto qSlerped = qBegin.slerp(qEnd, 2.0);
	auto vR = qSlerped.rotatedVector(v);
	auto vA = armos.math.Vector3d(-1, 0, 0);

	foreach (int i, value; vR.data) {
		assert( approxEqual(value, vA[i]) );
	}

}

alias Quaternion!(float) Quaternionf;
alias Quaternion!(double) Quaterniond;
