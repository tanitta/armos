module armos.graphics.texture;
import derelict.opengl3.gl;
import armos.math.vector;
static import armos.graphics;

/++
    openGLのtextureを表すクラスです．
    初期化後，allocateして利用します．
    Example:
    ---
        auto texture = new armos.graphics.Texture;
        texture.allocate(256, 256);
        
        auto rect = new armos.graphics.Mesh;
        rect.primitiveMode = armos.graphics.PrimitiveMode.Quads;
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
        this(){
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
        armos.math.Vector2i size()const{return _size;}

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

        /++
            Begin to bind the texture.
        +/
        Texture begin(){
            glBindTexture(GL_TEXTURE_2D , _id);
            return this;
        }

        /++
            End to bind the texture.
        +/
        Texture end(){
            glBindTexture(GL_TEXTURE_2D , 0);
            return this;
        }
        
        ///
        Texture bind(){
            glBindTexture(GL_TEXTURE_2D , _id);
            return this;
        };

        /++
            Resize texture.
        +/
        Texture resize(in armos.math.Vector2i textureSize){
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
        Texture allocate(in int w, in int h, armos.graphics.ColorFormat format){
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
        Texture allocate(armos.graphics.Bitmap!(char) bitmap){
            import std.math;
            if(bitmap.width != bitmap.height){
                int side = cast( int )fmax(bitmap.width, bitmap.height);
                armos.graphics.Bitmap!(char) squareBitmap;
                squareBitmap.allocate(side, side, bitmap.colorFormat);
                for (int i = 0; i < bitmap.size[0]; i++) {
                    for (int j = 0; j < bitmap.size[1]; j++) {
                        squareBitmap.pixel(i, j, bitmap.pixel(i, j));
                    }
                }
                ubyte[] bits;
                for (int i = 0; i < squareBitmap.size[0]; i++) {
                    for (int j = 0; j < squareBitmap.size[1]; j++) {
                        for (int k = 0; k < squareBitmap.numElements; k++) {
                            bits ~= squareBitmap.pixel(i, j).element(k);
                        }
                    }
                }
                allocate(bits, squareBitmap.size[0], squareBitmap.size[1], squareBitmap.colorFormat);
            }else{
                ubyte[] bits;
                for (int i = 0; i < bitmap.size[0]; i++) {
                    for (int j = 0; j < bitmap.size[1]; j++) {
                        for (int k = 0; k < bitmap.numElements; k++) {
                            bits ~= bitmap.pixel(i, j).element(k);
                        }
                    }
                }
                allocate(bits, bitmap.size[0], bitmap.size[1], bitmap.colorFormat);
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
        Texture allocate(ubyte[] bits, in int w, in int h, in armos.graphics.ColorFormat format){
            _size[0] = w;
            _size[1] = h;
            _bitsPtr = bits.ptr;
            allocate(format);
            return this;
        }

        /++
            Allocate texture
        +/
        Texture allocate(in armos.graphics.ColorFormat format){
            _format = format;
            allocate();
            return this;
        }

        /++
            Allocate texture
        +/
        Texture allocate(){
            GLuint internalFormat = armos.graphics.getGLInternalFormat(_format);
            begin;
            glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexImage2D(
                    GL_TEXTURE_2D, 0, internalFormat,
                    _size[0], _size[1],
                    0, internalFormat, GL_UNSIGNED_BYTE, cast(GLvoid*)_bitsPtr
                    );
            end;
            return this;
        }

        /++
        +/
        Texture setMinMagFilter(in TextureFilter minFilter, in TextureFilter magFilter){
            begin;
            glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, minFilter);
            glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, magFilter);
            end;
            return this;
        }

        /++
        +/
        Texture setMinMagFilter(in TextureFilter filter){
            setMinMagFilter(filter, filter);
            return this;
        }
    }

    private{
        int _id;
        ubyte* _bitsPtr;
        armos.math.Vector2i _size;
        armos.graphics.ColorFormat _format;
    }
}

/++
+/
enum TextureFilter{
    Linear = GL_LINEAR,
    Nearest = GL_NEAREST
}
