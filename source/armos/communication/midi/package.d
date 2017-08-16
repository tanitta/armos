module armos.communication.midi;

import derelict.portmidi.portmidi;
import derelict.portmidi.porttime;

struct MidiMessage{
    long timestamp;
    long status;
    long data1;
    long data2;
}

/++
+/
class MidiStream {
    public{
        static this(){
            DerelictPortMidi.load();
            DerelictPortTime.load();
        }

        static ~this(){
        }

        static auto inputStream(in int id = defaultInputDeviceId(), in size_t bufferSize = 1024){
            auto stream = new MidiStream;
            auto e = Pm_OpenInput(&stream._stream,
                                  id,
                                  null,
                                  bufferSize,
                                  null,
                                  null);
            return stream;
        }

        static int defaultInputDeviceId(){
            return Pm_GetDefaultInputDeviceID();
        }

        MidiStream close(){
            Pm_Close(this._stream);
            _hasClosed = true;
            return this;
        }

        MidiMessage[] popMessages(){
            immutable size_t max = 1024;
            auto buffer = new PmEvent[](max);
            auto numEvents = Pm_Read(_stream, buffer.ptr, max);
            auto events = new MidiMessage[](numEvents);
            foreach (size_t i, ref event; events) {
                import std.conv:to;
                event.timestamp = buffer[i].timestamp.to!long;
                event.status    = buffer[i].message.to!long & 0xFF;
                event.data1     = (buffer[i].message.to!long>>8) & 0xFF;
                event.data2     = (buffer[i].message.to!long>>16) & 0xFF;
            }
            return events;
        }
    }//public

    private{
        this(){}
        ~this(){
            if(!_hasClosed){
                close;
            }
        }

        PmStream*  _stream;
        PmDeviceID _deviceId;
        bool _hasClosed = false;
    }//private
}//class Stream


