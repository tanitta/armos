module armos.graphics.gl.rbo;
import armos.graphics;
import derelict.opengl3.gl;
import armos.math.vector;

/++
Render Buffer Objectを表すclassです．
+/
class Rbo{
    public{
        /++
            IDを返します．
        +/
        int id(){
            return rboID_;
        }

        /++
        +/
        this(){
            glGenRenderbuffers(1, cast(uint*)&rboID_);
            // begin;
            // glRenderbufferStorage(GL_RENDERBUFFER, internalFormat,
            // 	600, 800);
            // end;
        }

        /++
            RBOへの書き込みを開始します．
        +/
        void begin(){
            glGetIntegerv(GL_RENDERBUFFER_BINDING, &savedRboID_);
            glBindRenderbuffer(GL_RENDERBUFFER, rboID_);
        }

        /++
            RBOへの書き込みを終了します．
        +/
        void end(){
            glBindRenderbuffer(GL_RENDERBUFFER, savedRboID_);
        }

        void allocate(){}
    }//public

    private{
        int savedRboID_=0;
        int rboID_ = 0;
        armos.math.Vector2i size_;
    }//private


}
