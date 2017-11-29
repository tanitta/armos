module armos.graphics.gl.vao;

import derelict.opengl3.gl;

import armos.graphics.gl.buffer;
import armos.graphics.gl.shader;
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
            import armos.graphics.gl.context.helper.vao;
            currentContext.pushVao(this);
            return this;
        }

        /++
        +/
        Vao end(){
            import armos.app.runner:currentContext;
            import armos.graphics.gl.context.helper.vao;
            currentContext.popVao();
            return this;
        }

        ///
        Vao registerBuffer(in string attributeName, Buffer buffer, in Shader shader){
            registerBuffer(shader.attrLocation(attributeName), buffer);
            return this;
        }

        ///
        Vao registerBuffer(in int attributeLocation, Buffer buffer){
            if(buffer.type == BufferType.ElementArray){
                _ibo = buffer;
            }else{
                _vertexBuffers[attributeLocation] = buffer;
            }
            begin;
            isUsingAttribute(attributeLocation, true);
            buffer.sendToBindedVao(attributeLocation);
            isUsingAttribute(attributeLocation, false);
            end;
            return this;
        }

        ///
        Vao registerBuffer(Buffer buffer)in{
            assert(buffer.type == BufferType.ElementArray);
        }body{
            _ibo = buffer;
            begin;
            buffer.sendToBindedVao(0);
            end;
            return this;
        }

        ///
        Vao isUsingAttribute(in int attrLocation, in bool b){
            begin;
            isUsingAttributeWithoutBinding(attrLocation, b);
            end;
            return this;
        }

        ///
        Vao isUsingAttributes(in bool b){
            begin;
            import std.algorithm;
            _vertexBuffers.keys.each!((attrLocation){
                isUsingAttributeWithoutBinding(attrLocation, b);
            });
            end;
            return this;
        }

        ///
        Vao isUsingAttributeWithoutBinding(in int attrLocation, in bool b)in{
            import std.algorithm;
            assert(_vertexBuffers.keys.canFind(attrLocation), "No registration exists.");
        }body{
            if(b){
                glEnableVertexAttribArray(attrLocation);
            }else{
                glDisableVertexAttribArray(attrLocation);
            }
            return this;
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

        Buffer[int] _vertexBuffers;
        Buffer _ibo;
    }//private
}//class Vao
