module armos.graphics.bitmap;
import armos.math;
import armos.graphics;
/++
Bitmapデータを表すstructです．
画素を表すPixelの集合で構成されます．
+/
struct Bitmap(T){
    public{
        /++
            領域を確保します．
            Params:
            size = Bitmapのサイズです．
            colorType = Bitmapのカラーフォーマットを指定します．
        +/
        void allocate(armos.math.Vector2i size, armos.graphics.ColorFormat colorType){
            _colorFormat = colorType;
            allocate(size[0], size[1], colorType);
        }

        /++
            領域を確保します．
            Params:
            width = Bitmapの横幅です．
            height = Bitmapの縦幅です．
            colorType = Bitmapのカラーフォーマットを指定します．
        +/
        void allocate(int width, int height, armos.graphics.ColorFormat colorType){
            _size[0] = width;
            _size[1] = height;
            _colorFormat = colorType;
            auto arraySize = width * height;
            _data = [];
            for (int i = 0; i < arraySize; i++) {
                _data ~= armos.graphics.Pixel!T(colorType);
            }
        }

        /++
            Set value to all pixels for the given index.

            全てのピクセルのindexで与えられた画素に値を代入します
        +/
        void setAllPixels(int index, T level){
            foreach (pixel; _data) {
                pixel.element(index, level);
            }
        };

        /++
            Set value to the pixel for the given index and position.

            positionとindexで指定された画素に値を代入します．
        +/
        void pixel(in int x, in int y, in int index, in T value){
            _data[x+y*_size[0]].element(index, value);
        };

        /++
            Return the pixel for the given position.

            positionで指定された座標のpixelを返します．
        +/
        armos.graphics.Pixel!(T) pixel(in int x, in int y){
            return _data[x+y*_size[0]];
        };

        /++
            Set pixel to the pixel for the given position.

            positionで指定された座標のpixelにpixelを設定します．
        +/
        void pixel(in int x, in int y, armos.graphics.Pixel!(T) pixel){
            _data[x+y*_size[0]].element(pixel);
        };


        /++
            Paste a arg bitmap into this for the given position.

            bitmapを指定した座標に貼り付けます．
        +/
        void pasteInto(ref Bitmap!(T) targetBitmap, in int x, in int y){
            for (int i = 0; i < size[0]; i++) {
                for (int j = 0; j < size[1]; j++) {
                    targetBitmap.pixel(i+x, j+y, pixel(i, j));
                }
            }
        }

        /++
            Return the bitmap size;
        +/
        armos.math.Vector2i size()const{
            return _size;
        }

        /++
            Return width.

            bitmapの幅を返します．
        +/
        int width()const{return _size[0];}

        /++
            Return height.

            bitmapの高さを返します．
        +/
        int height()const{return _size[1];}

        /++
            Return the number of Elements.

            pixelの要素の数を返します．
        +/
        int numElements()const{
            return armos.graphics.numColorFormatElements(_colorFormat);
        }

        /++
            Generate a bitmap from the aligned pixels

            一次元配列からBitmapを生成します
        +/
        void setFromAlignedPixels(T* pixels, int width, int height, armos.graphics.ColorFormat format){
            allocate(width, height, format);
            auto size = width * height;
            auto numChannels = armos.graphics.numColorFormatElements(format);
            for (int i = 0; i < size*numChannels; i += numChannels) {
                for (int channel = 0; channel < numChannels; channel++){
                    _data[i/numChannels].element(channel, pixels[channel+i]);
                }
            }
        }

        /++
            RとBのチャンネルを入れ替えます．
        +/
        void swapRAndB(){
            if(numElements < 3){assert(0);}
            foreach (ref pixel; _data) {
                auto r = pixel.element(0);
                auto b = pixel.element(2);
                pixel.element(0, b);
                pixel.element(2, r);
            }
        }

        /++
            Bitmapのカラーフォーマットを返します．
        +/
        armos.graphics.ColorFormat colorFormat()const{
            return _colorFormat;
        }
    }

    private{
        armos.math.Vector2i _size;
        armos.graphics.Pixel!(T)[] _data;
        armos.graphics.ColorFormat _colorFormat;
    }
}
