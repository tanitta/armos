module armos.graphics.gl.uniform;

import derelict.opengl3.gl;

import armos.graphics.gl.shader;
import armos.math.vector;
import armos.math.matrix;
import armos.graphics.gl.shaderutils;

import std.variant;
import std.meta;

import armos.graphics.gl.types;

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
Shader uniform(A:T[N], T, size_t N)(Shader shader, in string name, A v)if(isInherentingIn!(T, GlArithmeticTypes)){
    if(shader.isLoaded){
        shader.begin;
        int location = shader.uniformLocation(name);
        if(location != -1){
            import std.conv:to;
            mixin(glFunctionString!(T[], N).name("glUniform") ~ "(location, 1, v.ptr);" );
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

import armos.graphics.gl.texture;
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

///
template hasUniformImpl(T) {
    enum bool hasUniformImpl = __traits(compiles, (){
        T t;
        Uniform u;
        t.uniformImpl("uniformName", u);
    });
}//template hasUniformImpl

T uniform(T)(T t, in string name, Uniform u)if(hasUniformImpl!T){
    t.uniformImpl(name, u);
    return t;
}

import std.meta:staticIndexOf;
///
T uniform(T, U)(T t, in string name, U v)if(hasUniformImpl!T && staticIndexOf!(U, AcceptableUniformTypes)!=-1)
{
    t.uniformImpl(name, Uniform(v));
    return t;
}

T uniform(T, V)(T t, in string name, V v)
if(isVector!(V) && V.dimention <= 4){
    t.uniform(name, v.array);
    return t;
}

T uniform(T, M)(T t, in string name, M m)
if(isMatrix!(M)){
    t.uniform(name, m.array!2);
    return t;
}

///
T uniform(T, E)(T t, in string name, E e)if(isInherentingIn!(E, GlArithmeticTypes)){
    E[1] v  = [e];
    uniform(t, name, v);
    return t;
}

///
T uniform(T, E)(T t, in string name, E e1, E e2)if(isInherentingIn!(E, GlArithmeticTypes)){
    E[2] v  = [e1, e2];
    uniform(t, name, v);
    return t;
}

///
T uniform(T, E)(T t, in string name, E e1, E e2, E e3)if(isInherentingIn!(E, GlArithmeticTypes)){
    E[3] v  = [e1, e2, e3];
    uniform(t, name, v);
    return t;
}

///
T uniform(T, E)(T t, in string name, E e1, E e2, E e3, E e4)if(isInherentingIn!(E, GlArithmeticTypes)){
    E[4] v  = [e1, e2, e3, e4];
    uniform(t, name, v);
    return t;
}
