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
	
	private armos.graphics.Mesh rect = new armos.graphics.Mesh;
	
	int id(){
		return fboID_;
	}
	
	this(){
		glGenFramebuffers(1, cast(uint*)&fboID_);
		colorRbo = new armos.graphics.Rbo;
		depthRbo = new armos.graphics.Rbo;
		
		glGetIntegerv(GL_FRAMEBUFFER_BINDING, &savedFboID_);
		glBindFramebuffer(GL_FRAMEBUFFER, fboID_);
			glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRbo.id);
			glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT,  GL_RENDERBUFFER, depthRbo.id);
		glBindFramebuffer(GL_FRAMEBUFFER, savedFboID_);
		
		texture = new armos.graphics.Texture(armos.app.currentWindow.size);
		float x = armos.app.currentWindow.size[0];
		float y = armos.app.currentWindow.size[1];
		rect.primitiveMode = armos.graphics.PrimitiveMode.Quads;
		rect.addVertex(0, 0, 0);
		rect.addVertex(x, 0, 0);
		rect.addVertex(x, y, 0);
		rect.addVertex(0, y, 0);
		
		texture.begin;
			rect.addTexCoord(0, 1);
			rect.addTexCoord(1, 1);
			rect.addTexCoord(1, 0);
			rect.addTexCoord(0, 0);
		texture.end;
		
		rect.addIndex(0);
		rect.addIndex(1);
		rect.addIndex(2);
		rect.addIndex(3);
			
	}
	
	void begin(){
		glGetIntegerv(GL_FRAMEBUFFER_BINDING, &savedFboID_);
		glBindFramebuffer(GL_FRAMEBUFFER, fboID_);
	}
	
	void end(){
		glBindFramebuffer(GL_FRAMEBUFFER, savedFboID_);
	}
	
	void draw(in float x, in float y, in float w, in float h){
		texture.begin;
			begin;
				glCopyTexSubImage2D(
						GL_TEXTURE_2D,
						0,
						0, 0,
						0, 0, armos.app.currentWindow.size[0], armos.app.currentWindow.size[1]
				);
			end;
			rect.drawFill();
		texture.end;
		//draw texture
	}
	
	void draw(in armos.math.Vector2f position, in armos.math.Vector2f size){
		draw(position[0], position[1], size[0], size[1]);
	}
}
