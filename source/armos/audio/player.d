module armos.audio.player;

import derelict.openal.al;
import armos.math;
import armos.audio.source;
import armos.audio.soundbuffer;

/++
+/
class Player {
    public{
        ///
        this(){
            DerelictAL.load();
            _device = alcOpenDevice(null);
            assert(_device, "Not found any devices.");
            _context = alcCreateContext(_device, null);
            assert(_device, "Failure creating openAL context.");
            alcMakeContextCurrent(_context);
        }
        
        ///
        ~this(){
            alcMakeContextCurrent(null);
            alcDestroyContext(_context);
            alcCloseDevice(_device);
        }
        
        ///
        Source play(SoundBuffer buf){
            return play(buf, Vector4f.zero);
        }
        
        ///
        Source play(V4)(SoundBuffer buf, in V4 position, in V4 velocity = V4.zero)if(isVector!(V4) && V4.dimention){
            return (new Source).position(position)
                               .velocity(velocity)
                               .buffer(buf)
                               .play;
        }
    }//public

    private{
        ALCdevice*  _device;
        ALCcontext* _context;
        Source[] _sources;
    }//private
}//class Player
