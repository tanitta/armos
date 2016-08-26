static import ar = armos;

class TestApp : ar.app.BaseApp{
	override void setup(){
		ar.graphics.blendMode = ar.graphics.BlendMode.Alpha;
		
		imageLena = new ar.graphics.Image;
		imageLena.load("lena_std.tif");
		
		imageDman= new ar.graphics.Image;
		imageDman.load("d-man.png");
		imageDman.setMinMagFilter(ar.graphics.TextureFilter.Nearest);
		
		imageFromArray = new ar.graphics.Image;
		ubyte[100*100] array;
		ar.math.Vector2i position;
		auto center = ar.math.Vector2i(50, 50);
		foreach (int index, ref pixel; array) {
			position[0] = index%100;
			position[1] = index/100;
			pixel = 255 - cast(ubyte)( ( position-center ).norm*20 );
		}
		imageFromArray.setFromAlignedPixels(array.ptr, 100, 100, ar.graphics.ColorFormat.Gray);
	}
	
	override void draw(){
		imageLena.drawCropped(512, 512, 256, 256, 512, 512);
		imageLena.draw(0, 0);
		
		ar.graphics.pushMatrix;
			ar.graphics.scale(10, 10, 1);
			imageDman.draw(14, 5);
		ar.graphics.popMatrix;
		
		imageFromArray.draw(300, 300);
	}
    
    private{
        ar.graphics.Image imageLena;
        ar.graphics.Image imageDman;
        ar.graphics.Image imageFromArray;
    }
}

void main(){ar.app.run(new TestApp);}
