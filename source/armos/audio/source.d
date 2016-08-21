module armos.audio.source;

import derelict.openal.al;
import armos.math;
import armos.audio.buffer;

/++
+/
enum SourceState {
    Initial = AL_INITIAL,
    Playing = AL_PLAYING,
    Paused  = AL_PAUSED,
    Stopped = AL_STOPPED
}//enum SourceState

/++
+/
class Source{
    public{
        ///
        this(){
            alGenSources(1, cast(uint*)&_id); 
        }
        
        ///
        ~this(){
            alDeleteSources(1, cast(uint*)&_id);
        }
        
        ///
        Source buffer(Buffer b){
            alSourcei(_id, AL_BUFFER, b.id);
            return this;
        }
        
        ///
        SourceState state(){
            int s;
            alGetSourcei(_id, AL_SOURCE_STATE, &s);
            switch (s) {
                case AL_INITIAL:
                         _state = SourceState.Initial;
                         break;
                case AL_PLAYING:
                         _state = SourceState.Playing;
                         break;
                case AL_PAUSED:
                         _state = SourceState.Paused;
                         break;
                case AL_STOPPED:
                         _state = SourceState.Stopped;
                         break;
                default:
                         assert(0);
            }
            return _state;
        };
        
        ///
        Source play(){
            alSourcePlay(_id);
            return this;
        }
        
        ///
        Source pause(){
            alSourcePause(_id);
            return this;
        }
        
        ///
        Source stop(){
            alSourceStop(_id);
            return this;
        }
        
        ///
        Source Rewind(){
            alSourceRewind(_id);
            return this;
        }
        
        ///
        Source position(V)(in V p)if(isVector!(V) && V.dimention >= 3){
            alSource3f(_id, AL_POSITION, p[0], p[1], p[2]);
            _position[3] = 1f;
            foreach (int i, e; p.elements) {
                _position[i] = e;
            }
            return this;
        }
        
        ///
        Source velocity (V)(in V v)if(isVector!(V) && V.dimention >= 3){
            alSource3f(_id, AL_VELOCITY, v[0], v[1], v[2]);
            _velocity[3] = 0f;
            foreach (int i, e; v.elements) {
                _velocity[i] = e;
            }
            return this;
        }
        
        Source direction (V)(in V v)if(isVector!(V) && V.dimention >= 3){
            alSource3f(_id, AL_DIRECTION, v[0], v[1], v[2]);
            _direction[3] = 0f;
            foreach (int i, e; v.elements) {
                _direction[i] = e;
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
        Vector4f direction()const{
            return _direction;
        }
        
        ///
        Source gain(in float g){
            alSourcef(_id, AL_GAIN, g);
            _gain = g;
            return this;
        }
        
        ///
        float gain(){return _gain;}
        
        ///
        Source isLooping(in bool f){
            alSourcei(_id, AL_LOOPING, f?AL_TRUE:AL_FALSE);
            _isLooping = f;
            return this;
        }
        
        ///
        bool isLooping()const{return _isLooping;}
    }//public

    private{
        int _id;
        Vector4f _position  = Vector4f(0, 0, 0, 1); 
        Vector4f _velocity  = Vector4f(0, 0, 0, 0);
        Vector4f _direction = Vector4f(0, 0, 0, 0);
        float _gain = 1f;
        bool _isLooping = false;
        
        SourceState _state;
    }//private
}//class Source
