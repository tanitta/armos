module armos.math.map;
import std.math;
import std.traits;

/++
指定した範囲内に収まる値を返します．
Params:
v = ソースとなる値
min = vの最小値
max = vの最大値
+/
pure T clamp(T)(in T v, in T min, in T max){
    if (v < min) {
        return min;
    }else if(max < v){
        return max;
    }else{
        return v;
    }
}

/++
+/
pure T map(T)(in T v1, in T v1_min, in T v1_max, in T v2_min, in T v2_max, bool isClamp = true){
    T epsilon;
    static if(isIntegral!T){
        epsilon = 0;
    }else{
        epsilon = T.epsilon;
    }
    if(( v1_max - v1_min ).abs <= epsilon){
        return v2_min;
    }else{
        if(isClamp){
            return clamp( (v1 - v1_min) * (v2_max - v2_min) / (v1_max - v1_min) + v2_min, v2_min, v2_max);
        }else{
            return (v1 - v1_min) * (v2_max - v2_min) / (v1_max - v1_min) + v2_min;
        }
    }
}


unittest{
    assert(5.map(0, 10, 10, 20) == 15);
    assert(0.5.map(0.0, 1.0, 1.0, 2.0) == 1.5);
    assert(0.5.clamp(-0.5, 2.0) == 0.5);
    assert((-1.0).clamp(-0.5, 2.0) == -0.5);
    assert((3.0).clamp(-0.5, 2.0) == 2.0);

}
