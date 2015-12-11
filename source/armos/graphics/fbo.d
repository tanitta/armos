module armos.graphics.fbo;
import armos.graphics;
import derelict.opengl3.gl;
import armos.math.vector;

class Fbo{
	private int savedFboID_=0;
	private int fboID_ = 0;
	
	private armos.graphics.Texture texture;
	private armos.graphics.Rbo depthRbo;
	
	private armos.graphics.Mesh rect = new armos.graphics.Mesh;
	
	int id()const{
		return fboID_;
	}
	
	this(){
		this(armos.app.currentWindow.size);
	}
	
	this(armos.math.Vector2i size){
		this(size[0], size[1]);
	}
	
	this(in int width, in int height){
		glGenFramebuffers(1, cast(uint*)&fboID_);
		depthRbo = new armos.graphics.Rbo;
		
		texture = new armos.graphics.Texture(width, height);
		float x = width;
		float y = height;
		rect.primitiveMode = armos.graphics.PrimitiveMode.Quads;
		
		texture.begin;
			rect.addTexCoord(0, 1);rect.addVertex(0, 0, 0);
			rect.addTexCoord(0, 0);rect.addVertex(0, y, 0);
			rect.addTexCoord(1, 0);rect.addVertex(x, y, 0);
			rect.addTexCoord(1, 1);rect.addVertex(x, 0, 0);
		texture.end;
		
		rect.addIndex(0);
		rect.addIndex(1);
		rect.addIndex(2);
		rect.addIndex(3);
		
		glGetIntegerv(GL_FRAMEBUFFER_BINDING, &savedFboID_);
		glBindFramebuffer(GL_FRAMEBUFFER, fboID_);
			glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT,  GL_RENDERBUFFER, depthRbo.id);
			glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture.id, 0);
		glBindFramebuffer(GL_FRAMEBUFFER, savedFboID_);
	}
	
	void begin(){
		glGetIntegerv(GL_FRAMEBUFFER_BINDING, &savedFboID_);
		glBindFramebuffer(GL_FRAMEBUFFER, fboID_);
		// colorRbo.begin;
		// depthRbo.begin;
	}
	
	void end(){
		// colorRbo.end;
		// depthRbo.end;
		glBindFramebuffer(GL_FRAMEBUFFER, savedFboID_);
	}
	
	// void draw(in float x, in float y, in float w, in float h){
	void draw(){
		texture.begin;
			rect.drawFill();
		texture.end;
	}
	
	void resize(in armos.math.Vector2i size){
		begin;
			rect.vertices[1].y = size[1];
			rect.vertices[2].x = size[0];
			rect.vertices[2].y = size[1];
			rect.vertices[3].x = size[0];
			texture.resize(size);
		end;
	}
	
	// void draw(in armos.math.Vector2f position, in armos.math.Vector2f size){
	// 	draw(position[0], position[1], size[0], size[1]);
	// }
}
