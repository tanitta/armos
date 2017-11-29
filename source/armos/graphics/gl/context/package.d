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
import armos.graphics.gl.stack;

public import armos.graphics.gl.context.helper.buffer;
public import armos.graphics.gl.context.helper.capability;
public import armos.graphics.gl.context.helper.matrix;
public import armos.graphics.gl.context.helper.shader;
public import armos.graphics.gl.context.helper.vao;

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

    package{
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

Context currentContext()
out(context){
    assert(context);
}body{
    import armos.app.runner:mainLoop;
    return mainLoop.currentEnvironment.context;
}

private Context bindVao(Context c){
    return c;
}

///
alias TextureUnit = Texture[TextureTarget];

///
enum MatrixType {
    Model,
    View,
    Projection,
    Texture
}//enum MatrixType

