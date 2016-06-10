module armos.utils.fpscounter;
import core.time;
import core.thread;
import std.conv;

class FpsCounter {
    public{
        this(in double defaultFps = 60){
            _timer = MonoTime.currTime;
            _currentFps = defaultFps;
            this.targetFps = defaultFps;
        }

        void targetFps(in double fps){
            _targetFps = fps;
            _targetTime = convertedTimeFromFps(fps);
        }

        double targetFps()const{
            return _targetFps;
        }

        double currentFps()const{
            return _currentFps;
        }

        void newFrame(){
            _timer = MonoTime.currTime;
            _currentFrames++;
        }

        ulong currenFrames()const{
            return _currentFrames;
        };

        double fpsUseRate()const{
            return _fpsUseRate;
        }

        void adjust(){
            immutable MonoTime after = MonoTime.currTime;
            immutable def = ( after - _timer );
            if( def.fracSec.hnsecs < _targetTime){
                Thread.sleep( dur!("hnsecs")( _targetTime - def.fracSec.hnsecs ) );
            }
            immutable after2 = MonoTime.currTime;
            immutable def2 = after2 - _timer;
            _currentFps = 1.0/def2.fracSec.hnsecs.to!double*10000000.0;
            _fpsUseRate = def.fracSec.hnsecs.to!double/_targetTime.to!double;
        }
    }

    private{
        double _targetFps = 60.0;
        double _currentFps = 60.0;
        ulong  _currentFrames = 0;
        int _targetTime = 0;
        double _fpsUseRate = 0;
        MonoTime _timer;

    }
}

private int convertedTimeFromFps(in double fps){
    return (1.0/fps*10000000.0).to!int;
}

