module armos.graphics.image;

static import armos.graphics;
import armos.math;
import armos.graphics.material;;
/++
    画像のファイルフォーマットを表します
+/
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
+/
class Image {
    public{
        this(){
            if(!isInitializedFreeImage){
                DerelictFI.load();
                FreeImage_Initialise();
                isInitializedFreeImage = true;
            }
            _material = (new DefaultMaterial);
            _material.attr("diffuse", Vector4f(1, 1, 1, 1));
        }

        /++
            Load image.

            画像を読み込みます．
        +/
        Image load(string pathInDataDir){
            import std.string;
            FIBITMAP * freeImageBitmap = null;
            _bitmap = armos.graphics.Bitmap!(char)();

            static import armos.utils;
            string fileName = armos.utils.absolutePath(pathInDataDir);

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

            allocate;
            _material.texture("tex0", this._texture);
            return this;
        }


        Image drawCropped(T)(
                in T x, in T y,
                in T startX, in T startY,
                in T endX, in T endY
                ){
            drawCropped(x, y, T(0), startX, startY, endX, endY);
            return this;
        }

        Image drawCropped(T)(
                in T x, in T y, in T z,
                in T startX, in T startY,
                in T endX, in T endY
                ){
            if(_isLoaded){
                import std.conv;
                _rect.texCoords[0] = Vector4f(startX.to!float/_texture.width, startY.to!float/_texture.height, 0, 1);
                _rect.texCoords[1] = Vector4f(startX.to!float/_texture.width, endY.to!float/_texture.height,   0, 1);
                _rect.texCoords[2] = Vector4f(endX.to!float/_texture.width,   endY.to!float/_texture.height,   0, 1);
                _rect.texCoords[3] = Vector4f(endX.to!float/_texture.width,   startY.to!float/_texture.height, 0, 1);
                
                // _rect.texCoords[0] = Vector4f(0, 0, 0, 1);
                // _rect.texCoords[1] = Vector4f(0, 1, 0, 1);
                // _rect.texCoords[2] = Vector4f(1,   1,   0, 1);
                // _rect.texCoords[3] = Vector4f(1,   ,   0, 1);

                _rect.vertices[0] = Vector4f(0f,          0f,          0f, 1f);
                _rect.vertices[1] = Vector4f(0f,          endY-startY, 0f, 1f);
                _rect.vertices[2] = Vector4f(endX-startX, endY-startY, 0f, 1f);
                _rect.vertices[3] = Vector4f(endX-startX, 0f,          0f, 1f);

                armos.graphics.pushMatrix;
                armos.graphics.translate(x, y, z);
                _material.begin;
                _rect.drawFill();
                _material.end;
                armos.graphics.popMatrix;
            }
            
            return this;
        }

        /++
            Draw image data which loaded in advance.

            読み込んだ画像データを画面に描画します．
        +/
        Image draw(T)(in T x, in T y, in T z = T(0)){
            drawCropped(x, y, z, 0, 0, bitmap.width, bitmap.height);
            return this;
        }

        /++
            Draw image data which loaded in advance.

            読み込んだ画像データを画面に描画します．
        +/
        Image draw(T)(in T position)const{
            static if(position.data.length == 2)
                draw(position[0], position[1]);
            else if(position.data.length == 3)
                draw(position[0], position[1], position[2]);
            else
                static assert(0, "arg is invalid dimention");
            return this;
        }

        /++
            Return image size.

            画像のサイズを返します．
        +/
        armos.math.Vector2i size()const{return _size;}

        /++
            Return width.

            画像の幅を返します．
        +/
        int width()const{return _size[0];}

        /++
            Return height.

            画像の高さを返します．
        +/
        int height()const{return _size[1];}

        /++
            Return bitmap pointer.

            画像のビットマップデータを返します．
        +/
        armos.graphics.Bitmap!(char) bitmap(){return _bitmap;}

        /++
            Set bitmap
        +/
        Image bitmap(armos.graphics.Bitmap!(char) data){
            _bitmap = data;
            allocate();
            _isLoaded = true;
            return this;
        }

        /++
            Generate a image from the aligned pixels

            一次元配列からImageを生成します
        +/
        Image setFromAlignedPixels(T)(T* pixels, int width, int height, armos.graphics.ColorFormat format){
            _bitmap.setFromAlignedPixels(cast(char*)pixels, width, height, format);
            allocate;
            _isLoaded = true;
            _material.texture("tex0", this._texture);
            return this;
        }

        /++
            与えられたbitmapを元にtextureとrectを生成します
        +/
        Image allocate(){
            _texture = new armos.graphics.Texture;
            _texture.allocate(_bitmap);
            _rect = new armos.graphics.Mesh;
            _rect.primitiveMode = armos.graphics.PrimitiveMode.TriangleStrip ;
            float x = _bitmap.width;
            float y = _bitmap.height;
            
            _rect.vertices = [
                Vector4f(0.0, 0.0, 0.0, 1.0f),
                Vector4f(0.0, y,   0.0, 1.0f),
                Vector4f(x,   y,   0.0, 1.0f),
                Vector4f(x,   0.0, 0.0, 1.0f),
            ];
            
            _rect.texCoords0= [
                Vector4f(0f, 0f,  0f, 1f),
                Vector4f(0,                                1f*_bitmap.height/_texture.height,  0f, 1f),
                Vector4f(1f*_bitmap.width/_texture.width,  1f*_bitmap.height/_texture.height,  0f, 1f),
                Vector4f(1f*_bitmap.width/_texture.width,  0,  0f, 1f),
            ];

            _rect.indices = [
                0, 1, 2,
                2, 3, 0,
            ];
            return this;
        }

        /++
            Retun true if the image was loaded.

            画像が読み込まれている場合trueを，そうでない場合はfalseを返します．
        +/
        bool isLoaded()const{
            return _isLoaded;
        }

        /++
        +/
        armos.graphics.Texture texture(){
            return _texture;
        }

        /++
        +/
        Image minMagFilter(in armos.graphics.TextureMinFilter minFilter, in armos.graphics.TextureMagFilter magFilter){
            _texture.minMagFilter(minFilter, magFilter);
            return this;
        }

        /++
        +/
        Image minFilter(in armos.graphics.TextureMinFilter filter){
            _texture.minFilter(filter);
            return this;
        }
        
        ///
        Image magFilter(in armos.graphics.TextureMagFilter filter){
            _texture.magFilter(filter);
            return this;
        }
        
        ///
        Material material(){
            return _material;
        }
    }//public

    private{
        static bool isInitializedFreeImage = false;
        armos.math.Vector2i _size;
        armos.graphics.Bitmap!(char) _bitmap;
        armos.graphics.Texture _texture;
        armos.graphics.Mesh _rect;
        bool _isLoaded = false;
        Material _material;

        /++
            ImageのbitmapにfreeImageのbitmapを指定します．
        +/
        void bitmap(FIBITMAP* freeImageBitmap, bool swapForLittleEndian = true){
            FREE_IMAGE_TYPE imageType = FreeImage_GetImageType(freeImageBitmap);

            uint bits = char.sizeof;

            import std.stdio;
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
                    armosColorFormat = armos.graphics.ColorFormat.RGB;
                    break;
                case 4:
                    armosColorFormat = armos.graphics.ColorFormat.RGBA;
                    break;
                default:
                    break;
            }

            FreeImage_FlipVertical(freeImageBitmap);
            char* bitmapBits = cast(char*)FreeImage_GetBits(freeImageBitmap);

            _bitmap.setFromAlignedPixels(bitmapBits, width, height, armosColorFormat);
            _bitmap.swapRAndB;
            _size = _bitmap.size;
        }
    }//private
}//class Image
