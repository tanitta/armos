module armos.graphics.pixel;
enum PixelType{
	Gray, 
	GrayAlpha, 
	RGB,
	BGR,
	RGBA,
	BGRA, 
}

int numPixelTypeElements(PixelType pixelType){
	int num;
	switch (pixelType) {
		case PixelType.Gray:
			num = 1;
			break;
		case PixelType.GrayAlpha:
			num = 2;
			break;
		case PixelType.RGB:
			num = 3;
			break;
		case PixelType.BGR:
			num = 3;
			break;
		case PixelType.RGBA:
			num = 4;
			break;
		case PixelType.BGRA:
			num = 4;
			break;
		default : assert(0, "case is not defined");
	}
	return num;
}

struct Pixel(T){
	public{
		this(int numElements){
			elements_ = new T[](numElements);
		}

		this(PixelType pixelType){
			this(numPixelTypeElements(pixelType));
		}

		void element(int index, T level)
		in{
			assert(index>=0);
			assert(index<elements.length);
		}body{
			elements_[index] = level;
		}
		
		T element(int index)
		in{
			assert(index>=0);
			assert(index<elements.length);
		}body{
			return elements_[index];
		}
	}
	
	private{
		T[] elements_;
	}
}

