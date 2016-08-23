import armos.app;
import armos.audio;
import armos.math;
alias ar = armos;
import std.stdio;

class TestApp : ar.app.BaseApp{
    override void setup(){
        _player = new ar.audio.Player;
        
        
        _buffer = (new ar.audio.Buffer).load("data/bgm.ogg")// loading a BGM(Music provided by OtObOx.thank you!)
                                       .range(0f, 10f);
        
        _source = (new ar.audio.Source).buffer(_buffer)
                                       .isLooping(true)
                                       .play;
    }

    private{
        ar.audio.Player _player;
        ar.audio.Buffer _buffer;
        ar.audio.Source _source;
    }
}

void main(){ar.app.run(new TestApp);}
