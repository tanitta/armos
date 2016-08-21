module armos.audio;

import derelict.openal.al;
import armos.math;

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
        Source play(Buffer buf){
            return play(buf, Vector4f.zero);
        }
        
        ///
        Source play(V4)(Buffer buf, in V4 position, in V4 velocity = V4.zero)if(isVector!(V4) && V4.dimention){
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

/++
+/
class Buffer {
    public{
        ///
        this(){
           alGenBuffers(1, cast(uint*)&_id); 
        }
        
        ///
        ~this(){
           alDeleteBuffers(1, cast(uint*)&_id); 
        }
        
        ///
        void load(ubyte[] buffer){
            Wave wave= buffer.decodeWave;
            import std.conv;
            alBufferData(_id,
                         format(wave.numChannels, wave.depth),
                         wave.data.ptr,
                         wave.data.length.to!int,
                         wave.sampleRate.to!int);
        }
        
        ///
        void load(string path){
            import std.file;
            load(cast(ubyte[])read(path));
        }
        
        //TODO: load ogg
        
        ///
        int id()const{return _id;}
    }//public

    private{
        int _id;
    }//private
}//class Buffer

private{
    ALenum format(size_t numChannels, size_t depth){
        ALenum f;
        if(numChannels == 1){
            if(depth == 8){
                f = AL_FORMAT_MONO8;
            }else{
                f = AL_FORMAT_MONO16;
            }
        }else{
            if(depth == 8){
                f = AL_FORMAT_STEREO8;
            }else{
                f = AL_FORMAT_STEREO16;
            }
        }
        return f;
    }
    
    unittest{
        assert(format(1,8)  == AL_FORMAT_MONO8);
        assert(format(1,16) == AL_FORMAT_MONO16);
        assert(format(2,8)  == AL_FORMAT_STEREO8);
        assert(format(2,16) == AL_FORMAT_STEREO16);
    }
    
    /++
        +/
    class Wave {
        public{
            size_t numChannels(){return _format.channels;}
            size_t sampleRate(){return _format.samplePerSecond;}
            size_t depth(){return _format.bitsPerSample;}
            
            short[] data(){return _data;}
        }//public

        private{
            WaveFileFormat _format;
            short[] _data;
        }//private
    }//class Wave
    
    struct ChunkHead {
        char[4] id;
        uint size;
    }

    struct RiffChunk {
        ChunkHead head;
        char[4] format;
    }

    struct WaveFileFormat {
        ushort audioFormat,
               channels;
        uint   samplePerSecond,
               bytesPerSecond;
        ushort blockAlign,
               bitsPerSample;
    }

    struct WaveFormatChunk {
        ChunkHead chunk;
        WaveFileFormat format;
    }

    auto min(M, N)(M m, N n) {
        return m > n ? n : m;
    }
    
    Wave decodeWave(ubyte[] buf){
        import std.stdio;
        size_t b = 0,
               e = RiffChunk.sizeof;

        RiffChunk* riff = cast(RiffChunk*)buf[b..e];

        WaveFileFormat* format;
        ubyte[] bufPcm;
        short[] pcm;

        if(riff.head.id != "RIFF") {
            writeln("Invalid WAV format was given");
            return null; 
        } 

        if (riff.format != "WAVE") {
            writeln("Invalid RIFF chunk format. Given file is not WAVE");
            return null; 
        }

        ChunkHead* chunk;

        b = e;
        size_t cursor;
        while (b < buf.length) {
            e = b + ChunkHead.sizeof;
            chunk = cast(ChunkHead*)buf[b..e];

            if (chunk.size < 0) {
                writeln("ERROR! Invalid chunk size");
                return null; 
            }

            b = e;

            if (chunk.id == "fmt ") {
                e = b + min(chunk.size, WaveFormatChunk.sizeof);
                format = cast(WaveFileFormat*)buf[b..e];

                b = e;
            } else if (chunk.id == "data") {
                e = b + chunk.size;

                bufPcm = buf[b..e];
                //隣接する2つの要素から1つのサンプルを計算するため必要な配列長はPCMの1/2
                pcm.length = bufPcm.length / 2;

                ulong realIdx;

                import std.range;
                foreach (offset; bufPcm.length.iota) {
                    if (offset % 2 == 0) {
                        //convert ubyte to 16 bit little endian integer
                        //隣接する2つのubyteから16bitのlittle endianなinteger(D言語ではshort)を計算する。
                        //この処理はNode.jsの`bufPcm`というライブラリと、`Buffer`の`readInt16LE`を参考にしました。
                        short val = cast(short)(bufPcm[offset] | (bufPcm[offset + 1] << 8));
                        pcm[realIdx++] = cast(short)((val & 0x8000) ? val | 0xFFFF0000 : val);
                    }
                } 

                b = e;
            } else {//skip the others chunk
                b = e + chunk.size;
            }
        }

        Wave wav = new Wave;
        wav._format = *format;
        wav._data = pcm;
        return wav;
    }
}
