module armos.math.quaternion;
import armos.math;
class Quaternion(T){
	alias Quaternion!(T) ThisType;
	Vector!(T, 4) vec;
	
	const T opIndex(in int index){
		return vec[index];
	}
	
	ref  T opIndex(in int index){
		return vec[index];
	}

	
	const ThisType opMul(in ThisType r_quat){
		auto v_l = new Vector!(T, 3);
		v_l[0] = this[0];
		v_l[1] = this[1];
		v_l[2] = this[2];
		T s_l = this[3];
		
		auto v_r = new Vector!(T, 3);
		v_r[0] = r_quat[0];
		v_r[1] = r_quat[1];
		v_r[2] = r_quat[2];
		T s_r = r_quat[3];
		
		auto return_vec = s_l*v_r + s_r*v_r;
		
		auto return_quaternion = new ThisType;
		return return_quaternion;
	}
}
