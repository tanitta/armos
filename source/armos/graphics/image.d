module armos.graphics.image;
enum ImageFormat{
	BMP     = 0,
	ICO     = 1,
	JPEG    = 2,
	JNG     = 3,
	KOALA   = 4,
	LBM     = 5,
	IFF     = LBM,
	MNG     = 6,
	PBM     = 7,
	PBMRAW  = 8,
	PCD     = 9,
	PCX     = 10,
	PGM     = 11,
	PGMRAW  = 12,
	PNG     = 13,
	PPM     = 14,
	PPMRAW  = 15,
	RAS     = 16,
	TARGA   = 17,
	TIFF    = 18,
	WBMP    = 19,
	PSD     = 20,
	CUT     = 21,
	XBM     = 22,
	XPM     = 23,
	DDS     = 24,
	GIF     = 25,
	HDR     = 26,
	FAXG3   = 27,
	SGI     = 28,
	EXR     = 29,
	J2K     = 30,
	JP2     = 31,
	PFM     = 32,
	PICT    = 33,
	RAW     = 34
}


import derelict.freeimage.freeimage;

/++
	画像を表すクラスです．
	load()で画像を読み込み，draw()で表示することができます．
++/
class Image {
	public{
		this(){
			if(!isInitializedFreeImage){
				DerelictFI.load();
				FreeImage_Initialise();
				isInitializedFreeImage = true;
			}
		}
		
		/++
			Load image.
			
			画像を読み込みます．
		++/
		void load(string localPathInDataDir){
			import std.string;
			FIBITMAP * freeImageBitmap = null;
			_bitmap = armos.graphics.Bitmap!(char)();
			auto fileName = armos.utils.toDataPath(localPathInDataDir);
			
			FREE_IMAGE_FORMAT freeImageFormat = FIF_UNKNOWN;
			freeImageFormat = FreeImage_GetFileType(fileName.toStringz , 0);
			
			if(freeImageFormat == FIF_UNKNOWN) {
				freeImageFormat = FreeImage_GetFIFFromFilename(fileName.toStringz);
			}
			if((freeImageFormat != FIF_UNKNOWN) && FreeImage_FIFSupportsReading(freeImageFormat)) {
				freeImageBitmap = FreeImage_Load(freeImageFormat, fileName.toStringz, 0);
				if (freeImageBitmap != null){
					_isLoaded = true;
				}
			}
			
			if ( _isLoaded ){
				//TODO: bring freeImageBitmap to armos.graphics.Bitmap
				bitmap(freeImageBitmap);
			}
			
			if (freeImageBitmap != null){
				FreeImage_Unload(freeImageBitmap);
			}
			
			_texture = new armos.graphics.Texture;
			_texture.allocate(_bitmap);
			_rect = new armos.graphics.Mesh;
			_rect.primitiveMode = armos.graphics.PrimitiveMode.Quads;
			float x = _bitmap.width;
			float y = _bitmap.height;

			_texture.begin;
				_rect.addTexCoord(0, 0);_rect.addVertex(0, 0, 0);
				_rect.addTexCoord(1.0*_bitmap.height/_texture.height, 0);_rect.addVertex(0, y, 0);
				_rect.addTexCoord(1.0*_bitmap.height/_texture.height, 1.0);_rect.addVertex(x, y, 0);
				_rect.addTexCoord(0, 1.0);_rect.addVertex(x, 0, 0);
			_texture.end;

			_rect.addIndex(0);
			_rect.addIndex(1);
			_rect.addIndex(2);
			_rect.addIndex(3);
		}
		
		/++
			Draw image data which loaded in advance.
			
			読み込んだ画像データを画面に描画します．
		++/
		void draw(T)(in T x, in T y, in T z = T(0)){
			armos.graphics.pushMatrix;
			armos.graphics.translate(x, y, z);
			_texture.begin;
			_rect.drawFill();
			_texture.end;
			armos.graphics.popMatrix;
			
		}
		
		/++
			Draw image data which loaded in advance.
			
			読み込んだ画像データを画面に描画します．
		++/
		void draw(T)(in T position)const{
			static if(position.data.length == 2)
				draw(position[0], position[1]);
			else if(position.data.length == 3)
				draw(position[0], position[1], position[2]);
			else
				static assert(0, "arg is invalid dimention");
		}
		
		/++
			Return image size.
			
			画像のサイズを返します．
		++/
		armos.math.Vector2i size()const{return _size;}
		
		/++
			Return width.
			
			画像の幅を返します．
		++/
		int width()const{return _size[0];}
		
		/++
			Return height.
			
			画像の高さを返します．
		++/
		int height()const{return _size[1];}
		
		/++
			Return bitmap pointer.
			
			画像のビットマップデータを返します．
		++/
		ref armos.graphics.Bitmap!(char) bitmap(){return _bitmap;}
		
		/++
			Retun true if the image was loaded.

			画像が読み込まれている場合trueを，そうでない場合はfalseを返します．
		++/
		bool isLoaded(){
			return _isLoaded;
		}
	}//public

	private{
		armos.math.Vector2i _size;
		armos.graphics.Bitmap!(char) _bitmap;
		armos.graphics.Texture _texture;
		armos.graphics.Mesh _rect;
		bool _isLoaded = false;
		static bool isInitializedFreeImage = false;
		
		/++
			ImageのbitmapにfreeImageのbitmapを指定します．
		++/
		void bitmap(FIBITMAP* freeImageBitmap, bool swapForLittleEndian = true){
			FREE_IMAGE_TYPE imageType = FreeImage_GetImageType(freeImageBitmap);
			
			uint bits = char.sizeof;
			
			FIBITMAP* bitmapConverted;
			bitmapConverted = FreeImage_ConvertTo32Bits(freeImageBitmap);
			freeImageBitmap = bitmapConverted;
			
			uint width = FreeImage_GetWidth(freeImageBitmap);
			uint height = FreeImage_GetHeight(freeImageBitmap);
			uint bpp = FreeImage_GetBPP(freeImageBitmap);
			uint channels = (bpp / bits) / 8;
			uint pitch = FreeImage_GetPitch(freeImageBitmap);
			
			armos.graphics.ColorFormat armosColorFormat;
			switch (channels) {
				case 1:
					armosColorFormat = armos.graphics.ColorFormat.Gray;
					break;
				case 2:
					armosColorFormat = armos.graphics.ColorFormat.Gray;
					break;
				case 3:
					armosColorFormat = armos.graphics.ColorFormat.BGR;
					break;
				case 4:
					armosColorFormat = armos.graphics.ColorFormat.BGRA;
					break;
				default:
					break;
			}
			
			FreeImage_FlipVertical(freeImageBitmap);
			char* bitmapBits = cast(char*)FreeImage_GetBits(freeImageBitmap);
				
			_bitmap.setFromAlignedPixels(bitmapBits, width, height, armosColorFormat);
			_bitmap.swapRAndB;
		}
	}//private
}//class Image
