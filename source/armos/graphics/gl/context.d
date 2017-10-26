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
            _modelMatrixStack      = new Stack!Matrix4f;
            _viewMatrixStack       = new Stack!Matrix4f;
            _projectionMatrixStack = new Stack!Matrix4f;
            _textureMatrixStack    = new Stack!Matrix4f;

            _shaderStack           = new Stack!Shader;
            // _bufferStacks          = new Stack!Buffer;
            _vaoStack              = new Stack!Vao;

            _readFramebufferStack  = new Stack!Fbo;
            _drawFramebufferStack  = new Stack!Fbo;
        }

        Stack!Matrix4f matrixStack(in MatrixType matrixType){
            Stack!Matrix4f s;
            switch (matrixType) {
                case MatrixType.Model:
                    s = _modelMatrixStack;
                    break;
                case MatrixType.View:
                    s = _viewMatrixStack;
                    break;
                case MatrixType.Projection:
                    s = _projectionMatrixStack;
                    break;
                case MatrixType.Texture:
                    s = _textureMatrixStack;
                    break;
                default:
                    assert(false);
            }
            return s;
        }
    }//publii

    private{
        Stack!Matrix4f _modelMatrixStack;
        Stack!Matrix4f _viewMatrixStack;
        Stack!Matrix4f _projectionMatrixStack;
        Stack!Matrix4f _textureMatrixStack;

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
    assert(__traits(compiles, (){
        Context context;
    }));
}

///
Matrix4f matrix(Context c, in MatrixType type){
    return c.matrixStack(type).current;
}

///
Context matrix(Context c, in MatrixType type, in Matrix4f m){
    c.matrixStack(type).current = m;
    return c;
}

///
Context pushMatrix(Context c, in MatrixType type){
    c.matrixStack(type).push(c.matrixStack(type).current);
    return c;
}

///
Context popMatrix(Context c, in MatrixType type){
    c.matrixStack(type).pop;
    return c;
}

///
Context multMatrix(Context c, in MatrixType type, in Matrix4f m){
    c.matrixStack(type).current = c.matrixStack(type).current * m;
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
    return c._shaderStack.current;
}

///
Context pushShader(Context c, Shader shader){
    auto prevShader = c.shader;
    c._shaderStack.push(shader);
    if(!c.shader){
        import derelict.opengl3.gl;
        glUseProgram(0);
        return c;
    }
    if(c.shader != prevShader){
        c.shader.bind;
    }
    return c;
}

///
Context popShader(Context c){
    assert(!c._shaderStack.empty, "stack is empty");
    auto prevShader = c.shader;
    c._shaderStack.pop();
    if(c._shaderStack.empty){
        import derelict.opengl3.gl;
        glUseProgram(0);
        return c;
    }
    if(c.shader != prevShader){
        c.shader.bind;
        return c;
    }
    return c;
}

import derelict.opengl3.gl;
///
enum TextureTarget{
    Dim1= GL_TEXTURE_1D,
    Dim2= GL_TEXTURE_2D,
    Dim3= GL_TEXTURE_3D,
    Buffer = GL_TEXTURE_BUFFER,
    Dim1Array = GL_TEXTURE_1D_ARRAY,
    Dim2Array = GL_TEXTURE_2D_ARRAY,
    Dim3Array = GL_TEXTURE_RECTANGLE,
    CubeMap      = GL_TEXTURE_CUBE_MAP,
    CubeMapArray = GL_TEXTURE_CUBE_MAP_ARRAY,
    Dim2Multisample      = GL_TEXTURE_2D_MULTISAMPLE,
    Dim2MultisampleArray = GL_TEXTURE_2D_MULTISAMPLE_ARRAY,
}

alias TextureUnit = Texture[TextureTarget];

/++
+/
class Stack(T){
    public{
        ref const(T) current()const{
            return _stack[$-1];
        }

        ref T current(){
            return _stack[$-1];
        }
        
        
        Stack!T push(T elem){
            _stack ~= elem;
            return this;
        }
        
        Stack!T pop(){
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
    assert(t.current == 1);
    t.push(2);
    assert(t.current == 2);
    t.pop();
    assert(t.current == 1);
}

Stack!Matrix4f mult(Stack!Matrix4f stack, in Matrix4f m){
    stack.current = stack.current * m;
    return stack;
}
