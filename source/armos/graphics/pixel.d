module armos.graphics.pixel;
/++
    カラーフォーマットを表します．
+/
enum ColorFormat{
    Gray, 
    GrayAlpha, 
    RGB,
    BGR,
    RGBA,
    BGRA, 
    Depth, 
}

/++
    カラーフォーマットのパラメータの数を返します．
+/
int numColorFormatElements(in ColorFormat ColorFormat){
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
        case ColorFormat.Depth:
            num = GL_DEPTH_COMPONENT;
            break;
        default : assert(0, "case is not defined");
    }
    return num;
}

import derelict.opengl3.gl;
/++
    ColorFormatを元にGLで用いられる定数を返します
+/
GLuint getGLInternalFormat(in ColorFormat format){
    GLuint num;
    switch(format){
        case ColorFormat.Gray:
            num = GL_LUMINANCE;
            break;
        case ColorFormat.GrayAlpha:
            num = GL_LUMINANCE_ALPHA;
            break;
        case ColorFormat.RGB:
            num = GL_RGB;
            break;
        case ColorFormat.BGR:
            num = GL_BGR;
            break;
        case ColorFormat.RGBA:
            num = GL_RGBA;
            break;
        case ColorFormat.BGRA:
            num = GL_BGRA;
            break;
        case ColorFormat.Depth:
            num = GL_DEPTH_COMPONENT;
            break;
        default: 
            num = GL_LUMINANCE;
            break;
    }
    return num;
}

/++
    画素を表すstructです．
+/
struct Pixel(T){
    public{
        /++
            +/
            this(in ColorFormat colorType){
                _colorType = colorType;
                _elements = new T[](numColorFormatElements(colorType));
            }
        unittest{
            assert(__traits(compiles, (){
                        auto p = Pixel!float(ColorFormat.RGB);
                        }));

            assert(__traits(compiles, (){
                        const p = Pixel!float(ColorFormat.RGB);
                        }));

            assert(!__traits(compiles, (){
                        immutable p = Pixel!float(ColorFormat.RGB);
                        }));
        }

        /++
            +/
            void element(in Pixel!(T) px){
                for (int i = 0; i < _elements.length; i++) {
                    _elements[i] = px.element(i);
                }
                // _elements = px.element;
            }

        /++
            +/
            void element(in int index, in T level)
            in{
                assert(index>=0);
                assert(index<_elements.length);
            }body{
                _elements[index] = level;
            }

        /++
            +/
            T element(in int index)const
            in{
                assert(index>=0);
                assert(index<_elements.length);
            }body{
                return _elements[index];
            }
        unittest{
            auto p = Pixel!float(ColorFormat.RGB);
            p.element(0, 1.0f);
            p.element(1, 0.5f);
            p.element(2, 0.1f);
            assert(p.element(0) == 1.0f);
            assert(p.element(1) == 0.5f);
            assert(p.element(2) == 0.1f);
        }

        /++
            +/
            int numElements()const{
                return numColorFormatElements(_colorType);
            }
        unittest{
            auto p = Pixel!float(ColorFormat.RGB);
            assert(p.numElements == 3);
        }
    }

    private{
        T[] _elements;
        ColorFormat _colorType;
    }
}

