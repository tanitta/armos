module armos.audio.buffer;

import derelict.openal.al;
import derelict.ogg.ogg;
import derelict.vorbis.vorbis;
import derelict.vorbis.enc;
import derelict.vorbis.file;

import armos.audio.spectrum;

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
        Buffer load(string path){
            import std.file;
            import std.path;
            switch (extension(path)) {
                case ".wav":
                    loadWav(path);
                    break;
                case ".ogg":
                    loadOgg(path);
                    break;
                default:
                    assert(0, "invalid format");
            }
            return this;
        }
        
        ///
        Buffer loadWav(string path){
            import std.file;
            loadWav(cast(ubyte[])read(path));
            return this;
        }
        
        ///
        Buffer loadWav(ubyte[] buffer){
            load(buffer.decodeWave);
            return this;
        }
        
        ///
        Buffer load(Wave wave){
            import std.conv;
            _sampleRate = wave.sampleRate.to!int;
            _numChannels = wave.numChannels.to!int;
            _depth = wave.depth.to!int;
            _format = formatFrom(wave.numChannels, wave.depth);
            
            if(!_channels) setupChannnels;
            
            alBufferData(_id,
                         _format,
                         wave.data.ptr,
                         wave.data.length.to!int,
                         wave.sampleRate.to!int);
            return this;
        }
        
        ///
        Buffer loadOgg(string path){
            DerelictOgg.load();
            DerelictVorbis.load();
            DerelictVorbisEnc.load();
            DerelictVorbisFile.load();
            
            OggVorbis_File vorbisFile;
            import std.string;
            if (ov_fopen(path.toStringz, &vorbisFile) != 0){
                assert(0);
            }
            vorbis_info* info = ov_info(&vorbisFile, -1);
            
            import std.conv;
            import std.algorithm;
            import std.array;
            byte[] tempData = new byte[4096];
            int currentPosition = 0;
            
            import std.array:appender;
            auto dataApp = appender!(byte[]);
            while(true){
                size_t tempSize = ov_read(&vorbisFile, tempData.ptr, 4096, 0, 2, 1, &currentPosition);
                if(tempSize <= 0)break;
                dataApp.put(tempData[0..tempSize]);
            }
            byte[] data = dataApp.data;
            
            _sampleRate = info.rate;
            
            import std.range;
            auto pcmApp = appender!(short[]);
            foreach (offset; data.length.iota) {
                if (offset % 2 == 0) {
                    //convert ubyte to 16 bit little endian integer
                    short val = cast(short)(cast(ubyte)(data[offset]) | (cast(ubyte)(data[offset + 1])<<8));
                    pcmApp.put(cast(short)((val & 0x8000) ? val | 0xFFFF0000 : val));
                }
            } 
            _pcm = pcmApp.data;
            
            _numChannels = info.channels;
            _depth = 16;
            _format = formatFrom(info.channels, 16);
            
            if(!_channels) setupChannnels;
                
            alBufferData(_id,
                         _format, 
                         _pcm.ptr,
                         _pcm.length.to!int*2,
                         info.rate);
            
            ov_clear(&vorbisFile);
            return this;
        }
        
        //TODO
        // void loadOgg(ubyte[] buffer){
        
        ///
        int id()const{return _id;}
        
        ///
        int samplingRate()const{
            return _sampleRate;
        }
        
        ///
        int numChannels()const{return _numChannels;}
        
        ///
        int depth()const{return _depth;}
        
        ///
        ALenum format()const{return _format;}
        
        short[] pcm(){
            return _pcm;
        }
        
        ///
        size_t channelLength()const{
            return _pcm.length/_numChannels;
        }
        
        ///
        Buffer range(in float startSec, in float finishSec){
            _start  = startSec;
            _finish = finishSec;
            float sampleRate = _sampleRate;
            import std.conv;
            short[] rangedPcm;
            if(finishSec < 0f){
                rangedPcm = _pcm[(_start*sampleRate).to!int*2..$];
            }else{
                rangedPcm = _pcm[(_start*sampleRate).to!int*2..(_finish*sampleRate).to!int*2];
            }
            
            if(!_channels) setupChannnels;
            
            alBufferData(_id,
                         _format, 
                         rangedPcm.ptr,
                         rangedPcm.length.to!int*2,
                         _sampleRate);
            return this;
        }
        
        ///
        Spectrum!double spectrumAtIndex(T = short)(in size_t channelIndex, in size_t index, in size_t bufferSize)const
        in{
            assert(index < channelLength);
        }
        body{
            const channel = _channels[channelIndex];
            
            short[] result = new short[](bufferSize*2);
            for (size_t i = index-(bufferSize*2-1), j = 0; i <= index; i++, j++) {
                if(0 <= i){
                    result[j] = channel[i];
                }
            }
            assert(result.length == bufferSize*2);
            return spectrum!double(result, _sampleRate);
        }
    }//public

    private{
        int _id;
        short[] _pcm;
        short[][] _channels;
        int _sampleRate;
        int _numChannels;
        int _depth;
        float _start;
        float _finish;
        ALenum _format;
        
        void setupChannnels(){
            import std.range:Appender;
            import std.stdio;
            for (int c = 0; c < _numChannels; c++) {
                _channels ~= new short[](0);
            }
            
            Appender!(short[])[] channelApps = new Appender!(short[])[](_numChannels);
            for (int i = 0; i < _pcm.length/_numChannels; i++) {
                for (int c = 0; c < _numChannels; c++) {
                    immutable pcmIndex = i*_numChannels+c;
                    channelApps[c].put(_pcm[pcmIndex]);
                }
            }
            assert(_channels.length == _numChannels);
            for (int c = 0; c < _numChannels; c++) {
                _channels[c] = channelApps[c].data;
            }
        }
    }//private
}//class Buffer

private{
    Spectrum!R spectrum(R, T)(T[] sample, in int samplingRate){
        import std.numeric:fft;
        import std.range:iota;
        import std.algorithm:map;
        import std.array:array;
        import std.conv:to;
        
        auto windowLength = sample.length;
        auto transformLength = windowLength;//TODO
        
        auto frequencyRange = transformLength.iota.map!(x=>x*(samplingRate/transformLength).to!R)[0..$/2].array;
        
        auto fx = fft(sample)[0..$/2];
        auto powers = fx.map!(x=>(x*typeof(x)(x.re, -x.im)).re/transformLength).array;

        Spectrum!R result;

        result.samplingRate = samplingRate;
        result.powers = powers;
        result.frequencyRange = frequencyRange;
        return result;
    }
    
    ALenum formatFrom(size_t numChannels, size_t depth){
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
        assert(formatFrom(1,8)  == AL_FORMAT_MONO8);
        assert(formatFrom(1,16) == AL_FORMAT_MONO16);
        assert(formatFrom(2,8)  == AL_FORMAT_STEREO8);
        assert(formatFrom(2,16) == AL_FORMAT_STEREO16);
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
    
    // I wish to thank alpha_kai_NET for providing this decoder.
    // cf. http://qiita.com/alpha_kai_NET/items/7346636d247449e8b342
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
        while (b < buf.length) {
            e = b + ChunkHead.sizeof;
            chunk = cast(ChunkHead*)buf[b..e];

            if (chunk.size < 0) {
                writeln("ERROR! Invalid chunk size");
                return null; 
            }

            b = e;

            if (chunk.id == "fmt ") {
                import std.algorithm : min;
                e = b + min(chunk.size, WaveFormatChunk.sizeof);
                format = cast(WaveFileFormat*)buf[b..e];

                b = e;
            } else if (chunk.id == "data") {
                e = b + chunk.size;

                bufPcm = buf[b..e];
                pcm.length = bufPcm.length / 2;

                size_t realIdx;

                import std.range;
                foreach (offset; bufPcm.length.iota) {
                    if (offset % 2 == 0) {
                        //convert ubyte to 16 bit little endian integer
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

}
