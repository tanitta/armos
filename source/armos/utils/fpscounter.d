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
            //convert from fps to nsecs
            _targetNsecsTime = (1.0/fps*1000000000.0).to!int;
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
            immutable def = ( after.ticks - _timer.ticks ).ticksToNSecs;
            if( def < _targetNsecsTime){
                Thread.sleep( dur!("nsecs")( _targetNsecsTime - def ) );
            }
            immutable after2 = MonoTime.currTime;
            immutable def2 = ( after2.ticks - _timer.ticks ).ticksToNSecs;
            _currentFps = 1.0/def2.to!double*1000000000.0;
            _fpsUseRate = def.to!double/_targetNsecsTime.to!double;
        }
    }

    private{
        double _targetFps = 60.0;
        double _currentFps = 60.0;
        ulong  _currentFrames = 0;
        int    _targetNsecsTime = 0;
        double _fpsUseRate = 0;
        MonoTime _timer;

    }
}

