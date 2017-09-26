module armos.math.quaternion;
import armos.math;
import std.math;
/++
クオータニオンを表すstructです．
+/
struct Quaternion(T)if(__traits(isArithmetic, T)){
    alias Quaternion!(T) Q;
    alias V4 = armos.math.Vector!(T, 4);
    alias V3 = armos.math.Vector!(T, 3);

    /// vec[0];x
    /// vec[1];y
    /// vec[2];z
    /// vec[3];w
    V4 vec = V4();

    /++
    +/
    this(in T x, in T y, in T z, in T w){
        vec[0] = x;
        vec[1] = y;
        vec[2] = z;
        vec[3] = w;
    }
    unittest{
        alias N = double;
        alias Q = Quaternion!N;
        assert(__traits(compiles, { Q q = Q(N(1), N(2), N(3), N(4)); }));
    }
    unittest{
        assert(__traits(compiles, { auto q = Quaternion!(int)(0, 0, 0, 1); }));
    }


    /++
    +/
    this(in T s, in V3 v){
        vec[0] = v[0];
        vec[1] = v[1];
        vec[2] = v[2];
        vec[3] = s;
    }
    unittest{
        alias T = double;
        alias Q = Quaternion!T;
        alias V3 = Vector!(T, 3);
        assert(__traits(compiles, {
                    Q q = Q(T(1), V3(2, 3, 4));
                    }));
    }

    /++
    +/
    this(in V3 v){
        this(T(1), v);
    }
    unittest{
        alias T = double;
        alias Q = Quaternion!T;
        alias V3 = Vector!(T, 3);
        assert(__traits(compiles, {
                    Q q = Q(V3(2, 3, 4));
                    }));
    }

    /++
    +/
    this(in V4 v){
        vec[0] = v[0];
        vec[1] = v[1];
        vec[2] = v[2];
        vec[3] = v[3];
    }
    unittest{
        alias T = double;
        alias Q = Quaternion!T;
        alias V4 = Vector!(T, 4);
        assert(__traits(compiles, {
                    Q q = Q(V4(1, 2, 3, 4));
                    }));
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
        return Q(T( 0 ), T( 0 ), T( 0 ), T( 1 ));
    }
    unittest{
        auto e = Quaternion!(double).unit;
        assert(e[0]==0);
        assert(e[1]==0);
        assert(e[2]==0);
        assert(e[3]==1);
    }

    /++
    +/
    Q opMul(in Q r_quat)const{
        immutable T s_l  = this[3];
        immutable v_l = V3(this[0], this[1], this[2]);

        immutable T s_r  = r_quat[3];
        immutable v_r = V3(r_quat[0], r_quat[1], r_quat[2],);

        immutable return_v = s_l*v_r + s_r*v_l + v_l.vectorProduct(v_r) ;
        immutable return_s = ( s_l*s_r ) - ( v_l.dotProduct(v_r) );
        return Q(return_v[0], return_v[1], return_v[2], return_s);
    }
    unittest{
        Quaternion!(double) q1      = Quaternion!(double)(0, 0, 0, 1);
        Quaternion!(double) q2      = Quaternion!(double)(0, 0, 0, 1);
        Quaternion!(double) qAnswer = Quaternion!(double)(0, 0, 0, 1);
        assert(q1*q2 == qAnswer);
    }
    unittest{
        auto va = Vector!(double, 3)(0.5, 0.1, 0.4);
        auto v = va.normalized;

        Quaternion!(double) q1      = Quaternion!(double)(v[0]*sin(0.1), v[1]*sin(0.1), v[2]*sin(0.1), cos(0.1));
        Quaternion!(double) q2      = Quaternion!(double)(v[0]*sin(0.2), v[1]*sin(0.2), v[2]*sin(0.2), cos(0.2));
        Quaternion!(double) qResult = q1 * q2;
        Quaternion!(double) qAnswer = Quaternion!(double)(v[0]*sin(0.3), v[1]*sin(0.3), v[2]*sin(0.3), cos(0.3));
        foreach (int i, value; qResult.vec.elements) {
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

    ///
    CastedType opCast(CastedType: Quaternion!T, T)()const{
        import std.conv:to;
        return CastedType(this.vec.to!(typeof(CastedType.vec)));
    }

    unittest{ 
        import std.conv:to;
        Quaternion!int iq = Quaternion!double.zero.to!(Quaternion!int); 
        import std.conv:to;
        Quaternion!double dq = Quaternion!int.zero.to!(Quaternion!double); 
    }

    ///
    CastedType opCast(CastedType: Matrix!(E, 4, 4), E)()const{
        import std.conv:to;
        return matrix44!E;
    }

    unittest{ 
        import std.conv:to;
        auto q = Quaternion!double.unit.to!(Matrix!(float, 4, 4));
        auto m = Matrix!(float, 4, 4).identity;
        assert(q == m);
    }

    ///
    CastedType opCast(CastedType: Matrix!(E, 3, 3), E)()const{
        import std.conv:to;
        return matrix33!E;
    }

    unittest{ 
        import std.conv:to;
        auto q = Quaternion!double.unit.to!(Matrix!(float, 3, 3));
        auto m = Matrix!(float, 3, 3).identity;
        assert(q == m);
    }
    
    /++
        Quaternionのノルムを返します．
    +/
    T norm()()const if(__traits(isFloating, T)){
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
        return Q(-this[0], -this[1], -this[2], this[3]);
    }
    unittest{
        auto q  = Quaternion!(double)(1, 2, 3, 4);
        auto qA = Quaternion!(double)(-1, -2, -3, 4);
        assert(q.conjugate == qA);
    }

    /++

    +/
    Q inverse()()const if(__traits(isFloating, T)){
        return conjugate/(this[0]^^T(2.0) + this[1]^^T(2.0) + this[2]^^T(2.0) + this[3]^^T(2.0));
    }
    unittest{
        auto q  = Quaternion!(double)(0, 1, 0, 1);
        auto qR = q.inverse;
        auto qA = Quaternion!(double)(0, -0.5, 0, 0.5);

        foreach (int i, value; qR.vec.elements) {
            assert( approxEqual(value, qA[i]) );
        }
    }

    /++
        自身の回転行列(4x4)を返します．
    +/
    armos.math.Matrix!(E, 4, 4) matrix44(E = T)()const if(__traits(isFloating, E)){
        return armos.math.Matrix!(E, 4, 4)(
                [this[3]^^2.0+this[0]^^2.0-this[1]^^2.0-this[2]^^2.0, 2.0*(this[0]*this[1]-this[3]*this[2]),               2.0*(this[0]*this[2]+this[3]*this[1]),               0],
                [2.0*(this[0]*this[1]+this[3]*this[2]),               this[3]^^2.0-this[0]^^2.0+this[1]^^2.0-this[2]^^2.0, 2.0*(this[1]*this[2]-this[3]*this[0]),               0],
                [2.0*(this[0]*this[2]-this[3]*this[1]),               2.0*(this[1]*this[2]+this[3]*this[0]),               this[3]^^2.0-this[0]^^2.0-this[1]^^2.0+this[2]^^2.0, 0],
                [0,                                                   0,                                                   0,                                                   1]
                );
    }
    unittest{
    }

    /++
        自身の回転行列(3x3)を返します．
    +/
    armos.math.Matrix!(E, 3, 3) matrix33(E = T)()const if(__traits(isFloating, E)){
        return armos.math.Matrix!(E, 3, 3)(
                [this[3]^^2.0+this[0]^^2.0-this[1]^^2.0-this[2]^^2.0, 2.0*(this[0]*this[1]-this[3]*this[2]),               2.0*(this[0]*this[2]+this[3]*this[1])              ],
                [2.0*(this[0]*this[1]+this[3]*this[2]),               this[3]^^2.0-this[0]^^2.0+this[1]^^2.0-this[2]^^2.0, 2.0*(this[1]*this[2]-this[3]*this[0])              ],
                [2.0*(this[0]*this[2]-this[3]*this[1]),               2.0*(this[1]*this[2]+this[3]*this[0]),               this[3]^^2.0-this[0]^^2.0-this[1]^^2.0+this[2]^^2.0]
                );
    }

    /++
        指定したベクトルを自身で回転させたベクトルを返します．
    +/
    V3 rotatedVector()(in V3 vec)const if(__traits(isFloating, T)){
        if( norm^^2.0 < T.epsilon){
            return vec;
        }else{
            auto temp_quat = Q(vec);
            auto return_quat= this*temp_quat*this.inverse;
            auto return_vector = V3(return_quat[0], return_quat[1], return_quat[2]);
            return return_vector;
        }
    }
    unittest{
        auto v = armos.math.Vector3d(1, 0, 0);
        double ang = PI*0.5*0.5;
        auto q  = Quaternion!(double)(0*sin(ang), 0*sin(ang), 1*sin(ang), cos(ang));
        auto vR = q.rotatedVector(v);
        auto vA = armos.math.Vector3d(0, 1, 0);

        foreach (int i, value; vR.elements) {
            assert( approxEqual(value, vA[i]) );
        }
    }

    /++
        指定したベクトルを自身の逆方向に回転させたベクトルを返します．
    +/
    V3 rotatedVectorInversely()(in V3 vec)const if(__traits(isFloating, T)){
        if( norm^^2.0 < T.epsilon){
            return vec;
        }else{
            auto temp_quat = Q(vec);
            auto return_quat= this.inverse*temp_quat*this;
            auto return_vector = V3(return_quat[0], return_quat[1], return_quat[2]);
            return return_vector;
        }
    }
    unittest{
        auto v = armos.math.Vector3d(1, 0, 0);
        double ang = PI*0.5*0.5;
        auto q  = Quaternion!(double)(0*sin(ang), 0*sin(ang), 1*sin(ang), cos(ang));
        auto vR = q.rotatedVectorInversely(v);
        auto vA = armos.math.Vector3d(0, -1, 0);

        foreach (int i, value; vR.elements) {
            assert( approxEqual(value, vA[i]) );
        }
    }

    /++
        指定した軸で自身を回転させます．
        Params:
        ang = 回転角
        axis = 回転軸
    +/
    static Q angleAxis()(T ang, V3 axis) if(__traits(isFloating, T)){
        immutable halfAngle = ang*T(0.5);
        return Q(axis[0]*sin(halfAngle), axis[1]*sin(halfAngle), axis[2]*sin(halfAngle), cos(halfAngle));
    }
    unittest{
        auto v = armos.math.Vector3d(1, 0, 0);
        auto q = Quaternion!(double).angleAxis(PI*0.5, armos.math.Vector3d(0, 0, 1));
        auto vR = q.rotatedVector(v);
        auto vA = armos.math.Vector3d(0, 1, 0);

        foreach (int i, value; vR.elements) {
            assert( approxEqual(value, vA[i]) );
        }
    }

    Q productAngle()(T gain) if(__traits(isFloating, T)){
        return slerp(Q.zero, this, gain);
    }

}

/// 回転の差分のQuaternionを返します．
Q rotationDifference(Q)(in Q from,  in Q to){
    return from.inverse * to;
}
unittest{
    auto qBegin= Quaternion!(double).angleAxis(PI*0.2, armos.math.Vector3d(0, 0, 1));
    auto qEnd = Quaternion!(double).angleAxis(PI*0.5, armos.math.Vector3d(0, 0, 1));
    
    auto qAns = Quaternion!(double).angleAxis(PI*0.3, armos.math.Vector3d(0, 0, 1));
    auto qResult = rotationDifference(qBegin, qEnd);
    
    assert(approxEqual(qResult[0], qAns[0]));
    assert(approxEqual(qResult[1], qAns[1]));
    assert(approxEqual(qResult[2], qAns[2]));
    assert(approxEqual(qResult[3], qAns[3]));
}

/++
球面線形補間(Sphercal Linear Interpolation)を行います．
Params:
from = tが0の時のQuaternion
to = tが1の時のQuaternion
t = 
+/
Q slerp(Q, T)(in Q from, in Q to,  T t)if(__traits(isFloating, typeof(Q.vec[0]))){
    T omega, cos_omega, sin_omega, scale_from, scale_to;

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

    foreach (int i, value; vR.elements) {
        assert( approxEqual(value, vA[i]) );
    }

}

alias Quaternion!(float) Quaternionf;
alias Quaternion!(double) Quaterniond;
