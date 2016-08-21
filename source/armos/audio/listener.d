module armos.audio.listener;

import derelict.openal.al;
import armos.math;

/++
+/
class Listener {
    public{
        ///
        Listener position(V)(in V p)if(isVector!(V) && V.dimention >= 3){
            alListener3f(AL_POSITION, V[0], V[1], V[2]);
            _position[3] = 1f;
            foreach (int i, e; p.elements) {
                _position[i] = e;
            }
            return this;
        }
        
        ///
        Listener velocity (V)(in V v)if(isVector!(V) && V.dimention >= 3){
            alListener3f(AL_VELOCITY, V[0], V[1], V[2]);
            _velocity[3] = 0f;
            foreach (int i, e; v.elements) {
                _velocity[i] = e;
            }
            return this;
        }
        
        ///
        Listener at(V)(in V v)if(isVector!(V) && V.dimention >= 3){
            ALfloat[6] orientation = [v[0],  v[1],  v[2],
                                      up[0], up[1], up[2]];
            alListenerfv(AL_ORIENTATION, orientation.ptr);
            _at[3] = 0f;
            foreach (int i, e; v.elements) {
                _at[i] = e;
            }
            return this;
        }
        
        ///
        Listener up(V)(in V v)if(isVector!(V) && V.dimention >= 3){
            ALfloat[6] orientation = [at[0], at[1], at[2],
                                      v[0],  v[1],  v[2]];
            alListenerfv(AL_ORIENTATION, orientation.ptr);
            _up[3] = 0f;
            foreach (int i, e; v.elements) {
                _up[i] = e;
            }
            return this;
        }
        
        /// 
        Vector4f position()const{
            return _position;
        }
        
        /// 
        Vector4f velocity()const{
            return _velocity;
        }
        
        /// 
        Vector4f at()const{
            return _at;
        }
        
        /// 
        Vector4f up()const{
            return _up;
        }
        
        ///
        Listener gain(in float g){
            alListenerf(AL_GAIN, g);
            _gain = g;
            return this;
        }
        
        ///
        float gain(){return _gain;}
    }//public

    private{
        Vector4f _position = Vector4f(0, 0, 0, 1); 
        Vector4f _velocity = Vector4f(0, 0, 0, 0); ;
        Vector4f _at = Vector4f(0, 0, -1, 0);
        Vector4f _up = Vector4f(0, 1, 0, 0);
        float _gain = 1f;
    }//private
}//class Listener
