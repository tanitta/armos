module armos.graphics.gl.uniform;

import derelict.opengl3.gl;

import armos.graphics.gl.shader;
import armos.math.vector;
import armos.math.matrix;
import armos.graphics.gl.shaderutils;

import std.variant;
import std.meta;

import armos.graphics.gl.types;

alias AcceptableNumericalUniformTypes = AliasSeq!(GlArithmeticTypes,
                                         GlVectorTypes,
                                         GlMatrixTypes);
alias NumericalUniform = Algebraic!(AcceptableNumericalUniformTypes);

///
template isInherentingIn(T, Ts...) {
    enum bool isInherentingIn = staticIndexOf!(T, Ts) != -1;
}//template isInherentingIn

unittest{
    assert(isInherentingIn!(uint, GlArithmeticTypes));
    assert(!isInherentingIn!(string, GlArithmeticTypes));
}


// Shader uniform(Shader shader, in string name, Uniform uniform){
//     static foreach (T; AcceptableUniformTypes) {
//         if(uniform.type == typeid(T)){
//             shader.uniform(name, uniform.get!T);
//             return shader;
//         }
//     }
//     assert(false);
// }


/++
    Set vector to uniform.
    example:
    ----
    auto v = ar.Vector!(float, 3)(1.0, 2.0, 3.0);
    shader.setUniform("v", v);
    ----
+/

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

/// GlMatrixTypes
// Shader uniform(Arg:T[ColSize][RowSize], T, size_t ColSize, size_t RowSize)(Shader shader, in string name, Arg m)if(isInherentingIn!(Arg, GlMatrixTypes)){
//     if(shader.isLoaded){
//         shader.begin;
//         int location = shader.uniformLocation(name);
//         if(location != -1){
//             T[RowSize*ColSize] arr;
//             foreach (size_t rIndex, row; m) {
//                 foreach(size_t cIndex, elem; row){
//                     arr[rIndex*ColSize+cIndex] = elem;
//                 }
//             }
//             mixin( glFunctionString!(T[], RowSize, ColSize).name("glUniform") ~ "(location, 1, GL_FALSE, arr.ptr);" );
//         }
//         shader.end;
//     }
//     return shader;
// }


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

import armos.graphics.gl.texture;
/// Set texture as uniform.
T uniform(T)(T t, in string name, Texture texture, uint textureLocation){
    t.uniformImpl(name, texture, textureLocation);
    return t;
}
unittest{
    assert(__traits(compiles, (){
        Shader shader;
        Texture texture;
        shader.uniform("foo", texture, 0);
    }));
}

T uniform(T)(T t, in string name, Texture texture){
    t.uniformImpl(name, texture);
    return t;
}

///
template hasUniformImpl(T) {
    enum bool hasUniformImpl = __traits(compiles, (){
        T t;
        NumericalUniform u;
        t.uniformImpl("uniformName", u);
    });
}//template hasUniformImpl

/// Set raw uniform struct.
T uniform(T)(T t, in string name, NumericalUniform u)if(hasUniformImpl!T){
    t.uniformImpl(name, u);
    return t;
}

import std.meta:staticIndexOf;

/// Set acceptable uniform types as uniform.
T uniform(T, U)(T t, in string name, U v)if(hasUniformImpl!T && staticIndexOf!(U, AcceptableNumericalUniformTypes) != -1)
{
    t.uniformImpl(name, NumericalUniform(v));
    return t;
}

unittest{
    assert(__traits(compiles, (){
        Shader shader;
        NumericalUniform u;
        u = 1f;
        shader.uniform("foo", u);
    }));

    assert(__traits(compiles, (){
        Shader shader;
        float[3][3] arr;
        shader.uniform("foo", arr);
    }));

    assert(!__traits(compiles, (){
        Shader shader;
        NumericalUniform u;
        u = "string";
        shader.uniform("foo", u);
    }));
}

/// Set armos.math.Vector.
T uniform(T, V)(T t, in string name, V v)
if(isVector!(V) && V.dimention <= 4){
    t.uniform(name, v.array);
    return t;
}

/// Set armos.math.Matrix.
T uniform(T, M)(T t, in string name, M m)
if(isMatrix!(M)){
    t.uniform(name, m.array!2);
    return t;
}

unittest{
    assert(__traits(compiles, (){
        Shader shader;
        Vector!(float, 3) v;
        shader.uniform("v", v);
    }));

    assert(__traits(compiles, (){
        Shader shader;
        Matrix!(float, 3, 3) m;
        shader.uniform("m", m);
    }));
}

// multi arguments wrapper
// NOTE: Use wrapper of acceptable uniform types to set one argument.

/// Set two arguments as uniform.
T uniform(T, E)(T t, in string name, E e1, E e2)if(isInherentingIn!(E, GlArithmeticTypes)){
    E[2] v  = [e1, e2];
    t.uniform(name, v);
    return t;
}

/// Set three arguments as uniform.
T uniform(T, E)(T t, in string name, E e1, E e2, E e3)if(isInherentingIn!(E, GlArithmeticTypes)){
    E[3] v  = [e1, e2, e3];
    t.uniform(name, v);
    return t;
}


/// Set four arguments as uniform, 
T uniform(T, E)(T t, in string name, E e1, E e2, E e3, E e4)if(isInherentingIn!(E, GlArithmeticTypes)){
    E[4] v  = [e1, e2, e3, e4];
    t.uniform(name, v);
    return t;
}
