static import ar = armos;
import std.stdio, std.math;

class TestApp : ar.app.BaseApp{
	override void setup(){
		_font = new ar.graphics.BitmapFont;
		_font.load("font.png", 8, 8);
		ar.graphics.blendMode = ar.graphics.BlendMode.Alpha;
		
		_dman = new ar.graphics.Image;
		_dman.load("d-man.png");
		_dman.magFilter(ar.graphics.TextureMagFilter.Nearest);
		
		ar.graphics.background(0.25, 0.25, 0.25);
	}
	
	override void draw(){
		ar.graphics.pushMatrix;
			ar.graphics.scale(2.0, 2.0, 1.0);
			_font.draw(
				"armos is a free and open source library for\ncreative coding in D programming language.",
				50, 10
			);
			
			ar.graphics.translate(200, 80, 0);
			ar.graphics.scale(2.0, 2.0, 1.0);
			_dman.draw(0, 0);
		ar.graphics.popMatrix;
	}
    
    private{
        ar.graphics.BitmapFont _font;
        ar.graphics.Image _dman;
    }
}

void main(){
    version(unittest){
    }else{
        ar.app.run(new TestApp);
    }
}
