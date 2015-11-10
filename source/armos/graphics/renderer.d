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
	armos.graphics.Style[] styleStack;
	auto currentStyle_ = new armos.graphics.Style;
	
	armos.math.Matrix4f[] matrixStack;
	auto currentMatrix_= new armos.math.Matrix4f;
	
	this(){}
	
	// void draw(ref armos.graphics.Mesh mesh, armos.graphics.PolyRenderMode renderMode){
		// if(mesh.vertices != 0){
			// glEnableClientState(GL_VERTEX_ARRAY);
			// glVertexPointer(3, GL_FLOAT, sizeof(ofVec3f), &vertexData.getVerticesPointer()->x);
		// }
	// };
	
	armos.graphics.Style* currentStyle(){
		return &currentStyle_;
	};
	
	void setBackground(const armos.graphics.Color color){
		glClearColor(cast(float)color.r/255.0, color.g/255., color.b/255., color.a/255. );
	}
	
	void pushMatrix(){
		glPushMatrix();
	};
	
	void popMatrix(){
		glPopMatrix();
	};
	
	void translate(float x, float y, float z){
		glTranslatef(x, y, z);
	}

	void translate(armos.math.Vector3f vec){
		glTranslatef(vec[0], vec[1], vec[2]);
	};
	
	void scale(float x, float y, float z){
		glScalef(x, y, z);
	}
	
	void scale(armos.math.Vector3f vec){
		glScalef(vec[0], vec[1], vec[2]);
	}
	
	void rotate(float degrees, float vecX, float vecY, float vecZ){
		glRotatef(degrees, vecX, vecY, vecZ);
	}
	
	// void rotate(armos.math.Quaternionf q){
	// 	glRotatef(q[3], q[0], q[1], q[2]);
	// }
	
	void draw(
		in armos.graphics.Mesh mesh,
		armos.graphics.PolyRenderMode renderMode,
		bool useColors,
		bool useTextures,
		bool useNormals
	){
		
		glPolygonMode(GL_FRONT_AND_BACK, armos.graphics.getGLPolyRenderMode(renderMode));
		//add vertices to GL
		if(mesh.numVertices){
			glEnableClientState(GL_VERTEX_ARRAY);
			glVertexPointer(3, GL_FLOAT, 0, mesh.vertices.ptr);
		}
		
		//add normals to GL
		
		//add colors to GL
		
		//add texChoords to GL
		
		//add indicees to GL
		
		
		if(mesh.numIndices()){
			glDrawElements(
				armos.graphics.getGLPrimitiveMode(mesh.primitiveMode),
				cast(int)mesh.numIndices(),
				GL_UNSIGNED_INT,
				mesh.indices.ptr
			);
		}
		
		glPolygonMode(GL_FRONT_AND_BACK, armos.graphics.currentStyle.isFill ?  GL_FILL : GL_LINE);
		
		if(mesh.numVertices){
			glDisableClientState(GL_VERTEX_ARRAY);
		}
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

void popMatrix(){
	currentRenderer.popMatrix();
}

void pushMatrix(){
	currentRenderer.pushMatrix();
}


void translate(float x, float y, float z){
	currentRenderer.translate(x, y, z);
}

void translate(armos.math.Vector3f vec){
	currentRenderer.translate(vec);
}

void scale(float x, float y, float z){
	currentRenderer.scale(x, y, z);
}

void scale(armos.math.Vector3f vec){
	currentRenderer.scale(vec);
}

void rotate(float degrees, float vec_x, float vec_y, float vec_z){
	currentRenderer.rotate(degrees, vec_x, vec_y, vec_z);
}
