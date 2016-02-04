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
armos.math.Matrix4f perspectiveMatrix(in float fov, in float aspect, in float nearDist, in float farDist){
    double tan_fovy = tan(fov*0.5*PI/180.0);
    double right  =  tan_fovy * aspect* nearDist;
    double left   = -right;
    double top    =  tan_fovy * nearDist;
    double bottom =  -top;
	
	return frustumMatrix(left,right,bottom,top,nearDist,farDist);
}

/++
++/
armos.math.Matrix4f frustumMatrix(in double left, in double right, in double bottom, in double top, in double zNear, in double zFar){
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
	public{
		
		/++
		++/
		this(){
			_fbo = new armos.graphics.Fbo;
		}
		
		/++
		++/
		void matrixMode(MatrixMode mode){
			glMatrixMode(getGLMatrixMode(mode));
		}
		
		/++
		++/
		ref armos.graphics.Style currentStyle(){
			return _currentStyle;
		};
		
		/++
		++/
		void bind(armos.math.Matrix4f projectionMatrix){
			glMatrixMode(GL_PROJECTION);
			pushMatrix();
			glLoadMatrixf(projectionMatrix.array.ptr);
		}
		
		/++
		++/
		void unbind(){
			glMatrixMode(GL_PROJECTION);
			popMatrix();
		}
		
		/++
		++/
		void setBackgroundAuto(bool b){
			_isBackgroundAuto = b;
		};
		
		/++
		++/
		void setBackground(in armos.types.Color color){
			_currentStyle.backgroundColor = cast(armos.types.Color)color;
			glClearColor(color.r/255.0,color.g/255.0,color.b/255.0,color.a/255.0);
		}
		
		/++
		++/
		void background(in armos.types.Color color){
			setBackground(color);
			glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		}
		
		/++
		++/
		void setColor(in armos.types.Color color){
			_currentStyle.color = cast(armos.types.Color)color; 
			glColor4f(color.r/255.0,color.g/255.0,color.b/255.0,color.a/255.0);
		}
		
		/++
		++/
		void setColor(in int colorCode){
			auto color =  armos.types.Color(colorCode);
			setColor(color);
		}
		
		/++
		++/
		void setStyle(armos.graphics.Style style){
			setColor(style.color);
			setBackground(style.backgroundColor);
			blendMode(style.blendMode);
			setLineWidth(style.lineWidth);
			setLineSmoothing(style.isSmoothing);
			setDepthTest(style.isDepthTest);
			_currentStyle.isFill = style.isFill;
		}
		
		/++
		++/
		void pushStyle(){
			_styleStack ~= _currentStyle;
		}
		
		/++
		++/
		void popStyle(){
			import std.range;
			if(_styleStack.length == 0){
				assert(0, "stack is empty");
			}else{
				_currentStyle = _styleStack[$-1];
				_styleStack.popBack;
				setStyle(_currentStyle);
			}
		}
		
		/++
		++/
		void pushMatrix(){
			glPushMatrix();
		};
		
		/++
		++/
		void popMatrix(){
			glPopMatrix();
		};
		
		/++
		++/
		void translate(float x, float y, float z){
			glTranslatef(x, y, z);
		}

		/++
		++/
		void translate(armos.math.Vector3f vec){
			glTranslatef(vec[0], vec[1], vec[2]);
		};
		
		/++
		++/
		void scale(float x, float y, float z){
			glScalef(x, y, z);
		}
		
		/++
		++/
		void scale(armos.math.Vector3f vec){
			glScalef(vec[0], vec[1], vec[2]);
		}
		
		/++
		++/
		void rotate(float degrees, armos.math.Vector3f vec){
			rotate(degrees, vec[0], vec[1], vec[2]);
		}
		
		/++
		++/
		void rotate(float degrees, float vecX, float vecY, float vecZ){
			glRotatef(degrees, vecX, vecY, vecZ);
		}
		
		/++
		++/
		void setLineWidth(float width){
			_currentStyle.lineWidth = width;
			glLineWidth(width);
		}
		
		/++
		++/
		void setLineSmoothing(bool smooth){
			_currentStyle.isSmoothing = smooth;
		}
		
		/++
		++/
		void setup(){
			if(_isUseFbo){
				_fbo.begin;
			}
				viewport();
				setupScreenPerspective();
				background(currentStyle.backgroundColor );
				
			if(_isUseFbo){
				_fbo.end;
			}
		};
		
		/++
		++/
		void resize(){
			if(_isUseFbo){
				_fbo.resize(armos.app.currentWindow.size);
				_fbo.begin;
			}
			
			background(currentStyle.backgroundColor );
			
			if(_isUseFbo){
				_fbo.end;
			}
		}
		
		/++
		++/
		void viewport(in float x = 0, in float y = 0, in float width = -1, in float height = -1, in bool vflip=true){
			auto position = armos.math.Vector2f(0, 0);
			auto size = armos.app.currentWindow.size();
			position[1] = size[1] - (position[1] + size[1]);
			glViewport(cast(int)position[0], cast(int)position[1], cast(int)size[0], cast(int)size[1]);
		}
		
		/++
		++/
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
			
			armos.math.Matrix4f lookAt = lookAtViewMatrix(
				armos.math.Vector3f(eyeX, eyeY, dist),
				armos.math.Vector3f(eyeX, eyeY, 0),
				armos.math.Vector3f(0, 1, 0)
			);
			
			glMatrixMode(GL_PROJECTION);
			glLoadIdentity();
			
			glLoadMatrixf((persp*lookAt).array.ptr);
			glScalef(1, -1, 1);
			glTranslatef(0, -viewH, 0);
			glMatrixMode(GL_MODELVIEW);
		}
		
		/++
		++/
		void startRender(){
			// setBackground(currentStyle.backgroundColor );
			if(_isUseFbo){
				_fbo.begin;
			}
			
			viewport();
			setupScreenPerspective();
			
			if( _isBackgroundAuto ){
				background(currentStyle.backgroundColor );
			}
		};
		
		/++
		++/
		void finishRender(){
			if(_isUseFbo){
				_fbo.end;
				armos.types.Color tmp = currentStyle.color;
				setColor(0xFFFFFF);
				
				bool isEnableDepthTest;
				glGetBooleanv(GL_DEPTH_TEST, cast(ubyte*)&isEnableDepthTest);
				disableDepthTest;
				
				_fbo.draw;
				setColor(tmp);
				if(isEnableDepthTest){
					enableDepthTest;
				}
			}
		};
		
		/++
		++/
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
		
		/++
		++/
		void drawRectangle(in float x, in float y, in float w, in float h){
			armos.graphics.Vertex[4] vertices;
			vertices[0].x = x;
			vertices[0].y = y;
			vertices[0].z = 0;
			
			vertices[1].x = x;
			vertices[1].y = y+h;
			vertices[1].z = 0;
			
			vertices[2].x = x+w;
			vertices[2].y = y+h;
			vertices[2].z = 0;
		
			vertices[3].x = x+w;
			vertices[3].y = y;
			vertices[3].z = 0;
			
			armos.graphics.TexCoord[] texCoords;
			int[4] indices = [0, 1, 2, 3];
			
			armos.graphics.PolyRenderMode renderMode;
			if(_currentStyle.isFill){
				renderMode = armos.graphics.PolyRenderMode.Fill;
			}else{
				renderMode = armos.graphics.PolyRenderMode.WireFrame;
			}
			draw(
				vertices,
				null,
				null,
				texCoords,
				indices, 
				armos.graphics.PrimitiveMode.Quads, 
				renderMode,
				true,
				false,
				false
			);
		}
		
		/++
		++/
		void draw(
			in armos.graphics.Mesh mesh,
			armos.graphics.PolyRenderMode renderMode,
			bool useColors,
			bool useTextures,
			bool useNormals
		){
			draw(
				mesh.vertices,
				mesh.normals,
				mesh.colors, 
				mesh.texCoords,
				mesh.indices, 
				mesh.primitiveMode,
				renderMode,
				useColors,
				useTextures,
				useNormals
			);
		}
		
		/++
		++/
		void draw(
			in armos.graphics.Vertex[] vertices,
			in armos.graphics.Normal[] normals,
			in armos.types.FloatColor[] colors,
			in armos.graphics.TexCoord[] texCoords,
			in int[] indices,
			in armos.graphics.PrimitiveMode primitiveMode, 
			armos.graphics.PolyRenderMode renderMode,
			bool useColors,
			bool useTextures,
			bool useNormals
		){
			
			glPolygonMode(GL_FRONT_AND_BACK, armos.graphics.getGLPolyRenderMode(renderMode));
			//add vertices to GL
			if(vertices.length){
				glEnableClientState(GL_VERTEX_ARRAY);
				glVertexPointer(3, GL_FLOAT, 0, vertices.ptr);
			}
			
			//add normals to GL
			if(normals.length && useNormals){
				glEnableClientState(GL_NORMAL_ARRAY);
				glNormalPointer(GL_FLOAT, 0, normals.ptr);
			}
			
			//add colors to GL
			if(colors.length && useColors){
				glEnableClientState(GL_COLOR_ARRAY);
				glColorPointer(4, GL_FLOAT, armos.types.FloatColor.sizeof, colors.ptr);
			}
			
			//add texchoords to gl
			if(texCoords.length){
				glEnableClientState(GL_TEXTURE_COORD_ARRAY);
				glTexCoordPointer(2, GL_FLOAT, 0, texCoords.ptr);
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
			
			
			if(indices.length){
				glDrawElements(
					armos.graphics.getGLPrimitiveMode(primitiveMode),
					cast(int)indices.length,
					GL_UNSIGNED_INT,
					indices.ptr
				);
			}
			
			glPolygonMode(GL_FRONT_AND_BACK, armos.graphics.currentStyle.isFill ?  GL_FILL : GL_LINE);
			
			if(vertices.length){
				glDisableClientState(GL_VERTEX_ARRAY);
			}
			if(texCoords.length){
				glDisableClientState(GL_TEXTURE_COORD_ARRAY);
			}
		}
		
		/++
		++/
		void enableDepthTest(){
			setDepthTest(true);
		}
		
		/++
		++/
		void disableDepthTest(){
			setDepthTest(false);
		}
		
		/++
		++/
		void setDepthTest(bool b){
			if(b){
				glEnable(GL_DEPTH_TEST);
			}else{
				glDisable(GL_DEPTH_TEST);
			}
			_currentStyle.isDepthTest = b;
		}
		
		/++
		++/
		void blendMode(armos.graphics.BlendMode mode){
			switch (mode) {
				case BlendMode.Alpha:
					glEnable(GL_BLEND);
					glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
					break;
				case BlendMode.Add:
					glEnable(GL_BLEND);
					glBlendFunc(GL_ONE, GL_ONE);
					break;
				case BlendMode.Disable:
					glDisable(GL_BLEND);
					break;
				default:
					assert(0);
			}
			_currentStyle.blendMode = mode;
		}
		
		/++
		++/
		void enableFbo(){
			_isUseFbo = true;
		}
		
		/++
		++/
		void disableFbo(){
			_isUseFbo = false;
		}
	}//public
	
	private{
		armos.graphics.Fbo _fbo;
		bool _isUseFbo = true;
		auto _currentStyle = armos.graphics.Style();
		armos.graphics.Style[] _styleStack;
		bool _isBackgroundAuto = true;
	}//private
}

/++
++/
armos.graphics.Renderer* currentRenderer(){
	return &armos.app.mainLoop.renderer;
}

/++
++/
armos.graphics.Style currentStyle(){
	return armos.graphics.currentRenderer.currentStyle;
}

/++
++/
void setStyle(in armos.graphics.Style style){
	currentRenderer.setStyle(style);
}

/++
++/
void pushStyle(){
	currentRenderer.pushStyle;
}

/++
++/
void popStyle(){
	currentRenderer.popStyle;
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
	currentRenderer.setBackgroundAuto = isAuto;
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
void drawLine(T)(in T x1, in T y1, in T z1, in T x2, in T y2, in T z2){
	import std.conv;
	currentRenderer.drawLine(x1.to!float, y1.to!float, z1.to!float, x2.to!float, y2.to!float, z2.to!float);
}

/++
++/
void drawLine(T)(in T x1, in T y1, in T x2, in T y2){
	drawLine(x1, y1, 0, x2, y2, 0);
}	

/++
++/
void drawLine(Vector)(Vector vec1, Vector vec2){
	drawLine(vec1[0], vec1[1], vec1[2], vec2[0], vec2[1], vec2[2]);
}

/++
++/
void drawRectangle(T)(in T x, in T y, in T w, in T h){
	import std.conv;
	currentRenderer.drawRectangle(x.to!float, y.to!float, w.to!float, h.to!float);
}

/++
++/
void drawRectangle(Vector)(in Vector position, in Vector size){
	drawRectangle(position[0], position[1], size[0], size[1]);
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
