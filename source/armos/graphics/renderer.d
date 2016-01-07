module armos.graphics.renderer;
import armos.app;
import armos.graphics;
import derelict.opengl3.gl;
import std.math;

/++
++/
enum PolyRenderMode {
	Points,
	WireFrame,
	Fill,
}

/++
++/
enum PrimitiveMode{
	Triangles,
	TriangleStrip,
	TriangleFan,
	Lines,
	LineStrip,
	LineLoop,
	Points,
	Quads,
}

/++
++/
enum MatrixMode{
	ModelView,
	Projection,
	Texture
}

/++
++/
enum BlendMode{
	Disable,
	Alpha,
	Add,
	Screen,
	Subtract
}

/++
++/
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
		case PrimitiveMode.LineStrip:
			return_mode =  GL_LINE_STRIP;
			break;
		case PrimitiveMode.LineLoop:
			return_mode =  GL_LINE_LOOP;
			break;
		case PrimitiveMode.Points:
			return_mode =  GL_POINTS;
			break;
		case PrimitiveMode.Quads:
			return_mode =  GL_QUADS;
			break;
		default : assert(0);

	}
	return return_mode;
}

/++
++/
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

/++
++/
GLuint getGLMatrixMode(MatrixMode mode){
	GLuint return_mode;
	switch (mode) {
		case MatrixMode.ModelView:
				 return_mode = GL_MODELVIEW;
					 break;
		case MatrixMode.Projection:
				 return_mode = GL_PROJECTION;
					 break;
		case MatrixMode.Texture:
				 return_mode = GL_TEXTURE;
					 break;
		default : assert(0);
	}
	return return_mode;
}

/++
++/
armos.math.Matrix4f perspectiveMatrix(float fov, float aspect, float nearDist, float farDist){
    double tan_fovy = tan(fov*0.5*PI/180.0);
    double right  =  tan_fovy * aspect* nearDist;
    double left   = -right;
    double top    =  tan_fovy * nearDist;
    double bottom =  -top;
	
	return frustumMatrix(left,right,bottom,top,nearDist,farDist);
}

/++
++/
armos.math.Matrix4f frustumMatrix(double left, double right, double bottom, double top, double zNear, double zFar){
    double A = (right+left)/(right-left);
    double B = (top+bottom)/(top-bottom);
    double C = -(zFar+zNear)/(zFar-zNear);
    double D = -2.0*zFar*zNear/(zFar-zNear);
	
	return armos.math.Matrix4f(
		[2.0*zNear/(right-left), 0.0,                    A,    0.0 ],
		[0.0,                    2.0*zNear/(top-bottom), B,    0.0 ],
		[0.0,                    0.0,                    C,    D   ],
		[0.0,                    0.0,                    -1.0, 0.0 ]
	);
}
	
/++
++/
armos.math.Matrix4f lookAtViewMatrix(in armos.math.Vector3f eye, in armos.math.Vector3f center, in armos.math.Vector3f up){
	armos.math.Vector3f zaxis;
	if((eye-center).norm>0){
		zaxis = (eye-center).normalized;
	}else{
		zaxis = armos.math.Vector3f();
	}
	
	armos.math.Vector3f xaxis;
	if(up.vectorProduct(zaxis).norm>0){
		xaxis = up.vectorProduct(zaxis).normalized;
	}else{
		xaxis = armos.math.Vector3f();
	}
	
	armos.math.Vector3f yaxis = zaxis.vectorProduct(xaxis);
	
	return armos.math.Matrix4f(
			[xaxis[0], xaxis[1], xaxis[2], -xaxis.dotProduct(eye)],
			[yaxis[0], yaxis[1], yaxis[2], -yaxis.dotProduct(eye)],
			[zaxis[0], zaxis[1], zaxis[2], -zaxis.dotProduct(eye)],
			[0,        0,        0,                             1]
	);
};

/++
++/
class Renderer {
	armos.graphics.Style[] styleStack;
	auto currentStyle_ = new armos.graphics.Style;
	
	armos.graphics.MatrixStack matrixStack;
	
	armos.math.Matrix4f projectionMatrix;
	
	bool isBackgroundAuto = true;
	
	armos.graphics.Fbo fbo;
	bool _isUseFbo = true;
	
	this(){
		matrixStack = new armos.graphics.MatrixStack(armos.app.currentWindow);
		fbo = new armos.graphics.Fbo;
	}
	
	void matrixMode(MatrixMode mode){
		glMatrixMode(getGLMatrixMode(mode));
	}
	// void draw(ref armos.graphics.Mesh mesh, armos.graphics.PolyRenderMode renderMode){
		// if(mesh.vertices != 0){
			// glEnableClientState(GL_VERTEX_ARRAY);
			// glVertexPointer(3, GL_FLOAT, sizeof(ofVec3f), &vertexData.getVerticesPointer()->x);
		// }
	// };
	
	// void viewport(float x, float y, float width, float height, bool vflip){
	// 	glViewport(nativeViewport.x,nativeViewport.y,nativeViewport.width,nativeViewport.height);
	// };
	
	armos.graphics.Style* currentStyle(){
		return &currentStyle_;
	};
	
	void bind(armos.math.Matrix4f projectionMatrix){
		glMatrixMode(GL_PROJECTION);
		pushMatrix();
		glLoadMatrixf(projectionMatrix.array.ptr);
	}
	void unbind(){
		glMatrixMode(GL_PROJECTION);
		popMatrix();
	}
	
	void setBackground(const armos.types.Color color){
		currentStyle.backgroundColor = cast(armos.types.Color)color;
		glClearColor(color.r/255.0,color.g/255.0,color.b/255.0,color.a/255.0);
		glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		
	}
	
	void setColor(const armos.types.Color color){
		currentStyle.color = cast(armos.types.Color)color; 
		glColor4f(color.r/255.0,color.g/255.0,color.b/255.0,color.a/255.0);
	}
	
	void setColor(int colorCode){
		auto color =  armos.types.Color(colorCode);
		setColor(color);
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
	
	void rotate(float degrees, armos.math.Vector3f vec){
		rotate(degrees, vec[0], vec[1], vec[2]);
	}
	void rotate(float degrees, float vecX, float vecY, float vecZ){
		glRotatef(degrees, vecX, vecY, vecZ);
	}
	
	void setLineWidth(float width){
		currentStyle.lineWidth = width;
		glLineWidth(width);
	}
	
	void setLineSmoothing(bool smooth){
		currentStyle.isSmoothing = smooth;
	}
	
	void drawLine(in float x1, in float y1, in float z1, in float x2, in float y2, in float z2){
		armos.graphics.Vertex[2] vertices;
		vertices[0].x = x1;
		vertices[0].y = y1;
		vertices[0].z = z1;
		vertices[1].x = x2;
		vertices[1].y = y2;
		vertices[1].z = z2;
		
		glEnableClientState(GL_VERTEX_ARRAY);
		glVertexPointer(3, GL_FLOAT, 0, vertices.ptr);
		glDrawArrays(GL_LINES, 0, 2);
		glDisableClientState(GL_VERTEX_ARRAY);
	};

	

	// void rotate(armos.math.Quaternionf q){
	// 	glRotatef(q[3], q[0], q[1], q[2]);
	// }
	void setup(){
		if(_isUseFbo){
			fbo.begin;
		}
			viewport();
			setupScreenPerspective();
			setBackground(currentStyle.backgroundColor );
			
		if(_isUseFbo){
			fbo.end;
		}
		
		// auto position = armos.math.Vector2f(0, 0);
		// auto size = armos.app.currentWindow.windowSize();
		
		// position[1] = size[1] - (position[1] + size[1]);
		// position[1] = renderSurfaceSize[1] - (y + height);
		// glViewport(cast(int)position[0], cast(int)position[1], cast(int)size[0], cast(int)size[1]);
		
		
	};
	
	void resize(){
		if(_isUseFbo){
			fbo.resize(armos.app.currentWindow.size);
			fbo.begin;
		}
		
		setBackground(currentStyle.backgroundColor );
		
		if(_isUseFbo){
			fbo.end;
		}
	}
	
	void viewport(in float x = 0, in float y = 0, in float width = -1, in float height = -1, in bool vflip=true){
		// matrixStack.viewport(x, y, width, height, vflip);
		// auto nativeViewport = matrixStack.nativeViewport();
		// glViewport(cast(int)nativeViewport.x,cast(int)nativeViewport.y,cast(int)nativeViewport.width,cast(int)nativeViewport.height);
		
		auto position = armos.math.Vector2f(0, 0);
		auto size = armos.app.currentWindow.size();
		position[1] = size[1] - (position[1] + size[1]);
		// position[1] = renderSurfaceSize[1] - (y + height);
		glViewport(cast(int)position[0], cast(int)position[1], cast(int)size[0], cast(int)size[1]);
	}
	
	armos.types.Rectangle currentViewport(){
		// nativeViewport();
		return matrixStack.currentViewport;
	}
	
	// armos.type.Rectangle nativeViewport(){
	// 	GLint viewport[4];					// Where The Viewport Values Will Be Stored
	// 	glGetIntegerv(GL_VIEWPORT, viewport);
	//
	// 	ofGLRenderer* mutRenderer = const_cast<ofGLRenderer*>(this);
	// 	ofRectangle nativeViewport(viewport[0], viewport[1], viewport[2], viewport[3]);
	// 	mutRenderer->matrixStack.nativeViewport(nativeViewport);
		// return nativeViewport;
	// }
	
	void setupScreenPerspective(float width = -1, float height = -1, float fov = 60, float nearDist = 0, float farDist = 0){
		float viewW, viewH;
		if(width<0 || height<0){
			viewW = armos.app.windowSize[0];
			viewH = armos.app.windowSize[1];
		}else{
			viewW = width;
			viewH = height;
		}
		
		float eyeX = viewW / 2.0;
		float eyeY = viewH / 2.0;
		float halfFov = PI * fov / 360;
		float theTan = tan(halfFov);
		float dist = eyeY / theTan;
		float aspect = viewW / viewH;
		//
		if(nearDist == 0) nearDist = dist / 10.0f;
		if(farDist == 0) farDist = dist * 10.0f;
		
		
		armos.math.Matrix4f persp = perspectiveMatrix(fov, aspect, nearDist, farDist);
		
		// matrixStack.loadProjectionMatrix( persp );
		// loadMatrix(persp);
		
		armos.math.Matrix4f lookAt = lookAtViewMatrix(
			armos.math.Vector3f(eyeX, eyeY, dist),
			armos.math.Vector3f(eyeX, eyeY, 0),
			armos.math.Vector3f(0, 1, 0)
		);
		
		glMatrixMode(GL_PROJECTION);
		glLoadIdentity();
		
		// import std.stdio;
		// writeln("persp:");
		// persp.print();
		//
		// writeln("lookAt:");
		// lookAt.print();
		//
		// writeln("persp*lookAt:");
		// ( persp*lookAt ).print();
		
		glLoadMatrixf((persp*lookAt).array.ptr);
		glScalef(1, -1, 1);
		glTranslatef(0, -viewH, 0);
		glMatrixMode(GL_MODELVIEW);
		// glLoadIdentity();
	}
	
	void startRender(){
		if(_isUseFbo){
			fbo.begin;
		}
		
		viewport();
		setupScreenPerspective();
		
		if( isBackgroundAuto ){
			setBackground(currentStyle.backgroundColor );
		}
	};
	void finishRender(){
		if(_isUseFbo){
			fbo.end;
			armos.types.Color tmp =currentStyle.color;
			setColor(0xFFFFFF);
			fbo.draw;
			setColor(tmp);
		}
		// glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	};
	
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
		
		//add texchoords to gl
		if(mesh.numTexCoords){
			glEnableClientState(GL_TEXTURE_COORD_ARRAY);
			glTexCoordPointer(2, GL_FLOAT, 0, mesh.texCoords.ptr);
			// foreach (texCoord; mesh.texCoords ) {
			// 	glTexCoord2f(texCoord.u , texCoord.v);
			// }
		}
		// 	if(texturelocationsenabled.size() == 0){
		// 		glenableclientstate(gl_texture_coord_array);
		// 		glTexCoordPointer(2, GL_FLOAT, sizeof(ofVec2f), &vertexData.getTexCoordsPointer()->x);
		// 	}else{
		// 		set<int>::iterator textureLocation = textureLocationsEnabled.begin();
		// 		for(;textureLocation!=textureLocationsEnabled.end();textureLocation++){
		// 			glActiveTexture(GL_TEXTURE0+*textureLocation);
		// 			glClientActiveTexture(GL_TEXTURE0+*textureLocation);
		// 			glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		// 			glTexCoordPointer(2, GL_FLOAT, sizeof(ofVec2f), &vertexData.getTexCoordsPointer()->x);
		// 		}
		// 		glActiveTexture(GL_TEXTURE0);
		// 		glClientActiveTexture(GL_TEXTURE0);
		// 	}
		
		//add indicees to GL
		
		
		if(mesh.numIndices){
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
		if(mesh.numTexCoords){
			glDisableClientState(GL_TEXTURE_COORD_ARRAY);
		}
	}
	
	void enableDepthTest(){
		glEnable(GL_DEPTH_TEST);
	}
	
	void disableDepthTest(){
		glDisable(GL_DEPTH_TEST);
	}
	
	void blendMode(armos.graphics.BlendMode mode){
		switch (mode) {
			case BlendMode.Alpha:
				glEnable(GL_BLEND);
				glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
				break;
				
			case BlendMode.Disable:
				glDisable(GL_BLEND);
				break;
			default:
				assert(0);
		}
		currentStyle.blendMode = mode;
	}
	
	void enableFbo(){
		_isUseFbo = true;
	}
	
	void disableFbo(){
		_isUseFbo = false;
	}
}

/++
++/
armos.graphics.Renderer* currentRenderer(){
	return &armos.app.mainLoop.renderer;
}

/++
++/
armos.graphics.Style* currentStyle(){
	return armos.graphics.currentRenderer.currentStyle;
}

/++
++/
void setBackground(const armos.types.Color color){
	currentRenderer.setBackground(color);
}

/++
++/
void setBackground(const float gray){
	currentRenderer.setBackground(armos.types.Color(gray, gray, gray, 255));
}

/++
++/
void setBackground(in float r, in float g, in float b, in float a = 255){
	currentRenderer.setBackground(armos.types.Color(r, g, b, a));
}

/++
++/
void setBackgroundAuto(const bool isAuto){
	currentRenderer.isBackgroundAuto = isAuto;
}

/++
++/
void setColor(in float r, in float g, in float b, in float a = 255){
	currentRenderer.setColor(armos.types.Color(r, g, b, a));
}

/++
++/
void setColor(const armos.types.Color color){
	currentRenderer.setColor(color);
}

/++
++/
void setColor(const float gray){
	currentRenderer.setColor(armos.types.Color(gray, gray, gray, 255));
}

/++
++/
void drawLine(in float x1, in float y1, in float z1, in float x2, in float y2, in float z2){
	currentRenderer.drawLine(x1, y1, z1, x2, y2, z2);
}

/++
++/
void drawLine(armos.math.Vector3f vec1, armos.math.Vector3f vec2){
	drawLine(vec1[0], vec1[1], vec1[2], vec2[0], vec2[1], vec2[2]);
}	

/++
++/
void drawLine(in float x1, in float y1, in float x2, in float y2){
	currentRenderer.drawLine(x1, y1, 0, x2, y2, 0);
}	

/++
++/
void drawLine(armos.math.Vector2f vec1, armos.math.Vector2f vec2){
	drawLine(vec1[0], vec1[1], 0, vec2[0], vec2[1], 0);
}

/++
++/
void popMatrix(){
	currentRenderer.popMatrix();
}

/++
++/
void pushMatrix(){
	currentRenderer.pushMatrix();
}

/++
++/
void translate(float x, float y, float z){
	currentRenderer.translate(x, y, z);
}

/++
++/
void translate(armos.math.Vector3f vec){
	currentRenderer.translate(vec);
}

/++
++/
void scale(float x, float y, float z){
	currentRenderer.scale(x, y, z);
}

/++
++/
void scale(float s){
	currentRenderer.scale(s, s, s);
}

/++
++/
void scale(armos.math.Vector3f vec){
	currentRenderer.scale(vec);
}

/++
++/
void rotate(float degrees, float vec_x, float vec_y, float vec_z){
	currentRenderer.rotate(degrees, vec_x, vec_y, vec_z);
}

/++
++/
void rotate(float degrees, armos.math.Vector3f vec){
	currentRenderer.rotate(degrees, vec);
}

/++
++/
void setLineWidth(float width){
	currentRenderer.setLineWidth(width);
}

/++
++/
void enableDepthTest(){
	currentRenderer.enableDepthTest;
}

/++
++/
void disableDepthTest(){
	currentRenderer.disableDepthTest;
}

/++
++/
void enableFbo(){
	currentRenderer.enableFbo;
}

/++
++/
void disableFbo(){
	currentRenderer.disableFbo;
}

/++
++/
void blendMode(armos.graphics.BlendMode mode){
	currentRenderer.blendMode = mode;
}
