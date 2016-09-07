static import ar = armos;

class TestApp : ar.app.BaseApp{
	override void setup(){
		ar.graphics.blendMode = ar.graphics.BlendMode.Alpha;
		
		_imageLena = (new ar.graphics.Image).load("lena_std.tif");
		
		_imageDman = (new ar.graphics.Image).load("d-man.png")
                                            .setMinMagFilter(ar.graphics.TextureFilter.Nearest);
		_imageFromArray = new ar.graphics.Image;
		ubyte[100*100] array;
		ar.math.Vector2i position;
		auto center = ar.math.Vector2i(50, 50);
		foreach (int index, ref pixel; array) {
			position[0] = index%100;
			position[1] = index/100;
			pixel = 255 - cast(ubyte)( ( position-center ).norm*20 );
		}
		_imageFromArray.setFromAlignedPixels(array.ptr, 100, 100, ar.graphics.ColorFormat.Gray);
	}
	
	override void draw(){
		_imageLena.drawCropped(512, 512, 256, 256, 512, 512);
		_imageLena.draw(0, 0);
        
		ar.graphics.pushMatrix;
			ar.graphics.scale(10, 10, 1);
			_imageDman.draw(14, 5);
		ar.graphics.popMatrix;
        
		_imageFromArray.draw(300, 300);
	}
    
    private{
        ar.graphics.Image _imageLena;
        ar.graphics.Image _imageDman;
        ar.graphics.Image _imageFromArray;
    }
}

void main(){ar.app.run(new TestApp);}
