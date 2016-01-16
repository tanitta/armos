module armos.graphics.bitmapfont;
import armos.graphics;;
import armos.math;

/++
++/
class BitmapFont {
	public{
		/++
		++/
		this(){
			_image = new armos.graphics.Image;
		}
		
		/++
		++/
		void load(in string fileName, in int fontWidth, in int fontHeight){
			_image.load(fileName);
			_image.setMinMagFilter(armos.graphics.TextureFilter.Nearest);
			width = fontWidth;
			height = fontHeight;
		};
		
		/++
		++/
		void draw(in string str, in int x, in int y, in int z = 0){
			if(str == ""){return;}
			
			int currentPosition = 0;
			
			import std.string;
			import std.algorithm;
			import std.conv;
			import std.array;
			string[] lines = str.split("\n");
			
			armos.graphics.pushMatrix;
			armos.graphics.translate(x, y, z);
			foreach (line; lines) {
				armos.graphics.pushMatrix;
				armos.graphics.translate(0, currentPosition*height, 0);
				drawLine(line);
				armos.graphics.popMatrix;
				currentPosition += 1;
			}
			armos.graphics.popMatrix;
		}
		
		/++
		++/
		int width(){
			return _size[0];
		}
		
		/++
		++/
		void width(int w){
			_size[0] = w;
		}
		
		/++
		++/
		int height(){
			return _size[1];
		}
		
		/++
		++/
		void height(int h){
			_size[1] = h;
		}
		
		int tabWidth= 4;
		
		void alignLeft(){_align = armos.graphics.TextAlign.Left;}
		void alignCenter(){_align = armos.graphics.TextAlign.Center;}
		void alignRight(){_align = armos.graphics.TextAlign.Right;}
		
	}//public

	private{
		armos.graphics.Image _image;
		armos.math.Vector2i _size;
		armos.graphics.TextAlign _align = armos.graphics.TextAlign.Left;
	
		void drawLine(in string str){
			import std.string;
			import std.algorithm;
			import std.conv;
			import std.array;
			char[] characters = str.split("").map!(to!char).array;
			int currentPosition = 0;
			foreach (character; characters) {
				switch (character) {
					case '\t':
						currentPosition += tabWidth;
						break;
					default:
						drawCharacter(character, currentPosition, 0);
						currentPosition += 1;
						break;
				}
			}
		}

		void drawCharacter(in char character, in int x, in int y){
			int textureX = character%16*width;
			int textureY = character/16*height;
			_image.drawCropped(x*width, y*height, textureX, textureY, textureX+width, textureY+height);

		}
	}//private
}//class BitmapFont

enum TextAlign{
	Left,
	Right,
	Center
};
