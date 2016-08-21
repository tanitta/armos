import armos.app;
import armos.audio;
import armos.math;
alias ar = armos;
import std.stdio;

class TestApp : ar.app.BaseApp{
    override void setup(){
        _player = new ar.audio.Player;
        
        _bufferM = new ar.audio.Buffer;
        _bufferM.load("data/se_monaural_16.wav");
        _bufferS = new ar.audio.Buffer;
        _bufferS.load("data/se_stereo_16.wav");
        
        _source = new ar.audio.Source;
        _source.buffer = _bufferM;
        _source.isLooping(true).play;
        
        _rad = 0.0f;
    }

    override void update(){
        _rad += 0.01f;
        
        import std.math;
        _sourceM.position(ar.math.Vector3f(sin(_rad), 0f, cos(_rad))*10f);
    }

    override void draw(){}
    
    private{
        ar.audio.Player _player;
        ar.audio.Buffer _bufferS;
        ar.audio.Buffer _bufferM;
        ar.audio.Source _source;
        float _rad;
    }
}

void main(){ar.app.run(new TestApp);}
