module armos.math.vector;
import armos.math;
import core.vararg;
import std.math;
import std.stdio;

version(D_SIMD) {
    import core.simd;
    enum SIMD_Enable = true;
}
else {
    enum SIMD_Enable = false;
}

/++
ベクトル計算を行うstructです
+/
struct Vector(T, int Dimention)if(__traits(isArithmetic, T) && Dimention > 0){
    private alias Vector!(T, Dimention) VectorType;

    enum XMMRegisterSize = 16;
    enum PackSize = XMMRegisterSize / T.sizeof;
    enum XMMsNum = Dimention % PackSize == 1 || Dimention % PackSize == 0 ?
        Dimention / PackSize :
        Dimention / PackSize + 1;
    enum XMMsSize = XMMsNum * PackSize;

    union PackedElements{
        T[Dimention] arr;
        static if (!is(T == real) && Dimention > 1) {
            static if (XMMsNum == 1){
                __vector(T[PackSize]) vec;
            }
            else {
                __vector(T[PackSize])[XMMsNum] vec;
            }
        }
    }


    private template Compute (string Base) {
        import std.format : format;
        static if (Dimention > 1) {
            enum XMMComputeBase = format("if(__ctfe){%s}else{%%s}",format(Base,"arr[]"));
            static if (XMMsNum == 1) {
                enum ComputeXMM = format(Base,"vec");
            }
            else {
                enum ComputeXMM = expandFor!(format(Base,"vec[%1$d]"),XMMsNum);
            }
            static if (Dimention <= XMMsSize) {
                enum Compute = format(XMMComputeBase,ComputeXMM);
            }
            else static if (Dimention == XMMsSize + 1) {
                enum Compute = format(XMMComputeBase,ComputeXMM ~ format(Base,"arr[$-1]"));
            }
            else {
                static assert (false,"illegal PackedElements!");
            }
        }
        else {
            enum Compute = format(Base,"arr[0]");
        }
    }
    unittest {
        static assert(Vector!(int,3).Compute!("x.%1$s+y.%1$s;") == "if(__ctfe){x.arr[]+y.arr[];}else{x.vec+y.vec;}");
        static assert(Vector!(int,4).Compute!("x.%1$s+y.%1$s;") == "if(__ctfe){x.arr[]+y.arr[];}else{x.vec+y.vec;}");
        static assert(Vector!(int,5).Compute!("x.%1$s+y.%1$s;") == "if(__ctfe){x.arr[]+y.arr[];}else{x.vec+y.vec;x.arr[$-1]+y.arr[$-1];}");
        static assert(Vector!(int,6).Compute!("x.%1$s+y.%1$s;") == "if(__ctfe){x.arr[]+y.arr[];}else{x.vec[0]+y.vec[0];x.vec[1]+y.vec[1];}");
        static assert(Vector!(int,9).Compute!("x.%1$s+y.%1$s;") == "if(__ctfe){x.arr[]+y.arr[];}else{x.vec[0]+y.vec[0];x.vec[1]+y.vec[1];x.arr[$-1]+y.arr[$-1];}");
    }
    unittest {
    }

    PackedElements packedElements;
        
    // T[Dimention] elements = packedElements.arr[];
    ref T[Dimention] elements()const{
        return packedElements.arr[];
    }

    //T[Dimention] packedElements = T.init;
    ///
    enum int dimention = Dimention;
    unittest{
        static assert(Vector!(float, 3).dimention == 3);
    }

    alias elementType = T;
    unittest{
        static assert(is(Vector!(float, 3).elementType == float));
    }

    enum string coordNames = "xyzw";

    static if (Dimention <= coordNames.length){
        enum string coordName = coordNames[0..Dimention];
    }else{
        enum string coordName = "";
    }
    unittest{
        static assert(Vector!(float,3).coordName == "xyz");
    }

    ///
    static VectorType array(Arr:E[], E)(Arr arr){
        VectorType v;
        import std.conv;
        v.packedElements.arr = arr.to!(T[]);
        return v; 
    }

    unittest{
        float[] array = [1, 2];
        auto v = Vector2f.array(array);
        assert(v[0] == array[0]);
        assert(v[1] == array[1]);
    }

    unittest{
        float[2] array = [1, 2];
        auto v = Vector2f.array(array);
        assert(v[0] == array[0]);
        assert(v[1] == array[1]);
    }

    unittest{
        auto v = Vector2f.array([1, 2]);
        assert(v[0] == 1f);
        assert(v[1] == 2f);
    }

    /++
        Vectorのinitializerです．引数はDimentionと同じ個数の要素を取ります．
    +/
    this(T[] arr ...)in{
        assert(arr.length == 0 || arr.length == Dimention);
    }body{
            if(arr.length != 0){
                packedElements.arr = arr;
            }
        }


    /++
    +/
    pure T opIndex(in size_t index)const{
        return packedElements.arr[index];
    }

    /++
    +/
    ref T opIndex(in size_t index){
        return packedElements.arr[index];
    }
    unittest{
        auto vec = Vector3d(1, 2, 3);
        assert(vec[0] == 1.0);
        assert(vec[1] == 2.0);
        assert(vec[2] == 3.0);
    }

    // pure const bool opEquals(Object vec){
    //  foreach (int index, T v; (cast(VectorType)vec).packedElements.arr) {
    //      if(v != this.packedElements.arr[index]){
    //          return false;
    //      }
    //  }
    //  return true;
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
    enum VectorType zero = (){
        VectorType v;
        v.packedElements.arr[] = T(0);
        return v;
    }();
    unittest{
        auto vec = Vector3d.zero;
        assert(vec[0] == 0);
        assert(vec[1] == 0);
        assert(vec[2] == 0);
    }

    /++
    +/
    VectorType opNeg()const{
        auto result = VectorType();
        static if (SIMD_Enable && !is(T == real))
            mixin(Compute!("result.packedElements.%1$s = -packedElements.%1$s;"));
        else
            result.packedElements.arr[] = -packedElements.arr[];
        return result;
    };
    unittest{
        auto vec1 = Vector3d();
        vec1[0] = 1.5;
        assert(vec1[0] == 1.5);
        assert((-vec1)[0] == -1.5);
    }

    /++
    +/
    VectorType opAdd(in VectorType r)const{
        auto result = VectorType();
        static if (SIMD_Enable && !is(T == real))
            mixin(Compute!("result.packedElements.%1$s = packedElements.%1$s + r.packedElements.%1$s;"));
        else
            result.packedElements.arr[] = packedElements.arr[] + r.packedElements.arr[];
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
    +/
    VectorType opSub(in VectorType r)const{
        auto result = VectorType();
        static if (SIMD_Enable && !is(T == real))
            mixin(Compute!("result.packedElements.%1$s = packedElements.%1$s - r.packedElements.%1$s;"));
        else
            result.packedElements.arr[] = packedElements.arr[] - r.packedElements.arr[];
        return result;
    }
    unittest{
        auto result = Vector3d(3, 2, 1) - Vector3d(1, 2, 3);
        assert(result == Vector3d(2, 0, -2));
    }

    /++
    +/
    VectorType opAdd(in T v)const{
        auto result = VectorType();
        static if (SIMD_Enable && !is(T == real)) {
            PackedElements packedV;
            packedV.arr[] = v;
            mixin(Compute!("result.packedElements.%1$s = packedElements.%1$s + packedV.%1$s;"));
        }
        else
            result.packedElements.arr[] = packedElements.arr[] + v;
        return result;
    }
    unittest{
        auto result = Vector3d(3.0, 2.0, 1.0);
        assert(result+2.0 == Vector3d(5.0, 4.0, 3.0));
        assert(2.0+result == Vector3d(5.0, 4.0, 3.0));
    }

    /++
    +/
    VectorType opSub(in T v)const{
        auto result = VectorType();
        static if (SIMD_Enable && !is(T == real)) {
            PackedElements packedV;
            packedV.arr[] = v;
            mixin(Compute!("result.packedElements.%1$s = packedElements.%1$s - packedV.%1$s;"));
        }
        else
            result.packedElements.arr[] = packedElements.arr[] - v;
        return result;
    }
    unittest{
        auto result = Vector3d(3.0, 2.0, 1.0);
        assert(result-2.0 == Vector3d(1.0, 0.0, -1.0));
    }

    /++
    +/
    VectorType opMul(in T v)const{
        auto result = VectorType();
        static if (SIMD_Enable && (is(T == float) || is(T == double) || is(T == short) || is(T == ushort))) {
            PackedElements packedV;
            packedV.arr[] = v;
            mixin(Compute!("result.packedElements.%1$s = packedElements.%1$s * cast(const)packedV.%1$s;"));
        }
        else
            result.packedElements.arr[] = packedElements.arr[] * v;
        return result;
    }
    unittest{
        auto result = Vector3d(3.0, 2.0, 1.0);
        assert(result*2.0 == Vector3d(6.0, 4.0, 2.0));
        assert(2.0*result == Vector3d(6.0, 4.0, 2.0));
    }

    /++
    +/
    VectorType opDiv(in T v)const{
        auto result = VectorType();
        static if (SIMD_Enable && (is(T == float) || is(T == double))) {
            PackedElements packedV;
            packedV.arr[] = v;
            mixin(Compute!("result.packedElements.%1$s = packedElements.%1$s / packedV.%1$s;"));
        }
        else
            result.packedElements.arr[] = packedElements.arr[] / v;
        return result;
    }
    unittest{
        auto result = Vector3d(3.0, 2.0, 1.0);
        assert(result/2.0 == Vector3d(1.5, 1.0, 0.5));
    }

    /++
    +/
    VectorType opMod(in T v)const{
        auto result = VectorType();
        result.packedElements.arr[] = packedElements.arr[] % v;
        return result;
    }
    unittest{
        auto result = Vector3d(4.0, 2.0, 1.0);
        assert(result%2.0 == Vector3d(0.0, 0.0, 1.0));
    }

    /++
    +/
    VectorType opMul(in VectorType v)const{
        auto result = VectorType();
        static if (SIMD_Enable && (is(T == float) || is(T == double) || is(T == short) || is(T == ushort)))
            mixin(Compute!("result.packedElements.%1$s = packedElements.%1$s * v.packedElements.%1$s;"));
        else
            result.packedElements.arr[] = packedElements.arr[] * v.packedElements.arr[];
        return result;
    }
    unittest{
        auto vec1 = Vector3d(3.0, 2.0, 1.0);
        auto vec2 = Vector3d(2.0, 1.0, 0.0);
        assert(vec1*vec2 == Vector3d(6.0, 2.0, 0.0));
    }

    /++
    +/
    VectorType opDiv(in VectorType v)const{
        auto result = VectorType();
        static if (SIMD_Enable && (is(T == float) || is(T == double)))
            mixin(Compute!("result.packedElements.%1$s = packedElements.%1$s / v.packedElements.%1$s;"));
        else
            result.packedElements.arr[] = packedElements.arr[] / v.packedElements.arr[];
        return result;
    }
    unittest{
        auto vec1 = Vector3d(4.0, 2.0, 1.0);
        auto vec2 = Vector3d(2.0, 1.0, 1.0);
        assert(vec1/vec2 == Vector3d(2.0, 2.0, 1.0));
    }

    /++
    +/
    VectorType opMod(in VectorType v)const{
        auto result = VectorType();
        result.packedElements.arr[] = packedElements.arr[] % v.packedElements.arr[];
        return result;
    }
    unittest{
        auto vec1 = Vector3d(3.0, 2.0, 1.0);
        auto vec2 = Vector3d(2.0, 1.0, 1.0);
        assert(vec1%vec2 == Vector3d(1.0, 0.0, 0.0));
    }

    /++
    +/
    void opAddAssign(in VectorType v){
        static if (SIMD_Enable && !is(T == real))
            mixin(Compute!("packedElements.%1$s += v.packedElements.%1$s;"));
        else
            packedElements.arr[] += v.packedElements.arr[];
    }
    unittest{
        auto vec1 = Vector3d(1.0,2.0,3.0);
        auto vec2 = Vector3d(1.0,1.0,2.0);
        vec1 += vec2;
        assert(vec1 == Vector3d(2.0,3.0,5.0));
    }

    /++
    +/
    void opSubAssign(in VectorType v){
        static if (SIMD_Enable && !is(T == real))
            mixin(Compute!("packedElements.%1$s -= v.packedElements.%1$s;"));
        else
            packedElements.arr[] -= v.packedElements.arr[];
    }
    unittest{
        auto vec1 = Vector3d(5.0,4.0,3.0);
        auto vec2 = Vector3d(3.0,2.0,1.0);
        vec1 -= vec2;
        assert(vec1 == Vector3d(2.0,2.0,2.0));
    }

    /++
    +/
    void opAddAssign(in T v){
        static if (SIMD_Enable && !is(T == real)) {
            PackedElements packedV;
            packedV.arr[] = v;
            mixin(Compute!("packedElements.%1$s += packedV.%1$s;"));
        }
        else
            packedElements.arr[] += v;
    }
    unittest{
        auto vec1 = Vector3d(1.0,2.0,3.0);
        vec1 += 1.0;
        assert(vec1 == Vector3d(2.0,3.0,4.0));
    }

    /++
    +/
    void opSubAssign(in T v){
        static if (SIMD_Enable && !is(T == real)) {
            PackedElements packedV;
            packedV.arr[] = v;
            mixin(Compute!("packedElements.%1$s -= packedV.%1$s;"));
        }
        else
            packedElements.arr[] -= v;
    }
    unittest{
        auto vec1 = Vector3d(2.0,3.0,4.0);
        vec1 -= 3.0;
        assert(vec1 == Vector3d(-1.0,0.0,1.0));
    }

    /++
    +/
    void opModAssign(in T v){
        packedElements.arr[] %= v;
    }
    unittest{
        auto vec1 = Vector3d(4.0,5.0,6.0);
        vec1 %= 3.0;
        assert(vec1 == Vector3d(1.0,2.0,0.0));
    }

    /++
    +/
    void opDivAssign(in T v){
        static if (SIMD_Enable && (is(T == float) || is(T == double))) {
            PackedElements packedV;
            packedV.arr[] = v;
            mixin(Compute!("packedElements.%1$s /= packedV.%1$s;"));
        }
        else
            packedElements.arr[] /= v;
    }
    unittest{
        auto vec1 = Vector3d(3.0,4.0,5.0);
        vec1 /= 2.0;
        assert(vec1 == Vector3d(1.5,2.0,2.5));
    }

    /++
    +/
    void opMulAssign(in T v){
        static if (SIMD_Enable && (is(T == float) && is(T == double) && is(T == short) && is(T == ushort))) {
            PackedElements packedV;
            packedV.arr[] = v;
            mixin(Compute!("packedElements.%1$s *= packedV.%1$s;"));
        }
        else 
            packedElements.arr[] *= v;
    }
    unittest{
        auto vec1 = Vector3d(2.0,-1.0,1.0);
        vec1 *= 3.0;
        assert(vec1 == Vector3d(6.0,-3.0,3.0));
    }

    /++
    +/
    void opModAssign(in VectorType v){
        packedElements.arr[] %= v.packedElements.arr[];
    }
    unittest{
        auto vec1 = Vector3d(3.0,2.0,1.0);
        auto vec2 = Vector3d(2.0,1.0,1.0);
        vec1 %= vec2;
        assert(vec1 == Vector3d(1.0,0.0,0.0));
    }

    /++
    +/
    void opDivAssign(in VectorType v){
        static if (SIMD_Enable && (is(T == double) || is(T == float)))
            mixin(Compute!("packedElements.%1$s /= v.packedElements.%1$s;"));
        else
            packedElements.arr[] /= v.packedElements.arr[];
    }
    unittest{
        auto vec1 = Vector3d(4.0,2.0,1.0);
        auto vec2 = Vector3d(2.0,1.0,1.0);
        vec1 /= vec2;
        assert(vec1 == Vector3d(2.0,2.0,1.0));
    }

    /++
    +/
    void opMulAssign(in VectorType v){
        static if (SIMD_Enable && (is(T == float) || is(T == double) || is(T == short) || is(T == ushort)))
            mixin(Compute!("packedElements.%1$s *= v.packedElements.%1$s;"));
        else
            packedElements.arr[] *= v.packedElements.arr[];
    }
    unittest{
        auto vec1 = Vector3d(3.0,2.0,1.0);
        auto vec2 = Vector3d(2.0,1.0,0.0);
        vec1 *= vec2;
        assert(vec1 == Vector3d(6.0,2.0,0.0));
    }

    /++
        Vectorのノルムを返します．
    +/
    T norm()const{
        import std.numeric : dotProduct;
        immutable T sumsq = dotProduct(packedElements.arr, packedElements.arr);

        static if(__traits(isFloating, T)){
            return sqrt(sumsq);
        }else{
            return cast(T)sqrt(cast(float)sumsq);
        }
    }
    unittest{
        auto result = Vector3d(3.0, 2.0, 1.0);
        assert(result.norm() == ( 3.0^^2.0+2.0^^2.0+1.0^^2.0 )^^0.5);
    }

    /++
        Vectorのドット積を返します．
    +/
    T dotProduct(in VectorType v)const{
        //v1 * v2 = v1.x * v2.x + v1.y * v2.y + v1.z * v2.z ...
        //product = (v1.x * v2.x, v1.y * v2.y, v1.z * v2.z)
        import std.algorithm.iteration : map;
        import std.range : iota,join;
        import std.format : format;
        auto product = this * v;
        //expand to "auto result = product.packedElements.arr[0] + product.packedElements.arr[1] + product.packedElements.arr[2] + ..."
        mixin("return "~Dimention
                        .iota
                        .map!(idx => format("product.packedElements.arr[%d]",idx))
                        .join('+')
                        ~ ";");
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
    +/
    static if (Dimention == 3){
        VectorType vectorProduct(in VectorType v)const{
            return VectorType(
                elements[1]*v[2] - elements[2]*v[1], 
                elements[2]*v[0] - elements[0]*v[2], 
                elements[0]*v[1] - elements[1]*v[0], 
            );
        }
    }

    static if (Dimention > 3){
        VectorType vectorProduct(in VectorType[] arg ...)const in{
            assert(arg.length == Dimention-2);
        }body{
            auto return_vector = VectorType.zero;
            foreach (int i, ref T v; return_vector.packedElements.arr) {
                auto matrix = armos.math.Matrix!(T, Dimention, Dimention)();
                auto element_vector = VectorType.zero;
                element_vector[i] = T(1);
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
    }
    unittest{
        auto vector0 = Vector3f(1, 2, 3);
        auto vector1 = Vector3f(4, 5, 6);
        auto anser = Vector3f(-3, 6, -3);
        assert(vector0.vectorProduct(vector1) == anser);
    }

    /++
        VectorとVectorの成す角を求めます
    +/
    auto angle(in VectorType v)const{
        /+
        v1 * v2 = |v1| * |v2| * cosθ
        θ = acos((v1 * v2) / (|v1| * |v2|))
        |v1| = √(v1.x^2 + v1.y^2 + v1.z^2 ...) = √(v1 * v1)
        norm_product = |v1| * |v2| = √(v1*v1 * v2*v2)
        dotProduct = v1 * v2
        +/
        auto innerProduct = dotProduct(v);
        auto normProduct = dotProduct(this) * v.dotProduct(v);
        static if (__traits(isIntegral,T)) {
            return acos(cast(float)innerProduct / sqrt(cast(float)normProduct));
        }
        else {
            return acos (innerProduct / sqrt(normProduct));
        }
    }
    unittest {
        auto v1 = Vector2i(3,0);
        auto v2 = Vector2i(0,5);
        assert (approxEqual(v1.angle(v2),PI/2));

        auto v3 = Vector3d(1.0 * cos(PI*1/6), 1.0 * sin(PI*1/6),0.0);
        auto v4 = Vector3d(2.0 * cos(PI*5/6), 2.0 * sin(PI*5/6),0.0);
        assert (approxEqual(v3.angle(v4),PI*2/3));

        auto v5 = Vector2i(3,0);
        auto v6 = Vector2i(0,-5);
        assert (approxEqual(v5.angle(v6),PI/2));

        auto v7 = Vector2i(3,0);
        auto v8 = Vector2i(-5,-5);
        assert (approxEqual(v7.angle(v8),PI*3/4));
    }

    /++
        正規化したVectorを返します．
    +/
    VectorType normalized()const{
        return this/this.norm();
    }
    unittest{
        auto vec1 = Vector3d(3.0, 2.0, 1.0);
        assert(vec1.normalized().norm() == 1.0);
    }

    /++
        Vectorを正規化します．
    +/
    void normalize(){
        static if (SIMD_Enable && (is(T == float) || is(T == double))) {
            PackedElements packedNorm;
            packedNorm.arr[] = this.norm();
            mixin(Compute!("this.packedElements.%1$s /= packedNorm.%1$s;"));
        }
        else
            this.packedElements.arr[] /= this.norm();
    }
    unittest{
        auto vec1 = Vector3d(3.0, 2.0, 1.0);
        vec1.normalize();
        assert(vec1.norm() == 1.0);
    }

    /++
        Vectorの要素を一次元配列で返します．
    +/
    T[Dimention] array()const{
        return packedElements.arr;
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
    +/
    string toString()const{
        import std.conv;
        return typeid(this).to!string ~ "(" ~ packedElements.arr.to!string ~ ")";
    }

    /++
        自身を別の型のVectorへキャストしたものを返します．キャスト後の型は元のVectorと同じ次元である必要があります．
    +/
    CastType opCast(CastType)()const if(CastType.dimention == dimention){
        auto vec = CastType();
        foreach (int index, const T var; packedElements.arr) {
            vec.packedElements.arr[index] = cast( typeof( vec.packedElements.arr[0] ) )packedElements.arr[index];
        }
        return vec;
    }

    unittest{
        auto vec_f = Vector3f(2.5, 0, 0);
        auto vec_i = Vector3i(0, 0, 0);

        vec_i = cast(Vector3i)vec_f;

        assert(vec_i[0] == 2);

        //Invalid cast. Different size.
        assert(!__traits(compiles, {
            auto vec_f = Vector2f(2.5, 0);
            auto vec_i = Vector3i(0, 0, 0);
            vec_i = cast(Vector3i)vec_f;
        }));
    }

    /++
        vec.x vec.xyのようにベクトルの一部を切り出すことが出来ます
    +/
    @property auto opDispatch(string swizzle)()const if (swizzle.length > 0 && swizzle.length < coordName.length && coordName.length > 0) {
        import std.string : indexOf,join;
        import std.array : array;
        import std.conv : to;
        import std.algorithm.iteration : map;

        static if (swizzle.length == 1) {
            enum index = coordName.indexOf(swizzle[0]);
            static if (index >= 0){
                return packedElements.arr[index];
            }
        } else {
            enum int[] indecies = swizzle.map!(axis => coordName.indexOf(axis)).array;
            mixin("return Vector!(T,swizzle.length)("~indecies.map!(index => "packedElements.arr["~index.to!string~"]").array.join(',')~");");
        }
    }
    
    /++
    +/
    @property void opDispatch(string swizzle)(in T v) if (swizzle.length == 1 && coordName.length > 0) {
        import std.string : indexOf;
        enum index = coordName.indexOf(swizzle[0]);
        static if (index >= 0) {
            packedElements.arr[index] = v;
        }else{
            static assert (false);
        }
    }

    /++
    +/
    @property void opDispatch(string swizzle,V)(in V v) if (swizzle.length > 0 && swizzle.length < coordName.length && coordName.length > 0 && isVector!V) {
        import std.string : indexOf;
        import std.array : array;
        import std.conv : to;
        import std.range : iota,zip;
        import std.algorithm.iteration : map,reduce;
        import std.traits;
        static if (is(T == Unqual!(typeof(v.packedElements.arr[0])))){
            enum indecies = swizzle.map!(charcter => coordName.indexOf(charcter)).array;
            mixin(swizzle.length.iota
                        .zip(indecies)
                        .map!(pair => "packedElements.arr["~pair[1].to!string~"] = v.packedElements.arr["~pair[0].to!string~"];")
                        .reduce!"a~b"
                        );
         }
    }
}

unittest{
    auto vec = Vector3f(1.0,2.0,3.0);

    assert(vec.x == 1.0);
    assert(vec.z == 3.0);

    assert(vec.xy == Vector2f(1.0,2.0));
    assert(vec.zx == Vector2f(3.0,1.0));

    //static assert (!__traits(compiles, vec.xw));
}

unittest{
    const vec = Vector3f(1.0,2.0,3.0);

    assert(vec.x == 1.0);
    assert(vec.z == 3.0);

    assert(vec.xy == Vector2f(1.0,2.0));
    assert(vec.zx == Vector2f(3.0,1.0));
}

unittest{
    auto vec = Vector3f(1.0,2.0,3.0);
    vec.x = 4.0;
    assert (vec == Vector3f(4.0,2.0,3.0));

    static assert (!__traits(compiles,vec.w = 1.0));
}

unittest{
    auto vec = Vector3f(2.0,4.0,6.0);
    vec.yx = Vector2f(0.0,1.0);
    assert (vec == Vector3f(1.0,0.0,6.0));

    static assert (!__traits(compiles,vec.xw = Vector2f(0.0,0.0)));
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

/++
+/
template isVector(V) {
    public{
        enum bool isVector = __traits(compiles, (){
                static assert(is(V == Vector!(typeof(V()[0]), V.dimention)));
                });
    }//public
}//template isVector
unittest{
    static assert(isVector!(Vector!(float, 3)));
    static assert(!isVector!(float));
}


private template expandFor(string stmt,size_t Limit) {
    import std.algorithm.iteration : map;
    import std.range : iota,repeat,join,zip;
    import std.format : format;
    enum expandFor = Limit
                    .iota
                    .map!(idx => format(stmt,idx))
                    .join;
}
unittest {
    static assert (expandFor!("xs[%1$d] + ys[%1$d];",3) == "xs[0] + ys[0];xs[1] + ys[1];xs[2] + ys[2];");
}
