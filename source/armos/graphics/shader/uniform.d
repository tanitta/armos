module armos.graphics.shader.uniform;

import derelict.opengl3.gl;

import armos.graphics.shader;
import armos.math.vector;
import armos.math.matrix;
import armos.graphics.shader.utils;

import std.variant;
import std.meta;
alias GlArithmeticTypes = AliasSeq!(uint, int, float);
alias GlVectorTypes     = AliasSeq!(uint[1], int[1], float[1],
                                    uint[2], int[2], float[2],
                                    uint[3], int[3], float[3],
                                    uint[4], int[4], float[4]);
alias GlMatrixTypes     = AliasSeq!(float[2][2], float[3][3], float[4][4],
                                    float[2][3], float[3][2],
                                    float[2][4], float[4][2],
                                    float[3][4], float[4][3]);
alias AcceptableUniformTypes = AliasSeq!(GlArithmeticTypes, GlVectorTypes, GlMatrixTypes);
alias Uniform = Algebraic!(AcceptableUniformTypes);
pragma(msg, __FILE__, "(", __LINE__, "): ",
       "TODO: build into material");

///
template isInherentingIn(T, Ts...) {
    enum bool isInherentingIn = staticIndexOf!(T, Ts) != -1;
}//template isInherentingIn

unittest{
    assert(isInherentingIn!(uint, GlArithmeticTypes));
    assert(!isInherentingIn!(string, GlArithmeticTypes));
}

Shader uniform(Shader shader, in string name, Uniform uniform){
    static foreach (T; AcceptableUniformTypes) {
        if(uniform.type == typeid(T)){
            shader.uniform(name, uniform.get!T);
            return shader;
        }
    }
    assert(false);
}

unittest{
    assert(__traits(compiles, (){
        Shader shader;
        Uniform u;
        u = 1f;
        shader.uniform("foo", u);
    }));

    assert(!__traits(compiles, (){
        Shader shader;
        Uniform u;
        u = "string";
        shader.uniform("foo", u);
    }));
}

/++
    Set vector to uniform.
    example:
    ----
    auto v = ar.Vector!(float, 3)(1.0, 2.0, 3.0);
shader.setUniform("v", v);
----
+/
Shader uniform(V)(Shader shader, in string name, V v)
if(isVector!(V) && V.dimention <= 4){
    shader.uniform(name, v.array);
    return shader;
}
unittest{
    assert(__traits(compiles, (){
        Shader shader;
        shader.uniform("foo", Vector4f.zero);
    }));
}

/++
    Set matrix to uniform.
    example:
    ----
    auto m = ar.Matrix!(float, 3, 3)(
            [0, 0, 0], 
            [0, 0, 0], 
            [0, 0, 0], 
            );
shader.setUniform("m", m);
----
+/
Shader uniform(M)(Shader shader, in string name, M m)
if(isMatrix!(M)){
    shader.uniform(name, m.array!2);
    return shader;
}
unittest{
    assert(__traits(compiles, (){
        Shader shader;
        shader.uniform("foo", Matrix4f.identity);
    }));
}

/++
    Set as an uniform.
    example:
    ----
    // Set variables to glsl uniform named "v".
    float a = 1.0;
    float b = 2.0;
    float c = 3.0;
    shader.setUniform("v", a, b, c);
    ----
+/
Shader uniform(T)(Shader shader, in string name, T[] v...)if(isInherentingIn!(T, GlArithmeticTypes)){
    if(shader.isLoaded){
        shader.begin;
        int location = shader.uniformLocation(name);
        if(location != -1){
            import std.conv:to;
            mixin(glFunctionString!(T[]).array("glUniform"));
        }
        shader.end;
    }
    return shader;
}

unittest{
    assert(__traits(compiles, (){
        Shader shader;
        shader.uniform("foo", 1f);
    }));
}

unittest{
    assert(__traits(compiles, (){
        Shader shader;
        shader.uniform("foo", [1f, 2f, 3f, 4f]);
    }));
}

unittest{
    assert(__traits(compiles, (){
        Shader shader;
        float[4] arr = [1f, 2f, 3f, 4f];
        shader.uniform("foo", arr);
    }));
}


/// GlMatrixTypes
Shader uniform(Arg:T[ColSize][RowSize], T, size_t ColSize, size_t RowSize)(Shader shader, in string name, Arg m)if(isInherentingIn!(Arg, GlMatrixTypes)){
    if(shader.isLoaded){
        shader.begin;
        int location = shader.uniformLocation(name);
        if(location != -1){
            T[RowSize*ColSize] arr;
            foreach (size_t rIndex, row; m) {
                foreach(size_t cIndex, elem; row){
                    arr[rIndex*ColSize+cIndex] = elem;
                }
            }
            mixin( glFunctionString!(T[], RowSize, ColSize).name("glUniform") ~ "(location, 1, GL_FALSE, arr.ptr);" );
        }
        shader.end;
    }
    return shader;
}
unittest{
    assert(__traits(compiles, (){
        Shader shader;
        float[3][3] arr;
        shader.uniform("foo", arr);
    }));
}

/// GlMatrixTypes
// Shader uniformArray(Arg:T[][])(Shader shader, in string name, Arg m)if(isInherentingIn!(Arg, GlArithmeticTypes)){
//     if(shader.isLoaded){
//         shader.begin;
//         int location = shader.uniformLocation(name);
//         if(location != -1){
//             T[] arr;
//             foreach (size_t rIndex, row; m) {
//                 foreach(size_t cIndex, elem; row){
//                     arr[rIndex*row.length+cIndex] = elem;
//                 }
//             }
//             mixin( glFunctionString!(T[], RowSize, ColSize).name("glUniform") ~ "(location, 1, GL_FALSE, arr.ptr);" );
//         }
//         shader.end;
//     }
//     return shader;
// }

import armos.graphics.texture;
/++
+/
Shader uniformTexture(Shader shader, in string name, Texture texture, int textureLocation){
    import std.string;
    if(shader.isLoaded){
        shader.begin;scope(exit)shader.end;
        glActiveTexture(GL_TEXTURE0 + textureLocation);
        texture.begin;
        shader.uniform(name, textureLocation);
    }
    return shader;
}
unittest{
    assert(__traits(compiles, (){
        Shader shader;
        Texture texture;
        shader.uniformTexture("foo", texture, 0);
    }));
}
