static import ar = armos;
import std.stdio;

class TestApp : ar.app.BaseApp{
    override void setup(){
        _recorder = (new ar.audio.Recorder).start;
    }
    
    override void update(){
        _recorder.update;
    }

    override void draw(){
        ar.graphics.pushMatrix;
            ar.graphics.translate(0, ar.app.windowSize.y*0.5, 0);
            ar.graphics.scale(1, -1, 1);
            foreach (int t,  ref v; _recorder.buffer[0.._recorder.samples]) {
                ar.graphics.drawLine(
                    ar.math.Vector2d(t, -v/4),
                    ar.math.Vector2d(t, v/4+1)
                );
            }
        ar.graphics.popMatrix;
    }
    
    private{
        ar.audio.Recorder _recorder;
        ar.audio.Spectrum!double _bpmSpectrum;
    }
}

void main(){
    version(unittest){
    }else{
        ar.app.run(new TestApp);
    }
}
