module armos.graphics.fbo;
import armos.graphics;
import derelict.opengl3.gl;
import armos.math.vector;

class Fbo{
	private int savedFboID_=0;
	private int fboID_ = 0;
	
	private armos.graphics.Texture texture;
	private armos.graphics.Rbo colorRbo;
	private armos.graphics.Rbo depthRbo;
	
	int id(){
		return fboID_;
	}
	
	this(){
		// glGenFramebuffers(1, &hoge);
		// glGenFramebuffers(1, cast(uint*)&fboID_);
		// colorRbo = new armos.graphics.Rbo;
		// depthRbo = new armos.graphics.Rbo;
		//
		//
		// glGetIntegerv(GL_FRAMEBUFFER_BINDING, &savedFboID_);
		// glBindFramebuffer(GL_FRAMEBUFFER, fboID_);
		// 	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRbo.id);
		// 	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRbo.id);
		// glBindFramebuffer(GL_FRAMEBUFFER, fboID_);
		//
		// texture = new armos.graphics.Texture;
	}
	
	void begin(){
		glGetIntegerv(GL_FRAMEBUFFER_BINDING, &savedFboID_);
		glBindFramebuffer(GL_FRAMEBUFFER, fboID_);
	}
	
	void end(){
		glBindFramebuffer(GL_FRAMEBUFFER, savedFboID_);
	}
	
	void draw(in float x, in float y, in float w, in float h){
		begin;
			texture.begin;
				glCopyTexSubImage2D(
						GL_TEXTURE_2D,
						0,
						0, 0,
						0, 0, armos.app.currentWindow.size[0], armos.app.currentWindow.size[1]
				);
			texture.end;
		end;
		
		//draw texture
	}
	
	void draw(in armos.math.Vector2f position, in armos.math.Vector2f size){
		draw(position[0], position[1], size[0], size[1]);
	
	}
}
