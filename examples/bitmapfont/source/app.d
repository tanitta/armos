import armos, std.stdio, std.math;

class TestApp : ar.BaseApp{
	ar.BitmapFont font;
	ar.Image dman;
	void setup(){
		font = new ar.BitmapFont;
		font.load("font.png", 8, 8);
		ar.blendMode = ar.BlendMode.Alpha;
		
		dman = new ar.Image;
		dman.load("d-man.png");
		dman.setMinMagFilter(ar.TextureFilter.Nearest);
		
		ar.setBackground(64, 64, 64);
	}
	
	void update(){
	}
	
	void draw(){
		ar.pushMatrix;
			ar.scale(2.0, 2.0, 1.0);
			font.draw(
				"armos is a free and open source library for\ncreative coding in D programming language.",
				50, 10
			);
			
			ar.translate(200, 80, 0);
			ar.scale(2.0, 2.0, 1.0);
			dman.draw(0, 0);
		ar.popMatrix;
	}
}

void main(){ar.run(new TestApp);}
