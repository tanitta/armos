module armos.graphics.gl.texture;

import derelict.opengl3.gl;
import armos.math.vector;
import armos.graphics;
import armos.graphics.pixel:ColorFormat;
import armos.graphics.bitmap:Bitmap;

/++
    openGLのtextureを表すクラスです．
    初期化後，allocateして利用します．
    Example:
    ---
        auto texture = new Texture;
        texture.allocate(256, 256);
        
        auto rect = new Mesh;
        rect.primitiveMode = PrimitiveMode.Quads;
        texture.begin;
            rect.addTexCoord(0, 1);rect.addVertex(0, 0, 0);
            rect.addTexCoord(0, 0);rect.addVertex(0, 1, 0);
            rect.addTexCoord(1, 0);rect.addVertex(1, 1, 0);
            rect.addTexCoord(1, 1);rect.addVertex(1, 0, 0);
        texture.end;
        
        rect.addIndex(0);
        rect.addIndex(1);
        rect.addIndex(2);
        rect.addIndex(3);
        
        texture.begin;
            rect.drawFill();
        texture.end;
    ---
+/
class Texture {
    public{
        /++
        +/
        this(TextureTarget target = TextureTarget.Dim2){
            _target = target;
            glEnable(GL_TEXTURE);
            glGenTextures(1 , cast(uint*)&_id);
        }

        ~this(){
            glDeleteTextures(1 , cast(uint*)&_id);
        }

        /++
            Return the texture size.

            textureのサイズを返します．
        +/
        Vector2i size()const{return _size;}

        /++
        +/
        int width()const{
            return size[0];
        }

        /++
        +/
        int height()const{
            return size[1];
        }

        /++
            Return gl texture id.
        +/
        int id()const{return _id;}

        ///
        TextureTarget target()const{
            return _target;
        } 

        /++
            Begin to bind the texture.
        +/
        Texture begin(){
            import armos.app.runner:currentContext;
            import armos.graphics.gl.context.helper.texture;
            currentContext.pushTexture(this);
            return this;
        }

        /++
            End to bind the texture.
        +/
        Texture end(){
            import armos.app.runner:currentContext;
            import armos.graphics.gl.context.helper.texture;
            currentContext.popTexture(_target);
            return this;
        }
        
        /++
            Resize texture.
        +/
        Texture resize(in Vector2i textureSize){
            _size = textureSize;
            allocate;
            return this;
        };

        /++
            Return pixel of texture
            Deprecated:
        +/
        ubyte pixel(){
            assert(_bitsPtr!=null);
            return 0x00;
        }

        /++
            Set pixel of texture
        +/
        Texture pixel(in ubyte v){
            assert(_bitsPtr!=null);
            return this;
        }

        /++
            Allocate texture
            Params:
            w = width
            h = height
        +/
        Texture allocate(in int w, in int h){
            _size[0] = w;
            _size[1] = h;
            allocate;
            return this;
        }

        /++
            Allocate texture
            Params:
            w = width
            h = height
        +/
        Texture allocate(in int w, in int h, ColorFormat format){
            _size[0] = w;
            _size[1] = h;
            _format = format;
            allocate;
            return this;
        }

        /++
            Allocate texture
            Params:
            bitmap =
        +/
        Texture allocate(Bitmap!(char) bitmap){
            import std.math;
            import std.array:appender;
            
            auto bitsApp = appender!(ubyte[]);
            if(bitmap.width != bitmap.height){
                int side = cast( int )fmax(bitmap.width, bitmap.height);
                Bitmap!(char) squareBitmap;
                squareBitmap.allocate(side, side, bitmap.colorFormat);
                for (int j = 0; j < bitmap.size[1]; j++) {
                    for (int i = 0; i < bitmap.size[0]; i++) {
                        squareBitmap.pixel(i, j, bitmap.pixel(i, j));
                    }
                }
                for (int j = 0; j < squareBitmap.size[1]; j++) {
                    for (int i = 0; i < squareBitmap.size[0]; i++) {
                        for (int k = 0; k < squareBitmap.numElements; k++) {
                            bitsApp.put(squareBitmap.pixel(i, j).element(k));
                        }
                    }
                }
                allocate(bitsApp.data, squareBitmap.size[0], squareBitmap.size[1], squareBitmap.colorFormat);
            }else{
                for (int j = 0; j < bitmap.size[1]; j++) {
                    for (int i = 0; i < bitmap.size[0]; i++) {
                        for (int k = 0; k < bitmap.numElements; k++) {
                            bitsApp.put(bitmap.pixel(i, j).element(k));
                        }
                    }
                }
                allocate(bitsApp.data, bitmap.size[0], bitmap.size[1], bitmap.colorFormat);
            }
            return this;
        }

        /++
            Allocate texture
            Params:
            w    = width
            h    = height
            bits = image data
        +/
        Texture allocate(ubyte[] bits, in int w, in int h, in ColorFormat format){
            _size[0] = w;
            _size[1] = h;
            _bitsPtr = bits.ptr;
            allocate(format);
            return this;
        }

        /++
            Allocate texture
        +/
        Texture allocate(in ColorFormat format){
            _format = format;
            allocate();
            return this;
        }

        /++
            Allocate texture
        +/
        Texture allocate(){
            GLuint internalFormat = getGLInternalFormat(_format);
            begin;scope(exit)end;
            glTexParameteri( _target, GL_TEXTURE_MIN_FILTER, _minFilter);
            glTexParameteri( _target, GL_TEXTURE_MAG_FILTER, _magFilter);
            if(_target.isOperatableWith1D){
                assert(false, "1D texture is not supported yet.");
            } 
            if(_target.isOperatableWith2D){
                glTexImage2D(
                    _target, 0, internalFormat,
                    _size[0], _size[1],
                    0, internalFormat, GL_UNSIGNED_BYTE, cast(GLvoid*)_bitsPtr
                );
                return this;
            }
            if(_target.isOperatableWith3D){
                assert(false, "3D texture is not supported yet.");
            }
            return this;
        }

        /++
        +/
        Texture minMagFilter(in TextureMinFilter minFilter, in TextureMagFilter magFilter){
            _minFilter = minFilter;
            _magFilter = magFilter;
            begin; 
            glTexParameteri( _target, GL_TEXTURE_MIN_FILTER, minFilter);
            glTexParameteri( _target, GL_TEXTURE_MAG_FILTER, magFilter);
            end;
            return this;
        }

        /++
        +/
        Texture minFilter(in TextureMinFilter filter){
            _minFilter = filter;
            begin;
            glTexParameteri( _target, GL_TEXTURE_MIN_FILTER, filter);
            end;
            return this;
        }
        
        ///
        Texture magFilter(in TextureMagFilter filter){
            _magFilter = filter;
            begin;
            glTexParameteri( _target, GL_TEXTURE_MAG_FILTER, filter);
            end;
            return this;
        }
        
        ///
        Texture wrap(in TextureWrap p){
            begin;
            glTexParameteri(_target, GL_TEXTURE_WRAP_S, p);
            glTexParameteri(_target, GL_TEXTURE_WRAP_T, p);
            end;
            return this;
        }
        
        ///
        Texture wrapS(in TextureWrap p){
            begin;
            glTexParameteri(_target, GL_TEXTURE_WRAP_S, p);
            end;
            return this;
        }
        
        ///
        Texture wrapT(in TextureWrap p){
            begin;
            glTexParameteri(_target, GL_TEXTURE_WRAP_T, p);
            end;
            return this;
        }
    }

    package{
        Texture bind(){
            return Texture.bind(this);
        }

        Texture bind(in TextureTarget target){
            return Texture.bind(this, target);
        }

        static Texture bind(Texture texture){
            return Texture.bind(texture, texture._target);
        }

        static Texture bind(Texture texture, in TextureTarget target){
            if(!texture){
                glBindTexture(target, 0);
                return texture;
            }
            glBindTexture(target, texture._id);
            return texture;
        }
    }

    private{
        int _id;
        ubyte* _bitsPtr;
        Vector2i _size;
        TextureTarget _target;
        ColorFormat _format;
        TextureMinFilter _minFilter;
        TextureMagFilter _magFilter;
    }
}

private bool isOperatableWith1D(in TextureTarget target){
    return target == TextureTarget.Dim1;
}

private bool isOperatableWith2D(in TextureTarget target){
    return target == TextureTarget.Dim2
        || target == TextureTarget.Dim1Array
        || target == TextureTarget.Rectangle;
}

private bool isOperatableWith3D(in TextureTarget target){
    return target == TextureTarget.Dim3 || target == TextureTarget.Dim2Array;
}

/++
+/
enum TextureMinFilter{
    Linear = GL_LINEAR,
    Nearest = GL_NEAREST, 
    NearestMipmapNearest = GL_NEAREST_MIPMAP_NEAREST,
    NearestMipmapLinear  = GL_NEAREST_MIPMAP_LINEAR,
    LinearMipmapNearest  = GL_LINEAR_MIPMAP_NEAREST,
    LinearMipmapLinear   = GL_LINEAR_MIPMAP_LINEAR,
}

///
enum TextureMagFilter{
    Linear = GL_LINEAR,
    Nearest = GL_NEAREST, 
}


///
enum TextureWrap{
    Clamp  = GL_CLAMP,
    Repeat = GL_REPEAT,
}

enum TextureTarget{
    Dim1 = GL_TEXTURE_1D,
    Dim2 = GL_TEXTURE_2D,
    Dim3 = GL_TEXTURE_3D,
    Buffer = GL_TEXTURE_BUFFER,
    Dim1Array = GL_TEXTURE_1D_ARRAY,
    Dim2Array = GL_TEXTURE_2D_ARRAY,
    Rectangle = GL_TEXTURE_RECTANGLE,
    CubeMap      = GL_TEXTURE_CUBE_MAP,
    CubeMapArray = GL_TEXTURE_CUBE_MAP_ARRAY,
    Dim2Multisample      = GL_TEXTURE_2D_MULTISAMPLE,
    Dim2MultisampleArray = GL_TEXTURE_2D_MULTISAMPLE_ARRAY,
}
