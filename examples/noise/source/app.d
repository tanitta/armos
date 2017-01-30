static import ar = armos;
import std.stdio, std.math;

class TestApp : ar.app.BaseApp{
	override void setup(){
        import std.conv;
        auto bitmapF = ar.graphics.Bitmap!(float)();
        bitmapF.allocate(512, 512, ar.graphics.ColorFormat.Gray);
        
        immutable freq = 2f;
        float vMax = 0f;
        float vMin = 0f;
        for (int i = 0; i < bitmapF.width; i++) {
            for (int j = 0; j < bitmapF.height; j++) {
                float v = 0f;
                v += _noise.eval(i.to!float/bitmapF.width*freq, j.to!float/bitmapF.height*freq, 1f);
                v += _noise.eval(i.to!float/bitmapF.width*freq*2, j.to!float/bitmapF.height*freq*2, 1f)*0.5;
                v += _noise.eval(i.to!float/bitmapF.width*freq*4, j.to!float/bitmapF.height*freq*4, 1f)*0.25;
                v += _noise.eval(i.to!float/bitmapF.width*freq*8, j.to!float/bitmapF.height*freq*8, 1f)*0.125;
                vMax = fmax(v, vMax);
                vMin = fmin(v, vMin);
                bitmapF.pixel(i, j, 0, v);
            }
        }
        
        auto bitmap = ar.graphics.Bitmap!(char)();
        bitmap.allocate(bitmapF.width, bitmapF.height, ar.graphics.ColorFormat.RGB);
        for (int i = 0; i < bitmap.width; i++) {
            for (int j = 0; j < bitmap.height; j++) {
                float normalized = ar.math.map(bitmapF.pixel(i, j).element(0), vMin, vMax, 0f, 255f);
                bitmap.pixel(i, j, 0, normalized.to!char);
                bitmap.pixel(i, j, 1, normalized.to!char);
                bitmap.pixel(i, j, 2, normalized.to!char);
            }
        }
        
        _noiseImage = (new ar.graphics.Image).bitmap(bitmap);
	}
	
	override void draw(){
        _noiseImage.draw(0, 0);
	}
    
    private{
        ar.math.PerlinNoise!(float, 3) _noise;
        ar.graphics.Image _noiseImage;
    }
}

void main(){
    version(unittest){
    }else{
        ar.app.run(new TestApp);
    }
}
