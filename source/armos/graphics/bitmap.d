module armos.graphics.bitmap;
import armos.math;
import armos.graphics;
struct Bitmap(T){
	public{
		void allocate(armos.math.Vector2i size, armos.graphics.PixelType pixelType){
			allocate(size[0], size[1], pixelType);
		}
		
		void allocate(int width, int height, armos.graphics.PixelType pixelType){
			auto arraySize = width * height;
			for (int i = 0; i < arraySize; i++) {
				_data ~= armos.graphics.Pixel!T(pixelType);
			}
		}
		
		void setAllPixels(int index, T level){
			foreach (pixel; _data) {
				pixel.element(index, level);
			}
		};
	}
	
	private{
		armos.math.Vector2i _size;
		armos.graphics.Pixel!(T)[] _data;
	}
}

// alias Bitmap(T) Bitmap;
