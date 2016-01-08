module armos.graphics.texture;
import derelict.opengl3.gl;
import armos.math.vector;

int nextPow2(int a){
	// from nehe.gamedev.net lesson 43
	int rval=1;
	while(rval<a) rval<<=1;
	return rval;
}

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
++/
class Texture {
	public{
		this(){}
		
		/++
			Return the texture size.
			
			textureのサイズを返します．
		++/
		armos.math.Vector2i size(){return size_;}
		
		/++
		++/
		int width(){
			return size[0];
		}
		
		/++
		++/
		int height(){
			return size[1];
		}
		
		/++
			Return gl texture id.
		++/
		int id(){return texID_;}

		/++
			Begin to bind the texture.
		++/
		void begin(){
			glGetIntegerv(GL_TEXTURE_BINDING_2D, &savedTexID_);
			glBindTexture(GL_TEXTURE_2D , texID_);
		}

		/++
			End to bind the texture.
		++/
		void end(){
			glBindTexture(GL_TEXTURE_2D , savedTexID_);
		}

		/++
			Resize texture.
		++/
		void resize(in armos.math.Vector2i textureSize){
			size_ = textureSize;
			begin;
				glTexImage2D(
					GL_TEXTURE_2D, 0, GL_RGBA8,
					size_[0], size_[1],
					0, GL_RGBA, GL_UNSIGNED_BYTE, cast(GLvoid*)bitsPtr
				);
			end;
		};
		
		/++
			Return pixel of texture
		++/
		ubyte pixel(){
			assert(bitsPtr!=null);
			return 0x00;
		}

		/++
			Set pixel of texture
		++/
		void pixel(ubyte v){
			assert(bitsPtr!=null);
		}
		
		/++
			Allocate texture
			Params:
				w = width
				h = height
		++/
		void allocate(in int w, in int h){
			size_[0] = w;
			size_[1] = h;
			allocate(_format);
		}
		
		/++
			Allocate texture
			Params:
				bitmap =
		++/
		void allocate(armos.graphics.Bitmap!(char) bitmap){
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
			
		}
		
		/++
			Allocate texture
			Params:
				w    = width
				h    = height
				bits = image data
		++/
		void allocate(ubyte[] bits, in int w, in int h, armos.graphics.ColorFormat format){
			size_[0] = w;
			size_[1] = h;
			bitsPtr = bits.ptr;
			allocate(format);
		}
		
		/++
			Allocate texture
		++/
		void allocate(armos.graphics.ColorFormat format){
			glEnable(GL_TEXTURE_2D);
			glGenTextures(1 , cast(uint*)&texID_);
			
			GLuint glInternalFormat = armos.graphics.getGLInternalFormat(format);
			begin;
				glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
				glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
				glTexImage2D(
					GL_TEXTURE_2D, 0, glInternalFormat,
					size_[0], size_[1],
					0, glInternalFormat, GL_UNSIGNED_BYTE, cast(GLvoid*)bitsPtr
				);
			end;
		}
	}

	private{
		int savedTexID_;
		int texID_;
		ubyte* bitsPtr;
		armos.math.Vector2i size_;
		armos.graphics.ColorFormat _format;
	}
}
