module armos.graphics.renderer;
import armos.app;
import armos.graphics;
import derelict.opengl3.gl;
enum PolyRenderMode {
	Points,
	WireFrame,
	Fill,
}

enum PrimitiveMode{
	Triangles,
	TriangleStrip,
	TriangleFan,
	Lines,
	LineStrip,
	LineLoop,
	Points,
}

GLuint getGLPrimitiveMode(PrimitiveMode mode){
	GLuint return_mode;
	switch (mode) {
		case PrimitiveMode.Triangles:
				 return_mode = GL_TRIANGLES;
					 break;
		case PrimitiveMode.TriangleStrip:
				 return_mode =  GL_TRIANGLE_STRIP;
					 break;
		case PrimitiveMode.TriangleFan:
				 return_mode =  GL_TRIANGLE_FAN;
					 break;
		case PrimitiveMode.Lines:
				 return_mode =  GL_LINES;
					 break;
		case PrimitiveMode.LineLoop:
				 return_mode =  GL_LINE_LOOP;
					 break;
		case PrimitiveMode.Points:
				 return_mode =  GL_POINTS;
					 break;
		default : assert(0);
		
	}
	return return_mode;
}

GLuint getGLPolyRenderMode(PolyRenderMode mode){
	GLuint return_mode;
	switch (mode) {
		case PolyRenderMode.Points:
				 return_mode = GL_POINTS;
					 break;
		case PolyRenderMode.WireFrame:
				 return_mode = GL_LINE;
					 break;
		case PolyRenderMode.Fill:
				 return_mode = GL_FILL;
					 break;
		default : assert(0);
	}
	return return_mode;
}

// getGLPolyRenderMode(PolyRenderMode){
//
// }


class Renderer {
	auto currentStyle_ = new armos.graphics.Style;
	this(){}
	void draw(ref armos.graphics.Mesh mesh, armos.graphics.PolyRenderMode renderMode){
		// if(mesh.vertices != 0){
			// glEnableClientState(GL_VERTEX_ARRAY);
			// glVertexPointer(3, GL_FLOAT, sizeof(ofVec3f), &vertexData.getVerticesPointer()->x);
		// }
	};
	
	armos.graphics.Style* currentStyle(){
		return &currentStyle_;
	};
	
	void setBackground(const armos.graphics.Color color){
		glClearColor(cast(float)color.r/255.0, color.g/255., color.b/255., color.a/255. );
	}
}

armos.graphics.Renderer* currentRenderer(){
	return &armos.app.mainLoop.renderer;
}

armos.graphics.Style* currentStyle(){
	return armos.graphics.currentRenderer.currentStyle;
}

void setBackground(const armos.graphics.Color color){
	currentRenderer.setBackground(color);
	glClear(GL_COLOR_BUFFER_BIT);
}

