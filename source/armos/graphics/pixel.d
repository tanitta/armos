module armos.graphics.pixel;
enum ColorFormat{
	Gray, 
	GrayAlpha, 
	RGB,
	BGR,
	RGBA,
	BGRA, 
}

int numColorFormatElements(ColorFormat ColorFormat){
	int num;
	switch (ColorFormat) {
		case ColorFormat.Gray:
			num = 1;
		break;
		case ColorFormat.GrayAlpha:
			num = 2;
			break;
		case ColorFormat.RGB:
			num = 3;
			break;
		case ColorFormat.BGR:
			num = 3;
			break;
		case ColorFormat.RGBA:
			num = 4;
			break;
		case ColorFormat.BGRA:
			num = 4;
			break;
		default : assert(0, "case is not defined");
	}
	return num;
}

struct Pixel(T){
	public{
		// this(int numElements){
		// 	_elements = new T[](numElements);
		// }

		this(ColorFormat colorType){
			_colorType = colorType;
			_elements = new T[](numColorFormatElements(colorType));
		}

		void element(Pixel!(T) px){
			for (int i = 0; i < _elements.length; i++) {
				_elements[i] = px.element(i);
			}
			// _elements = px.element;
		}
		
		void element(int index, T level)
		in{
			assert(index>=0);
			assert(index<_elements.length);
		}body{
			_elements[index] = level;
		}
		
		T element(int index)
		in{
			assert(index>=0);
			assert(index<_elements.length);
		}body{
			return _elements[index];
		}
		
		int numElements(){
			return numColorFormatElements(_colorType);
		}
	}
	
	private{
		T[] _elements;
		ColorFormat _colorType;
	}
}

