import armos.app;
import armos.audio;
import armos.math;
alias ar = armos;
import std.stdio;

class TestApp : ar.app.BaseApp{
    override void setup(){
        _player = new ar.audio.Player;
        _buffer = (new ar.audio.Buffer).load("data/bgm.ogg")
                                       .range(0f, 11f);
        
        _source = (new ar.audio.Source).buffer(_buffer)
                                       .isLooping(true)
                                       .play;
        
        _rad = 0.0f;
    }

    override void update(){
        _rad += 0.01f;
        
        import std.math;
        _source.position(ar.math.Vector3f(sin(_rad), 0f, cos(_rad))*10f);
    }

    override void draw(){}
    
    override void unicodeInputted(uint key){
        key.writeln;
    }
    
    private{
        ar.audio.Player _player;
        ar.audio.Buffer _buffer;
        ar.audio.Source _source;
        float _rad;
    }
}

void main(){ar.app.run(new TestApp);}
