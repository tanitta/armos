module armos.math.noise;
import std.random;
import armos.math;

/++
ノイズを生成します．
+/
struct PerlinNoise(T, int Dim) {
    private{
        alias V = Vector!(T, Dim);
        alias Vi = Vector!(int, Dim);
        import std.math:sqrt;
        import std.conv:to;
        enum R = sqrt(1f/Dim.to!T);
    }
    public{
        ///
        T eval(T[] args ...){
            import std.conv;
            V localCoord;
            localCoord.elements = args;
            _vi = (localCoord.to!Vi%T(255));
            _vf = localCoord - localCoord.to!Vi.to!V;
            _faded = _vf.fade;
            // return (lerp()+T(1))*T(0.5);
            return lerp();
        }
    }//public

    private{
        int[] _permutationTable = defaultPermutationTable ~ defaultPermutationTable;
        float _repeat = 1f;
        
        Vi _vi;
        V _vf;
        V _faded;
        
        T lerp(T)(in T a, in T b, in T x)const{
            return a+x*(b-a);
        }
        
        T lerp()const{
            return lerpR!(Dim-1, hypercubeVertices!(T, Dim));
        }
        
        T lerpR(int currentDim, V[] HyperCubeVertices)()const{
            static if(currentDim == 0){
                import std.conv;
                return lerp(
                    grad((_vi+HyperCubeVertices[0].to!Vi).hash(_permutationTable), _vf-HyperCubeVertices[0]),
                    grad((_vi+HyperCubeVertices[1].to!Vi).hash(_permutationTable), _vf-HyperCubeVertices[1]),
                    _faded[currentDim]
                );
            }else{
                return lerp(
                    lerpR!(currentDim-1, HyperCubeVertices[0..$/2]), 
                    lerpR!(currentDim-1, HyperCubeVertices[$/2..$]), 
                    _faded[currentDim]
                );
            }
        }
    }//private
}//struct PerlinNoise

private{
    int hash(Vi:Vector!(int, Dim), int Dim)(in Vi vi, in int[] permutationTable){
        return hashR!(Vi, Dim, Dim-1)(vi, permutationTable);
    }
    
    int hashR(Vi:Vector!(int, Dim), int Dim, int currentDim)(in Vi vi, in int[] permutationTable){
        static if(currentDim == 0){
            return permutationTable[vi[0]];
        }else{
            return permutationTable[hashR!(Vi, Dim, currentDim-1)(vi, permutationTable)+vi[currentDim]];
        }
    }
    
    V fade(V:Vector!(T, Dim), T, int Dim)(in V t){
        return t * t * t * (t * (t * T(6) - T(15)) + T(10));
    }
    
    

    T grad(V:Vector!(T, Dim), T, int Dim: 1)(in int hash, in V vec){
        int h = hash & 0xF;
        T g= T(1) + (h & 7);
        if(h&8) g =- g;
        return g * vec.x;
    }
    
    T grad(V:Vector!(T, Dim), T, int Dim: 2)(in int hash, in V vec){
        int h = hash & 0x7;
        T u = h<4 ? vec.x : vec.y;
        T v = h<4 ? vec.y : vec.x;
        return ((h&1)? -u : u) + ((h&2)? -2.0f*v : 2.0f*v);
    }
    
    T grad(V:Vector!(T, Dim), T, int Dim: 3)(in int hash, in V vec){
        int h = hash & 0xF;
        T u = h<8 ? vec.x : vec.y;
        T v = h<4 ? vec.y : h==12||h==14 ? vec.x : vec.z;
        return ((h&1)? -u : u) + ((h&2)? -v : v);
    }
    
    T grad(V:Vector!(T, Dim), T, int Dim: 4)(in int hash, in V vec){
        int h = hash & 0x1F;
        T u = h<24 ? vec.x : vec.y;
        T v = h<16 ? vec.y : vec.z;
        T w = h<8 ? vec.z : vec.w;
        return ((h&1)? -u : u) + ((h&2)? -v : v) + ((h&4)? -w : w);
    }
    
    armos.math.Vector!(T, Dim)[] hypercubeVertices(T, int Dim)(){
        armos.math.Vector!(T, Dim)[] hypercubeVerticesR(T, int Dim)(in ulong verticesIndex){
            if(verticesIndex<2^^Dim){
                import std.conv:to;
                import std.array:split;
                import std.format:format;
                import std.algorithm.mutation:foo = reverse;
                T[] array = format("%." ~ Dim.to!string ~ "b", verticesIndex).split("").to!(T[]).reverseArray(Dim);
                auto v = armos.math.Vector!(T, Dim)(array);
                return v ~ hypercubeVerticesR!(T, Dim)(verticesIndex + 1);
            }else{
                armos.math.Vector!(T, Dim)[] array;
                return array;
            }
        }

        return hypercubeVerticesR!(T, Dim)(0);
    }
    
    static unittest{
        import std.stdio;
        alias V = Vector3i;
        assert(hypercubeVertices!(int, 3) == [
            V(0, 0, 0), 
            V(1, 0, 0), 
            V(0, 1, 0), 
            V(1, 1, 0), 
            V(0, 0, 1), 
            V(1, 0, 1), 
            V(0, 1, 1), 
            V(1, 1, 1), 
        ]);
    }
    
    T[] reverseArray(T)(T[] array, in int index){
        if(index > 1){
            return reverseArray(array[1..$], index-1) ~  array[0] ;
        }else{
            return array;
        }
    }

    static immutable int[] defaultPermutationTable = [
        151, 160, 137, 91,  90,  15,  131, 13,  201, 95,  96,  53,  194, 233, 7,   225,
        140, 36,  103, 30,  69,  142, 8,   99,  37,  240, 21,  10,  23,  190, 6,   148,
        247, 120, 234, 75,  0,   26,  197, 62,  94,  252, 219, 203, 117, 35,  11,  32,
        57,  177, 33,  88,  237, 149, 56,  87,  174, 20,  125, 136, 171, 168, 68,  175,
        74,  165, 71,  134, 139, 48,  27,  166, 77,  146, 158, 231, 83,  111, 229, 122,
        60,  211, 133, 230, 220, 105, 92,  41,  55,  46,  245, 40,  244, 102, 143, 54,
        65,  25,  63,  161, 1,   216, 80,  73,  209, 76,  132, 187, 208, 89,  18,  169,
        200, 196, 135, 130, 116, 188, 159, 86,  164, 100, 109, 198, 173, 186, 3,   64,
        52,  217, 226, 250, 124, 123, 5,   202, 38,  147, 118, 126, 255, 82,  85,  212,
        207, 206, 59,  227, 47,  16,  58,  17,  182, 189, 28,  42,  223, 183, 170, 213,
        119, 248, 152, 2,   44,  154, 163, 70,  221, 153, 101, 155, 167, 43,  172, 9,
        129, 22,  39,  253, 19,  98,  108, 110, 79,  113, 224, 232, 178, 185, 112, 104,
        218, 246, 97,  228, 251, 34,  242, 193, 238, 210, 144, 12,  191, 179, 162, 241,
        81,  51,  145, 235, 249, 14,  239, 107, 49,  192, 214, 31,  181, 199, 106, 157,
        184, 84,  204, 176, 115, 121, 50,  45,  127, 4,   150, 254, 138, 236, 205, 93,
        222, 114, 67,  29,  24,  72,  243, 141, 128, 195, 78,  66,  215, 61,  156, 180,
    ];
}

// #define FASTFLOOR(x) ( ((x)>0) ? ((int)x) : (((int)x)-1) )
