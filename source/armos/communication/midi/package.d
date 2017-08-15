module armos.communication.midi;

import derelict.portmidi.portmidi;
import derelict.portmidi.porttime;

/++
+/
class Stream {
    public{
        static this(){
            DerelictPortMidi.load();
            DerelictPortTime.load();
        }

        static auto inputStream(){
            return new Stream;
        }

    }//public

    private{
        this(){}

        PmStream*  _stream;
        PmDeviceID _deviceId;
    }//private
}//class Stream
