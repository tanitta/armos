module armos.graphics.fbo;
import derelict.opengl3.gl;
import armos.math.vector;

class Fbo{
	private int savedFboID_;
	uint fboID_;
	this(){
		glGenFramebuffers(1, cast(uint*)&fboID_);
	}
	
	void begin(){
		glGetIntegerv(GL_FRAMEBUFFER_BINDING, &savedFboID_);
		glBindFramebuffer(GL_FRAMEBUFFER, fboID_);
	}
	
	void end(){
		glBindFramebuffer(GL_FRAMEBUFFER, fboID_);
	}
	
	void draw(in float x, in float y, in float w, in float h){
		
	}
	
	void draw(in armos.math.Vector2f position, in armos.math.Vector2f size){
	
	}
}
