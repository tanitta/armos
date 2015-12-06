module armos.graphics.texture;
import derelict.opengl3.gl;
import armos.math.vector;

class Texture {
	private int savedTexID_;
	private int texID_;
	
	int id(){
		return texID_;
	}

	this(){
		glGenTextures(1 , cast(uint*)&texID_);
	}
	
	void begin(){
		glGetIntegerv(GL_TEXTURE_BINDING_2D, &savedTexID_);
		glBindTexture(GL_TEXTURE_2D , texID_);
	}
	
	void end(){
		glBindTexture(GL_TEXTURE_2D , savedTexID_);
	}
	
	void resize(in armos.math.Vector2i size){
	
	};
}
