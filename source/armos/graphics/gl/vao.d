module armos.graphics.gl.vao;

import derelict.opengl3.gl;

import armos.graphics.gl.buffer;
import armos.graphics.gl.stack;

/++
+/
class Vao {
    public{

        /++
        +/
        this(){
            glGenVertexArrays(1, cast(uint*)&_id);
        }

        ~this(){
            glDeleteVertexArrays(1, cast(uint*)&_id);
        }

        /++
        +/
        Vao begin(){
            import armos.app.runner:currentContext;
            import armos.graphics.gl.context;
            currentContext.pushVao(this);
            return this;
        }

        /++
        +/
        Vao end(){
            import armos.app.runner:currentContext;
            import armos.graphics.gl.context;
            currentContext.popVao();
            return this;
        }

        Buffer buffer(in BufferType bufferType){
            pragma(msg, __FILE__, "(", __LINE__, "): ",
                   "TODO: impl");
            return null;
        }
    }//public

    package{
        Vao bind(){
            return Vao.bind(this);
        }

        static Vao bind(Vao vao){
            if(!vao){
                glBindVertexArray(0);
                return vao;
            }
            glBindVertexArray(vao._id);
            return vao;
        }
    }

    private{
        int _id;
        int[] _savedIDs;

        Stack!Buffer[BufferType] _bufferStacks;
    }//private
}//class Vao
