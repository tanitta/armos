module armos.graphics.bitmap;
import armos.math;
import armos.graphics;
struct Bitmap(T){
	private{
		armos.math.Vector2i _size;
		armos.graphics.Pixel!(T)[] _data;
	}
}

// alias Bitmap(T) Bitmap;
