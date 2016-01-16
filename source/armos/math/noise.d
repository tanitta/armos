module armos.math.noise;
import std.random;
import armos.math;

template perlinNoise(Args ...){
	alias T = Args[0];
	const int Dim = Args.length;

	T perlinNoise(in Args args){
		const center = armos.math.Vector!(Args[0], Dim)(args)%T(1);
		const hypercubeVertices = hypercube!(T, Dim);
		import std.algorithm;
		import std.array;
		const toCenter = hypercubeVertices.map!(x => center-x).array;
		const faded = center.fade!(T, Dim);
		// T[2^^Dim] hashedVertices = ;
		return lerp!(T, Dim)(faded, hypercubeVertices);
		// return args[0];
	}


}
static unittest{
	// static assert(perlinNoise(0, 0, 0) == 0);
}

private{
	armos.math.Vector!(T, Dim)[] hash(T, int Dim)(){
		
	}
	
	armos.math.Vector!(T, Dim)[] hypercube(T, int Dim)(){
		armos.math.Vector!(T, Dim)[] hypercubeR(T, int Dim)(in ulong verticesIndex){
			if(verticesIndex<2^^Dim){
				import std.conv:to;
				import std.array:split;
				import std.format:format;
				import std.algorithm.mutation:foo = reverse;
				T[] array = format("%." ~ Dim.to!string ~ "b", verticesIndex).split("").to!(T[]).reverseArray(Dim);
				auto v = armos.math.Vector!(T, Dim)(array);
				return v ~ hypercubeR!(T, Dim)(verticesIndex + 1);
			}else{
				armos.math.Vector!(T, Dim)[] array;
				return array;
			}
		}

		return hypercubeR!(T, Dim)(0);
	}
	static unittest{
		import std.stdio;
		auto array = hypercube!(int, 3);
		array.writeln;
	}
	// armos.math.Vector!(T, Dim) bitarrayToVector(T, int Dim)(BitArray bitArray){
	// 	index
	// }
	T[] reverseArray(T)(T[] array, in int index){
		if(index > 1){
			return reverseArray(array[1..$], index-1) ~  array[0] ;
		}else{
			return array;
		}
	}
	// static unittest{
	// 	import std.stdio;
	// 	double[] array = [0, 1, 2, 3, 4];
	// 	array.reverseArray(5).writeln;
	// }

	armos.math.Vector!(T, Dim) fade(T, int Dim)(in armos.math.Vector!(T, Dim) t){
		return t * t * t * (t * (t * T(6) - T(15)) + T(10));
	}

	T lerpR(T, int Dim)(
		in armos.math.Vector!(T, Dim) f,
		in armos.math.Vector!(T, Dim)[] hypercubeVertices,
		in int dim
	){
		if(dim > 1){
			const T a_tmp = lerpR!(T, Dim)(f,hypercubeVertices[0..2^^(dim - 1)-1], dim-1);
			const T b_tmp = lerpR!(T, Dim)(f,hypercubeVertices[2^^(dim - 1)..$], dim-1);
			return a_tmp + f[dim-1] * (b_tmp - a_tmp);
		}else{
			//grad
			return 1;
		}
		
	}
	
	T lerp(T, int Dim)(
		in armos.math.Vector!(T, Dim) f,
		in armos.math.Vector!(T, Dim)[] hypercubeVertices
	){
		return lerpR!(T, Dim)(f, hypercubeVertices, Dim);
	}

	T grad(T, int Dim)(T, armos.math.Vector!(T, Dim) vec){
		return 0;
	}


	static immutable char[512] permutationTable = [151,160,137,91,90,15,
					 131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
					 190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
					 88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
					 77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
					 102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
					 135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
					 5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
					 223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
					 129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
					 251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
					 49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
					 138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180,
					 151,160,137,91,90,15,
					 131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
					 190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
					 88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
					 77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
					 102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
					 135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
					 5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
					 223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
					 129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
					 251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
					 49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
					 138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180 
						 ];
}

// #define FASTFLOOR(x) ( ((x)>0) ? ((int)x) : (((int)x)-1) )
