static import ar = armos;
import std.stdio;

class TestApp : ar.app.BaseApp{
    override void setup(){
        _player = new ar.audio.Player;
        
        _buffer = (new ar.audio.Buffer).load("data/bgm.ogg")// loading a BGM(Music provided by OtObOx.thank you!)
                                       .detectBpm(1024);
        
        _source = (new ar.audio.Source).buffer(_buffer)
                                       .isLooping(true)
                                       .play;
    }

    override void draw(){
        ar.graphics.pushMatrix;
            ar.graphics.translate(0, ar.app.windowSize.y*0.5, 0);
            ar.graphics.scale(1, -1, 1);
            foreach (int t,  ref v; _source.currentSpectrum(0, 1024).powers) {
                import std.math;
                ar.graphics.drawLine(
                    ar.math.Vector2d(t, 0),
                    ar.math.Vector2d(t, v/10000000)
                );
            }
        ar.graphics.popMatrix;
    }
    
    private{
        ar.audio.Player _player;
        ar.audio.Buffer _buffer;
        ar.audio.Source _source;
        ar.audio.Spectrum!double _bpmSpectrum;
    }
}

void main(){
    version(unittest){
    }else{
        ar.app.run(new TestApp);
    }
}
