module armos.graphics.gl.sampler;

import derelict.opengl3.gl;

/++
+/
class Sampler {
    public{
        ///
        this(){
            glGenSamplers(1, cast(uint*)&_id);
            //TODO
            glSamplerParameteri (_id, GL_TEXTURE_WRAP_S, GL_REPEAT);
            glSamplerParameteri (_id, GL_TEXTURE_WRAP_T, GL_REPEAT);
            glSamplerParameteri (_id, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glSamplerParameteri (_id, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            
            _textureUnit = 0;
        }
        
        ///
        ~this(){
            glDeleteSamplers(1, cast(uint*)&_id);
        }
        
        ///
        void begin(){
            int savedID;
            glGetIntegerv(GL_SAMPLER_BINDING ,&savedID);
            _savedIDs ~= savedID;
            glBindSampler(0, _id);
        }

        ///
        int textureUnit()const{
            return _textureUnit;
        }
        
        ///
        Sampler textureUnit(in int n){
            _textureUnit = n;
            return this;
        }
        
        ///
        void end(){
            import std.range;
            glBindSampler(_textureUnit, _savedIDs[$-1]);
            if (_savedIDs.length == 0) {
                assert(_textureUnit, "stack is empty");
            }else{
                _savedIDs.popBack;
            }
        }
    }//public

    private{
        int _id;
        int[] _savedIDs;
        int _textureUnit;
    }//private
}//class Sampler
