module armos.graphics.bitmap;
import armos.math;
import armos.graphics;
import std.experimental.ndslice;
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
        Bitmap allocate(armos.math.Vector2i size, armos.graphics.ColorFormat colorType){
            _colorFormat = colorType;
            allocate(size[0], size[1], colorType);
            return this;
        }

        /++
            領域を確保します．
            Params:
            width = Bitmapの横幅です．
            height = Bitmapの縦幅です．
            colorType = Bitmapのカラーフォーマットを指定します．
        +/
        Bitmap allocate(int width, int height, armos.graphics.ColorFormat colorType){
            import std.array:appender;
            _size[0] = width;
            _size[1] = height;
            _colorFormat = colorType;
            auto arraySize = width * height;
            _data = new armos.graphics.Pixel!(T)[arraySize];
            for (int i = 0; i < arraySize; i++) {
                _data[i] = armos.graphics.Pixel!T(colorType);
            }
            return this;
        }

        /++
            Set value to all pixels for the given index.

            全てのピクセルのindexで与えられた画素に値を代入します
        +/
        Bitmap setAllPixels(int index, T level){
            foreach (pixel; _data) {
                pixel.element(index, level);
            }
            return this;
        };

        /++
            Set value to the pixel for the given index and position.

            positionとindexで指定された画素に値を代入します．
        +/
        Bitmap pixel(in int x, in int y, in int index, in T value){
            _data[x+y*_size[0]].element(index, value);
            return this;
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
        Bitmap pixel(in int x, in int y, armos.graphics.Pixel!(T) pixel){
            _data[x+y*_size[0]].element(pixel);
            return this;
        };


        /++
            Paste a arg bitmap into this for the given position.

            bitmapを指定した座標に貼り付けます．
        +/
        Bitmap pasteInto(ref Bitmap!(T) targetBitmap, in int x, in int y){
            for (int i = 0; i < size[0]; i++) {
                for (int j = 0; j < size[1]; j++) {
                    targetBitmap.pixel(i+x, j+y, pixel(i, j));
                }
            }
            return this;
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
        Bitmap setFromAlignedPixels(T* pixels, int width, int height, armos.graphics.ColorFormat format){
            allocate(width, height, format);
            auto size = width * height;
            auto numChannels = armos.graphics.numColorFormatElements(format);
            for (int i = 0; i < size*numChannels; i += numChannels) {
                for (int channel = 0; channel < numChannels; channel++){
                    _data[i/numChannels].element(channel, pixels[channel+i]);
                }
            }
            return this;
        }
        

        /++
            RとBのチャンネルを入れ替えます．
        +/
        Bitmap swapRAndB(){
            if(numElements < 3){assert(0);}
            foreach (ref pixel; _data) {
                auto r = pixel.element(0);
                auto b = pixel.element(2);
                pixel.element(0, b);
                pixel.element(2, r);
            }
            return this;
        }

        /++
            Bitmapのカラーフォーマットを返します．
        +/
        ColorFormat colorFormat()const{
            return _colorFormat;
        }
        
        
        ///
        Slice!(3LU, V*) sliced(V = float)(){
            import std.array:appender;
            auto app = appender!(V[]);
            import std.range;
            import std.algorithm;
            import std.conv;
            foreach (ref pixel; _data) {
                foreach (ref index; numElements.iota.array) {
                    static if(__traits(isFloating, T)){
                        app.put(pixel.element(index));
                    }else{
                        import std.conv;
                        app.put(pixel.element(index).to!V/T.max.to!V);
                    }
                }
            }
            return app.data.sliced(_size[0], _size[1], numElements);
        }
    }

    private{
        armos.math.Vector2i _size;
        armos.graphics.Pixel!(T)[] _data;
        armos.graphics.ColorFormat _colorFormat;
    }
}

///
Bitmap!T asBitmap(T, S)(S slice, in armos.graphics.ColorFormat colorFormat){
    Bitmap!T bitmap;
    import std.conv;
    bitmap.allocate(slice.length!1.to!int, slice.length!0.to!int, colorFormat);
    for (size_t x = 0; x < slice.length!1; x++) {
        for (size_t y = 0; y < slice.length!0; y++) {
            for (size_t e = 0; e < slice.length!2; e++) {
                alias SliceElement = DeepElementType!(S);
                size_t index = x+y*(slice.length!1);
                T level;
                static if(__traits(isFloating, T)){
                    static if(__traits(isFloating, SliceElement)){
                        level = slice[y, x, e];
                    }else{
                        level = slice[y, x, e].to!float/SliceElement.max.to!float;
                    }
                }else{
                    static if(__traits(isFloating, SliceElement)){
                        level = (slice[y, x, e]*T.max.to!SliceElement).to!T;
                    }else{
                        level = slice[y, x, e].to!T;
                    }
                }
                bitmap._data[index].element(e.to!int, level);
            }
        }
    }
    return bitmap;
}

unittest{
    Bitmap!char bitmapA;
    bitmapA.allocate(4, 4, ColorFormat.RGBA)
           .pixel(0, 0, 0, 22)
           .pixel(1, 0, 0, 128)
           .pixel(2, 0, 1, 32);
    
    auto slice = bitmapA.sliced!float;
    auto bitmapB = slice.asBitmap!char(ColorFormat.RGBA);
    
    assert(bitmapA.pixel(0, 0) == bitmapB.pixel(0, 0));
    assert(bitmapA.pixel(1, 0) == bitmapB.pixel(1, 0));
    assert(bitmapA.pixel(2, 0) == bitmapB.pixel(2, 0));
}

unittest{
    Bitmap!char bitmap;
    bitmap.allocate(4, 4, ColorFormat.RGBA)
          .pixel(0, 0, 0, 0)
          .pixel(1, 0, 0, 0)
          .pixel(2, 0, 1, 0);
    
    auto slice = bitmap.sliced!float;
    assert(slice[0, 0, 0] == 0.0f);
    assert(slice[0, 1, 0] == 0.0f);
    assert(slice[0, 2, 1] == 0.0f);
}

unittest{
    Bitmap!float bitmap;
    bitmap.allocate(4, 4, ColorFormat.RGBA)
          .pixel(0, 0, 0, 0.5f)
          .pixel(1, 0, 0, 0.5f)
          .pixel(2, 0, 1, 0.5f);
    
    auto slice = bitmap.sliced!float;
    assert(slice[0, 0, 0] == 0.5f);
    assert(slice[0, 1, 0] == 0.5f);
    assert(slice[0, 2, 1] == 0.5f);
}

