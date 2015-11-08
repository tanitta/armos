module armos.graphics.renderer;
import armos.app;
import armos.graphics;
import derelict.opengl3.gl3;
enum PolyRenderMode {
	Points,
	WireFrame,
	Fill,
}

// getGLPolyRenderMode(PolyRenderMode){
//
// }


class Renderer {
	this(){}
	void draw(ref armos.graphics.Mesh mesh, armos.graphics.PolyRenderMode renderMode){
		// if(mesh.vertices != 0){
			// glEnableClientState(GL_VERTEX_ARRAY);
			// glVertexPointer(3, GL_FLOAT, sizeof(ofVec3f), &vertexData.getVerticesPointer()->x);
		// }
	};
	
	void setBackground(const armos.graphics.Color color){
		glClearColor(cast(float)color.r/255.0, color.g/255., color.b/255., color.a/255. );
	}
}

armos.graphics.Renderer* getCurrentRenderer(){
	return &armos.app.mainLoop.renderer;
}

void setBackground(const armos.graphics.Color color){
	getCurrentRenderer.setBackground(color);
	glClear(GL_COLOR_BUFFER_BIT);
}
