module armos.graphics.rbo;
import armos.graphics;
import derelict.opengl3.gl;
import armos.math.vector;

class Rbo{
	private int savedRboID_=0;
	private int rboID_ = 0;
	
	int id(){
		return rboID_;
	}
	
	this(){
		glGenRenderbuffers(1, cast(uint*)&rboID_);
	}
	
	void begin(){
		glGetIntegerv(GL_RENDERBUFFER_BINDING, &savedRboID_);
		glBindFramebuffer(GL_RENDERBUFFER, rboID_);
	}
	
	void end(){
		glBindFramebuffer(GL_RENDERBUFFER, savedRboID_);
	}
}
