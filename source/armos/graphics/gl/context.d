module armos.graphics.gl.context;

import armos.math.matrix;
import armos.graphics.gl.shader;
import armos.graphics.gl.texture;
import armos.graphics.gl.fbo;
import armos.graphics.gl.buffer;
import armos.graphics.gl.vao;
import armos.graphics.gl.viewport;
import armos.graphics.gl.capability;
import armos.graphics.gl.polyrendermode;
import armos.graphics.gl.texture:TextureTarget;

///
enum MatrixType {
    Model,
    View,
    Projection,
    Texture
}//enum MatrixType

///
class Context {
    public{
        this(){
            _matrixStacks[MatrixType.Model]      = new Stack!Matrix4f;
            _matrixStacks[MatrixType.View]       = new Stack!Matrix4f;
            _matrixStacks[MatrixType.Projection] = new Stack!Matrix4f;
            _matrixStacks[MatrixType.Texture]    = new Stack!Matrix4f;

            _shaderStack           = new Stack!Shader;
            _bufferStacks[BufferType.ElementArray]     = new Stack!Buffer;
            _bufferStacks[BufferType.Array]            = new Stack!Buffer;
            _vaoStack              = new Stack!Vao;

            _readFramebufferStack  = new Stack!Fbo;
            _drawFramebufferStack  = new Stack!Fbo;
        }

        Stack!Matrix4f matrixStack(in MatrixType matrixType){
            return _matrixStacks[matrixType];
        }
    }//publii

    private{
        Stack!Matrix4f[MatrixType] _matrixStacks;

        Stack!Shader             _shaderStack;
        Stack!Buffer[BufferType] _bufferStacks;
        Stack!Vao                _vaoStack;

        Stack!Fbo _readFramebufferStack;
        Stack!Fbo _drawFramebufferStack;

        Stack!Texture[TextureTarget][] _textureStacks;
        Stack!size_t                   _activeTextureUnitStack;
        Stack!Viewport _viewportStack;
        Stack!bool[Capability] _capabilityStacks;
        Stack!PolyRenderMode     _polyRenderModeStack;
    }
}//class Context

unittest{
    // assert(__traits(compiles, (){
    //     Context context;
    // }));
}

///
Matrix4f matrix(Context c, in MatrixType type){
    return c.matrixStack(type).top;
}

///
Context matrix(Context c, in MatrixType type, in Matrix4f m){
    c.matrixStack(type).top = m;
    return c;
}

///
Context pushMatrix(Context c, in MatrixType type){
    c.matrixStack(type).push(c.matrixStack(type).top);
    return c;
}

///
Context popMatrix(Context c, in MatrixType type){
    c.matrixStack(type).pop;
    return c;
}

///
Context multMatrix(Context c, in MatrixType type, in Matrix4f m){
    c.matrixStack(type).top = c.matrixStack(type).top * m;
    return c;
}


///
Matrix4f modelMatrix(Context c){
    return c.matrix(MatrixType.Model);
}

///
Context modelMatrix(Context c, in Matrix4f m){
    return c.matrix(MatrixType.Model, m);
}

///
Context pushModelMatrix(Context c){
    return c.pushMatrix(MatrixType.Model);
}

///
Context popModelMatrix(Context c){
    return c.popMatrix(MatrixType.Model);
}

///
Context multModelMatrix(Context c, in Matrix4f m){
    return c.multMatrix(MatrixType.Model, m);
}


///
Matrix4f viewMatrix(Context c){
    return c.matrix(MatrixType.View);
}

///
Context viewMatrix(Context c, in Matrix4f m){
    return c.matrix(MatrixType.View, m);
}

///
Context pushViewMatrix(Context c){
    return c.pushMatrix(MatrixType.View);
}

///
Context popViewMatrix(Context c){
    return c.popMatrix(MatrixType.View);
}

///
Context multViewMatrix(Context c, in Matrix4f m){
    return c.multMatrix(MatrixType.View, m);
}


///
Matrix4f projectionMatrix(Context c){
    return c.matrix(MatrixType.Projection);
}

///
Context projectionMatrix(Context c, in Matrix4f m){
    return c.matrix(MatrixType.Projection, m);
}

///
Context pushProjectionMatrix(Context c){
    return c.pushMatrix(MatrixType.Projection);
}

///
Context popProjectionMatrix(Context c){
    return c.popMatrix(MatrixType.Projection);
}

///
Context multProjectionMatrix(Context c, in Matrix4f m){
    return c.multMatrix(MatrixType.Projection, m);
}


Shader shader(Context c){
    if(c._shaderStack.empty) return null;
    return c._shaderStack.top;
}

///
Context pushShader(Context c, Shader shader){
    auto prevShader = c.shader;
    c._shaderStack.push(shader);
    if(!c.shader){
        Shader.bind(null);
        return c;
    }
    if(c.shader != prevShader){
        c.shader.bind;
    }
    return c;
}

///
Context popShader(Context c){
    auto prevShader = c.shader;
    c._shaderStack.pop();
    if(c._shaderStack.empty){
        Shader.bind(null);
        return c;
    }
    if(c.shader != prevShader){
        c.shader.bind;
        return c;
    }
    return c;
}

Buffer buffer(Context c, in BufferType bufferType){
    import std.algorithm:canFind;
    if(!c._bufferStacks.keys.canFind(bufferType)) return null;
    if(c._bufferStacks[bufferType].empty) return null;
    return c._bufferStacks[bufferType].top;
}

Context pushBuffer(Context c, in BufferType bufferType, Buffer buffer){
    auto prevBuffer = c.buffer(bufferType);
    c._bufferStacks[bufferType].push(buffer);
    if(!c.buffer(bufferType)){
        Buffer.bind(bufferType, null);
        return c;
    }
    if(c.buffer(bufferType) != prevBuffer){
        c.buffer(bufferType).bind;
        return c;
    }
    return c;
}

Context popBuffer(Context c, in BufferType bufferType){
    auto prevBuffer = c.buffer(bufferType);
    c._bufferStacks[bufferType].pop();
    if(c._bufferStacks[bufferType].empty){
        Buffer.bind(bufferType, null);
        return c;
    }
    if(c.buffer(bufferType) != prevBuffer){
        c.buffer(bufferType).bind;
        return c;
    }
    return c;
}


import derelict.opengl3.gl;
///

alias TextureUnit = Texture[TextureTarget];

/++
+/
class Stack(T){
    public{
        ref const(T) top()const{
            return _stack[$-1];
        }

        ref T top(){
            return _stack[$-1];
        }
        
        
        Stack!T push(T elem){
            _stack ~= elem;
            return this;
        }
        
        Stack!T pop(){
            assert(!empty, "stack is empty");
            import std.array;
            _stack.popBack;
            return this;
        }
        
        Stack!T load(ref T elem){
            _stack[$-1] = elem;
            return this;
        }
        
        bool empty()const{
            return _stack.length == 0;
        }
    }//public

    private{
        T[] _stack;
    }//private
}//class MatrixStack

unittest{
    auto t = new Stack!int;
    import std.stdio;
    t.push(1);
    assert(t.top == 1);
    t.push(2);
    assert(t.top == 2);
    t.pop();
    assert(t.top == 1);
}

Stack!Matrix4f mult(Stack!Matrix4f stack, in Matrix4f m){
    stack.top = stack.top * m;
    return stack;
}
