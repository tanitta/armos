import armos;

class TestApp : ar.BaseApp{
	ar.Image imageLena;
	ar.Image imageDman;
	ar.Image imageFromArray;
	
	void setup(){
		ar.blendMode = ar.BlendMode.Alpha;
		
		imageLena = new ar.Image;
		imageLena.load("lena_std.tif");
		
		imageDman= new ar.Image;
		imageDman.load("d-man.png");
		imageDman.setMinMagFilter(ar.TextureFilter.Nearest);
		
		imageFromArray = new ar.Image;
		ubyte[100*100] array;
		ar.Vector2i position;
		auto center = ar.Vector2i(50, 50);
		foreach (int index, ref pixel; array) {
			position[0] = index%100;
			position[1] = index/100;
			pixel = 255 - cast(ubyte)( ( position-center ).norm*20 );
		}
		imageFromArray.setFromAlignedPixels(array.ptr, 100, 100, ar.ColorFormat.Gray);
	}
	
	void draw(){
		imageLena.drawCropped(512, 512, 256, 256, 512, 512);
		imageLena.draw(0, 0);
		
		ar.pushMatrix;
			ar.scale(10, 10, 1);
			imageDman.draw(14, 5);
		ar.popMatrix;
		
		imageFromArray.draw(300, 300);
	}
}

void main(){ar.run(new TestApp);}
