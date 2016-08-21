module armos.audio.buffer;

import derelict.openal.al;

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
                pcm.length = bufPcm.length / 2;

                ulong realIdx;

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
}
