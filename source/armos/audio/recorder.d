module armos.audio.recorder;

import derelict.openal.al;
/++
+/
class Recorder {
    public{
        ///
        this(uint rate = 44100, uint size = 1024){
            DerelictAL.load();
            _rate = rate;
            _size = size;
            _device = alcCaptureOpenDevice(null, _rate, AL_FORMAT_STEREO16, _size);
        }

        ~this(){
            stop;
            alcCaptureCloseDevice(_device);
        }

        ///
        string usableDevice(){
            import std.conv;
            return alcGetString(null, ALC_CAPTURE_DEVICE_SPECIFIER).to!string;
        }

        ///
        string currentDevice(){
            import std.conv;
            assert(_device, "No capture device selected.");
            return alcGetString(_device, ALC_CAPTURE_DEVICE_SPECIFIER).to!string;
        }

        ///
        const(byte[]) buffer()const{
            return _buffer;
        }

        ///
        int samples()const{
            return _samples;
        }

        ///
        Recorder update(){
            alcGetIntegerv(_device, ALC_CAPTURE_SAMPLES, cast(ALCsizei)(ALint.sizeof), &_samples);
            if(_samples > 0){
                _buffer = new byte[_samples];
                alcCaptureSamples(_device, _buffer.ptr, _samples/2);
            }else{
                _buffer = [];
            }
            return this;
        }

        ///
        Recorder start(){
            alcCaptureStart(_device);
            return this;
        }

        ///
        Recorder stop(){
            alcCaptureStop(_device);
            return this;
        }
    }//public

    private{
        ALCdevice*  _device;
        int _samples;
        byte[] _buffer;
        uint _rate;
        uint _size;
    }//private
}//class Recorder
