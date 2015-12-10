module armos.graphics.texture;
import derelict.opengl3.gl;
import armos.math.vector;

class Texture {
	private int savedTexID_;
	private int texID_;
	private const ubyte* bitsPtr;
	
	private armos.math.Vector2i size_;
	armos.math.Vector2i size(){return size_;}
	
	int id(){
		return texID_;
	}

	
	this(in armos.math.Vector2i textureSize, in ubyte[] bits){
		glEnable(GL_TEXTURE_2D);
		glGenTextures(1 , cast(uint*)&texID_);
		
		size_ = textureSize;
		bitsPtr = bits.ptr;
		
		begin;
			glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
			glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
		end;
		allocate;
	}
	
	this(in int width, in int height, in ubyte[] bits){
		this(armos.math.Vector2i(width, height), bits);
	}
	
	this(armos.math.Vector2i textureSize){
		glEnable(GL_TEXTURE_2D);
		glGenTextures(1 , cast(uint*)&texID_);
		
		size_ = textureSize;
		bitsPtr = null;
		
		begin;
			glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
			glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
		end;
		allocate;
	}
	
	this(in int width, in int height){
		this(armos.math.Vector2i(width, height));
	}
	
	void begin(){
		glGetIntegerv(GL_TEXTURE_BINDING_2D, &savedTexID_);
		glBindTexture(GL_TEXTURE_2D , texID_);
	}
	
	void end(){
		glBindTexture(GL_TEXTURE_2D , savedTexID_);
	}
	
	void resize(in armos.math.Vector2i textureSize){
		size_ = textureSize;
		allocate;
	};
	
	private void allocate(){
		begin;
			glTexImage2D(
				GL_TEXTURE_2D, 0, GL_RGBA8,
				size_[0], size_[1],
				0, GL_RGBA, GL_UNSIGNED_BYTE, cast(GLvoid*)bitsPtr
			);
		end;
	}
}
