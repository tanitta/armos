module armos.graphics.renderer;

import std.math;
import derelict.opengl3.gl;
import armos.app;
import armos.graphics;
import armos.math;
import armos.types;

/++
ポリゴンのレンダリング方法を表します
+/
enum PolyRenderMode {
    Points    = GL_POINTS, /// 頂点のみ描画します．
    WireFrame = GL_LINE,   /// 線のみ描画します．
    Fill      = GL_FILL,   /// 面を塗りつぶして描画します．
}

/++
ポリゴンのプリミティブを指定します．
+/
enum PrimitiveMode{
    Triangles     = GL_TRIANGLES,
    TriangleStrip = GL_TRIANGLE_STRIP,
    TriangleFan   = GL_TRIANGLE_FAN,
    Lines         = GL_LINES,
    LineStrip     = GL_LINE_STRIP,
    LineLoop      = GL_LINE_LOOP,
    Points        = GL_POINTS,
}

/++
openGLで扱うMatrixの種類を表します．
+/
enum MatrixMode{
    ModelView  = GL_MODELVIEW,
    Projection = GL_PROJECTION,
    Texture    = GL_TEXTURE
}

/++
+/
enum BlendMode{
    Disable,
    Alpha,
    Add,
    Screen,
    Subtract
}

/++
+/
armos.graphics.Renderer currentRenderer(){
    return armos.app.mainLoop.renderer;
}

/++
+/
armos.graphics.Style currentStyle(){
    return armos.graphics.currentRenderer.currentStyle;
}

/++
+/
void style(in armos.graphics.Style s){
    currentRenderer.style(s);
}

/++
+/
void pushStyle(){
    currentRenderer.pushStyle;
}

/++
+/
void popStyle(){
    currentRenderer.popStyle;
}

/++
+/
void background(const armos.types.Color color){
    currentRenderer.background = color;
}

/++
+/
void background(const float gray){
    currentRenderer.background = armos.types.Color(gray, gray, gray, 1);
}

/++
+/
void background(in float r, in float g, in float b, in float a = 1){
    currentRenderer.background = armos.types.Color(r, g, b, a);
}

///
void fillBackground(){
    currentRenderer.fillBackground = currentRenderer.background;
}

///
void fillBackground(const armos.types.Color color){
    currentRenderer.fillBackground = color;
}

///
void fillBackground(const float gray){
    currentRenderer.fillBackground = armos.types.Color(gray, gray, gray, 1);
}
///
void fillBackground(in float r, in float g, in float b, in float a = 1){
    currentRenderer.fillBackground = armos.types.Color(r, g, b, a);
}

/++
+/
void isBackgrounding(in bool b){
    currentRenderer.isBackgrounding = b;
}

///
void clear(in armos.types.Color c){
    currentRenderer.fillBackground(c);
}

/++
+/
void color(in float r, in float g, in float b, in float a = 1){
    currentRenderer.color = armos.types.Color(r, g, b, a);
}

/++
+/
void color(const armos.types.Color c){
    currentRenderer.color = c;
}

/++
+/
void color(const float gray){
    currentRenderer.color = armos.types.Color(gray, gray, gray, 1);
}

/++
+/
void drawLine(T)(in T x1, in T y1, in T z1, in T x2, in T y2, in T z2){
    import std.conv;
    currentRenderer.drawLine(x1.to!float, y1.to!float, z1.to!float, x2.to!float, y2.to!float, z2.to!float);
}

/++
+/
void drawLine(T)(in T x1, in T y1, in T x2, in T y2){
    drawLine(x1, y1, 0, x2, y2, 0);
}	

/++
+/
void drawLine(V)(in V vec1, in V vec2)if(armos.math.isVector!(V) && V.dimention == 3){
    drawLine(vec1[0], vec1[1], vec1[2], vec2[0], vec2[1], vec2[2]);
}

/++
+/
void drawLine(V)(in V vec1, in V vec2)if(armos.math.isVector!(V) && V.dimention == 2){
    drawLine(vec1[0], vec1[1], 0, vec2[0], vec2[1], 0);
}

/++
+/
void drawRectangle(T)(in T x, in T y, in T w, in T h){
    import std.conv;
    currentRenderer.drawRectangle(x.to!float, y.to!float, w.to!float, h.to!float);
}

/++
+/
void drawRectangle(Vector)(in Vector position, in Vector size){
    drawRectangle(position[0], position[1], size[0], size[1]);
}

/++
+/
void drawGridPlane(
        in float stepSize, in int numberOfSteps,
        in bool labels=false 
        ){
    for (int i = -numberOfSteps; i <= numberOfSteps; i++) {
        drawLine( -stepSize*numberOfSteps, 0.0,  i*stepSize,              stepSize*numberOfSteps, 0.0, i*stepSize             );
        drawLine( i*stepSize,              0.0,  -stepSize*numberOfSteps, i*stepSize            , 0.0, stepSize*numberOfSteps );
    }
}

/++
+/
void drawAxis(
        in float size
        ){
    pushStyle;{
        lineWidth = 2.0;
        color(1, 0, 0);
        drawLine(-size*0.5, 0.0, 0.0, size, 0.0,  0.0);
        color(0, 1, 0);
        drawLine(0.0, -size*0.5, 0.0, 0.0,  size, 0.0);
        color(0, 0, 1);
        drawLine(0.0, 0.0, -size*0.5, 0.0,  0.0,  size);
    }popStyle;
}

/++
+/
void drawGrid(
        in float stepSize, in int numberOfSteps,
        in bool labels=false, in bool x=true, in bool y=true, in bool z=true
        ){
    pushStyle;{
        pushMatrix;{
            rotate(90.0, 0, 0, 1);
            if(x){
                color(1, 0, 0);
                drawGridPlane(stepSize, numberOfSteps);
            }
            rotate(-90.0, 0, 0, 1);
            if(y){
                color(0, 1, 0);
                drawGridPlane(stepSize, numberOfSteps);
            }
            rotate(90.0, 1, 0, 0);
            if(z){
                color(0, 0, 1);
                drawGridPlane(stepSize, numberOfSteps);
            }
        }popMatrix;
    }popStyle;
}

/++
+/
void popMatrix(){
    // currentRenderer.popMatrix();
    popModelMatrix;
}

/++
+/
void pushMatrix(){
    // currentRenderer.pushMatrix();
    pushModelMatrix;
}

///
M translationMatrix(T, M = armos.math.Matrix!(T, 4, 4))(in T x, in T y, in T z)
if(armos.math.isMatrix!(M) && __traits(isArithmetic, T) && M.rowSize == 4){
    import std.conv;
    auto t = M.identity;
    t[0][M.colSize-1] = x.to!(M.elementType);
    t[1][M.colSize-1] = y.to!(M.elementType);
    t[2][M.colSize-1] = z.to!(M.elementType);
    return t;
}

unittest{
    alias M = armos.math.Matrix4f;
    M m = translationMatrix(2f, 3f, 4f);
    immutable ans = M(
            [1, 0, 0, 2], 
            [0, 1, 0, 3], 
            [0, 0, 1, 4], 
            [0, 0, 0, 1], 
            );
    assert(m == ans);
}

///
M translate(M, T)(in M matrix, in T x, in T y, in T z)
if(armos.math.isMatrix!(M) && __traits(isArithmetic, T) && M.rowSize == 4){
    import std.conv;
    alias E = M.elementType;
    return matrix * translationMatrix(x.to!E, y.to!E, z.to!E);
}

unittest{
    alias M = armos.math.Matrix4d;
    immutable ans = M(
            [1, 0, 0, 2], 
            [0, 1, 0, 3], 
            [0, 0, 1, 4], 
            [0, 0, 0, 1], 
            );
    assert(M.identity.translate(2.0, 3.0, 4.0) == ans);
}

/++
+/
void translate(T)(in T x, in T y, in T z)if(__traits(isArithmetic, T)){
    import std.conv;
    multModelMatrix(translationMatrix(x.to!float, y.to!float, z.to!float));
}

///
void translate(V:VT!(T, D), alias VT, T, int D)(in V vec)if(armos.math.isVector!(V) && __traits(isArithmetic, T) && D == 3){
    translate(vec[0], vec[1], vec[2]);
}

///
void translate(V:VT!(T, D), alias VT, T, int D)(in V vec)if(armos.math.isVector!(V) && __traits(isArithmetic, T) && D == 2){
    translate(vec[0], vec[1], T(0));
}

///
M scalingMatrix(T, M = armos.math.Matrix!(T, 4, 4))(in T x, in T y, in T z)
if(armos.math.isMatrix!(M) && __traits(isArithmetic, T) && M.rowSize == 4){
    import std.conv;
    auto t = M.identity;
    t[0][0] = x.to!(M.elementType);
    t[1][1] = y.to!(M.elementType);
    t[2][2] = z.to!(M.elementType);
    return t;
}

unittest{
    alias M = armos.math.Matrix4d;
    M m = scalingMatrix(2.0, 3.0, 4.0);
    immutable ans = M(
            [2, 0, 0, 0], 
            [0, 3, 0, 0], 
            [0, 0, 4, 0], 
            [0, 0, 0, 1], 
            );
    assert(m == ans);
}

///
M scale(M, T)(in M matrix, in T x, in T y, in T z)
if(
    armos.math.isMatrix!(M) && 
    __traits(isArithmetic, T) && 
    M.rowSize == 4
){
    import std.conv;
    alias E = M.elementType;
    return matrix * scalingMatrix(x.to!E, y.to!E, z.to!E);
}

unittest{
    alias M = armos.math.Matrix4d;
    immutable ans = M(
            [2, 0, 0, 0], 
            [0, 3, 0, 0], 
            [0, 0, 4, 0], 
            [0, 0, 0, 1], 
            );
    assert(M.identity.scale(2, 3, 4) == ans);
}

/++
+/
void scale(float x, float y, float z){
    multModelMatrix(scalingMatrix(x, y, z));
}

/++
+/
void scale(float s){
    multModelMatrix(scalingMatrix(s, s, s));
}

/++
+/
void scale(armos.math.Vector3f vec){
    multModelMatrix(scalingMatrix(vec[0], vec[1], vec[2]));
}

///
M4 rotationMatrix(T, M4 = armos.math.Matrix!(T, 4, 4))(in T rad, in T x, in T y, in T z)
if(armos.math.isMatrix!(M4) && __traits(isArithmetic, T) && M4.rowSize == 4){
    import std.conv;
    import std.math;
    alias E = M4.elementType;
    alias M3 = armos.math.Matrix!(E, 3, 3);
    immutable E d = rad.to!E;
    immutable n = armos.math.Vector!(E, 3)(x, y, z).normalized;
    immutable r = M3(
        [E(0),     -n[2], n[1] ], 
        [n[2],  E(0),     -n[0]], 
        [-n[1], n[0],  E(0)    ], 
    );
    immutable m = M3.identity + sin(d)*r + (1-cos(d))*r*r;
    immutable t = M4.identity.setMatrix(m);
    return t;
}

unittest{
    alias M = armos.math.Matrix4d;
    immutable m = rotationMatrix(PI, 0.0, 1.0, 0.0);
    immutable ans = M(
            [-1, 0, 0, 0], 
            [0, 1, 0, 0], 
            [0, 0, -1, 0], 
            [0, 0, 0, 1], 
            );
    import std.math;
    foreach (int i, ref r; m.elements) {
        foreach (int j, ref c; r.elements) {
            assert(approxEqual(c, ans[i][j]));
        }
    }
}

///
M rotate(M, T)(in M matrix, in T rad, in T x, in T y, in T z)
if(armos.math.isMatrix!(M) && __traits(isArithmetic, T) && M.rowSize == 4){
    import std.conv;
    alias E = M.elementType;
    return matrix * rotationMatrix(rad.to!E, x.to!E, y.to!E, z.to!E);
}

unittest{
    alias M = armos.math.Matrix4d;
    immutable ans = M(
            [-1, 0, 0, 0], 
            [0, 1, 0, 0], 
            [0, 0, -1, 0], 
            [0, 0, 0, 1], 
            );
    
    import std.math;
    immutable m = M.identity.rotate(PI, 0.0, 1.0, 0.0);
    foreach (int i, ref r; m.elements) {
        foreach (int j, ref c; r.elements) {
            assert(approxEqual(c, ans[i][j]));
        }
    }
}

/++
+/
void rotate(T)(in T rad, in T vec_x, in T vec_y, in T vec_z)if(__traits(isArithmetic, T)){
    multModelMatrix(rotationMatrix!float(rad, vec_x, vec_y, vec_z));
}

/++
+/
void rotate(T, V)(in T rad, V vec)if(__traits(isArithmetic, T) && armos.math.isVector!(V)){
    
    multModelMatrix(rotationMatrix(rad, vec[0], vec[1], vec[2]));
}

// /++
// +/
// void loadIdentity(){
//     currentRenderer.loadIdentity();
// }
//
// /++
// +/
// void loadMatrix(Q)(Q matrix){
//     currentRenderer.loadMatrix(matrix);
// }
//
// /++
// +/
// void multMatrix(Q)(Q matrix){
//     currentRenderer.multMatrix(matrix);
// }

/++
+/
void lineWidth(float width){
    currentRenderer.lineWidth(width);
}

/++
+/
void isUsingDepthTest(in bool b){
    currentRenderer.isUsingDepthTest(b);
}
/++
+/
void enableDepthTest(){
    currentRenderer.isUsingDepthTest(true);
}

/++
+/
void disableDepthTest(){
    currentRenderer.isUsingDepthTest(false);
}

/++
+/
void isUsingFbo(in bool b){
    currentRenderer.isUsingFbo(b);
}

/++
+/
void enableUsingFbo(){
    currentRenderer.isUsingFbo(true);
}

/++
+/
void disableUsingFbo(){
    currentRenderer.isUsingFbo(false);
}

/++
+/
void blendMode(armos.graphics.BlendMode mode){
    currentRenderer.blendMode = mode;
}

///
mixin armos.graphics.matrixstack.MatrixStackFunction!("Model");

///
mixin armos.graphics.matrixstack.MatrixStackFunction!("View");

///
mixin armos.graphics.matrixstack.MatrixStackFunction!("Projection");

///
mixin armos.graphics.matrixstack.MatrixStackFunction!("Texture");

armos.math.Matrix4f modelViewProjectionMatrix(){
    return projectionMatrix * viewMatrix * modelMatrix;
}

/++
+/
private struct ScopedMatrixStack{
    public{
        this(armos.graphics.MatrixStack matrixStack, in armos.math.Matrix4f matrix){
            _matrixStack = matrixStack;
            _matrixStack.push();
            _matrixStack.mult(matrix);
        }
        
        ~this(){
            _matrixStack.pop;
        }
    }//public

    private{
        armos.graphics.MatrixStack _matrixStack;
    }//private
}//struct ScopedMatrixStack

ScopedMatrixStack scopedModelMatrix(in armos.math.Matrix4f matrix = armos.math.Matrix4f.identity){
    return ScopedMatrixStack(currentRenderer._modelMatrixStack, matrix);
}

ScopedMatrixStack scopedViewMatrix(in armos.math.Matrix4f matrix = armos.math.Matrix4f.identity){
    return ScopedMatrixStack(currentRenderer._viewMatrixStack, matrix);
}

ScopedMatrixStack scopedProjectionMatrix(in armos.math.Matrix4f matrix = armos.math.Matrix4f.identity){
    return ScopedMatrixStack(currentRenderer._projectionMatrixStack, matrix);
}

ScopedMatrixStack scopedTextureMatrix(in armos.math.Matrix4f matrix = armos.math.Matrix4f.identity){
    return ScopedMatrixStack(currentRenderer._textureMatrixStack, matrix);
}

// ///
// void currentMaterial(armos.graphics.Material material){
//     currentRenderer.currentMaterial = material;
// }

///
void pushMaterialStack(armos.graphics.Material material){
    currentRenderer.pushMaterialStack(material);
}

///
void popMaterialStack(){
    currentRenderer.popMaterialStack;
}

///
armos.graphics.Material currentMaterial(){
    return currentRenderer.currentMaterial;
}

///
void samples(in int s){
    currentRenderer.samples = s;
}
    
///
int samples(){
    return currentRenderer.samples;
    
}

///
armos.graphics.Fbo currentFbo(){
    return currentRenderer._fbo;
}

/++
+/
class Renderer {
    mixin armos.graphics.matrixstack.MatrixStackManipulator!("Model");
    mixin armos.graphics.matrixstack.MatrixStackManipulator!("View");
    mixin armos.graphics.matrixstack.MatrixStackManipulator!("Projection");
    mixin armos.graphics.matrixstack.MatrixStackManipulator!("Texture");
    
    public{
        
        /++
        +/
        this(){
            _bufferMesh   = new armos.graphics.BufferMesh;
            _materialStack ~= new armos.graphics.DefaultMaterial;
            auto bitmap = (new armos.graphics.Bitmap!(char))
                         .allocate(2, 2, armos.graphics.ColorFormat.RGBA)
                         .setAllPixels(0, 255)
                         .setAllPixels(1, 255)
                         .setAllPixels(2, 255)
                         .setAllPixels(3, 255);
            currentMaterial.texture("tex0", (new armos.graphics.Texture).allocate(bitmap));
            _bufferEntity = new armos.graphics.BufferEntity(_bufferMesh, currentMaterial);
            
            _modelMatrixStack.push;
            _viewMatrixStack.push;
            _projectionMatrixStack.push;
            _textureMatrixStack.push;
        }
        
        /++
        +/
        void isBackgrounding(bool b){
            _isBackgrounding = b;
        };

        /++
        +/
        void background(in armos.types.Color color){
            _currentStyle.backgroundColor = cast(armos.types.Color)color;
            glClearColor(color.r/Color.limit,
                         color.g/Color.limit, 
                         color.b/Color.limit,
                         color.a/Color.limit);
        }
        
        ///
        armos.types.Color background(){
            return _currentStyle.backgroundColor;
        }

        /++
        +/
        void fillBackground(in armos.types.Color color){
            background = color;
            glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        }

        /++
        +/
        void color(in armos.types.Color c){
            import std.conv:to;
            _currentStyle.color = cast(armos.types.Color)c; 
            _materialStack[0].uniform("diffuse", armos.math.Vector4f(c.r.to!float,c.g.to!float,c.b.to!float,c.a.to!float)/Color.limit);
            glColor4f(c.r/Color.limit,c.g/Color.limit,c.b/Color.limit,c.a/Color.limit);
        }

        /++
        +/
        void color(in int colorCode){
            auto c=  armos.types.Color(colorCode);
            color(c);
        }

        /++
        +/
        void style(armos.graphics.Style s){
            color(s.color);
            background = s.backgroundColor;
            blendMode = s.blendMode;
            lineWidth = s.lineWidth;
            isSmoothingLine = s.isSmoothing;
            isUsingDepthTest(s.isDepthTest);
            _currentStyle.polyRenderMode = s.polyRenderMode;
        }

        /++
        +/
        ref armos.graphics.Style currentStyle(){
            return _currentStyle;
        };

        /++
        +/
        void pushStyle(){
            _styleStack ~= _currentStyle;
        }

        /++
        +/
        void popStyle(){
            import std.range;
            if(_styleStack.length == 0){
                assert(0, "stack is empty");
            }else{
                _currentStyle = _styleStack[$-1];
                _styleStack.popBack;
                style(_currentStyle);
            }
        }
        
        /++
        +/
        void translate(T)(in T x, in T y, in T z)if(__traits(isArithmetic, T)){
            import std.conv;
            _modelMatrixStack.mult(translationMatrix!(float)(x, y, z));
        }

        /++
        +/
        void translate(V)(in V vec)if(armos.math.isVector!(V)){
            translate(vec[0], vec[1], vec[2]);
        };

        /++
        +/
        void scale(T)(in T x, in T y, in T z)if(__traits(isArithmetic, T)){
            import std.conv;
            _modelMatrixStack.mult(scalingMatrix!(float)(x, y, z));
        }

        /++
        +/
        
        void scale(V)(in V vec)if(armos.math.isVector!(V)){
            scale(vec[0], vec[1], vec[2]);
        }

        /++
        +/
        void rotate(T)(in T degrees, in T vecX, in T vecY, in T vecZ)if(__traits(isArithmetic, T)){
            import std.conv;
            _modelMatrixStack.mult(rotationMatrix!(float)(degrees, vecX, vecY, vecZ));
        }
        
        ///
        void rotate(T, V)(in T degrees, in V vec)if(__traits(isArithmetic, T) && armos.math.isVector!(V)){
            rotate(degrees, vec[0], vec[1], vec[2]);
        }

        /++
        +/
        void lineWidth(T)(in T width)if(__traits(isArithmetic, T)){
            import std.conv;
            _currentStyle.lineWidth = width.to!float;
            glLineWidth(width.to!float);
        }

        /++
        +/
        void isSmoothingLine(in bool smooth){
            _currentStyle.isSmoothing = smooth;
        }

        /++
        +/
        void setup(){
            _fbo = (new armos.graphics.Fbo).minFilter(TextureMinFilter.Linear);
            glEnable(GL_LINE_SMOOTH);
            glHint(GL_POINT_SMOOTH_HINT, GL_NICEST);
            import std.conv;
            viewport(Vector2f.zero, armos.app.currentWindow.frameBufferSize.to!Vector2f);

            if(_isUseFbo){
                _fbo.begin;
            }

            fillBackground(currentStyle.backgroundColor);

            if(_isUseFbo){
                _fbo.end;
            }
        };

        /++
        +/
        void resize(){
            if(_isUseFbo){
                import std.conv;
                _fbo.resize((armos.app.currentWindow.frameBufferSize.to!Vector2f/armos.app.currentWindow.pixelScreenCoordScale).to!Vector2i);
                _fbo.begin;
            }

            fillBackground(currentStyle.backgroundColor );

            if(_isUseFbo){
                _fbo.end;
            }
        }

        /++
        +/
        void startRender(){
            _projectionMatrixStack.push;
            import std.conv;
            auto windowSize = (armos.app.currentWindow.frameBufferSize.to!Vector2f/armos.app.currentWindow.pixelScreenCoordScale).to!Vector2i;
            _projectionMatrixStack.load(screenPerspectiveMatrix(windowSize));
            _projectionMatrixStack.mult(scalingMatrix!float(1f, -1f, 1f)*translationMatrix!float(0, -windowSize.y, 0));
            if(_isUseFbo){
                _fbo.begin;
            }
            if( _isBackgrounding ){
                fillBackground(currentStyle.backgroundColor);
            }
        };

        /++
        +/
        void finishRender(){
            armos.types.Color tmp = currentStyle.color;
            bool isEnableDepthTest;
            if(_isUseFbo){
                _fbo.end;
                color(0xFFFFFF);

                glGetBooleanv(GL_DEPTH_TEST, cast(ubyte*)&isEnableDepthTest);
                disableDepthTest;
            }

            import std.conv;
            viewport(Vector2f.zero, armos.app.currentWindow.frameBufferSize.to!Vector2f);

            if(_isUseFbo) _fbo.draw;
            _projectionMatrixStack.pop;
            color(tmp);
            if(isEnableDepthTest){
                enableDepthTest;
            }
        };

        /++
        +/
        void drawLine(in float x1, in float y1, in float z1, in float x2, in float y2, in float z2){
            armos.math.Vector4f[2] vertices = [
                armos.math.Vector4f(x1, y1, z1, 1f), 
                armos.math.Vector4f(x2, y2, z2, 1f)
            ];
            immutable freq = armos.graphics.BufferUsageFrequency.Dynamic;
            immutable nature = armos.graphics.BufferUsageNature.Draw;
            auto shader = currentMaterial.shader;
            
            import armos.utils.scoped;
            const scopedVao    = scoped(_bufferMesh.vao);
            const scopedMaterial = scoped(currentMaterial);
            
            _bufferMesh.attrs["vertex"].array(vertices, freq, nature);
            
            _bufferMesh.attrs["vertex"].begin;
            shader.attr("vertex");
            _bufferMesh.attrs["vertex"].end;
            
            shader.uniform("modelViewMatrix", viewMatrix * modelMatrix);
            shader.uniform("projectionMatrix", projectionMatrix);
            shader.uniform("modelViewProjectionMatrix", modelViewProjectionMatrix);
            
            const scopedShader = scoped(shader);
            shader.enableAttrib("vertex");
            glDrawArrays(GL_LINES, 0, vertices.length);
            shader.disableAttrib("vertex");
        };

        /++
        +/
        void drawRectangle(in float x, in float y, in float w, in float h){
            armos.math.Vector4f[4] vertices;
            vertices[0] = armos.math.Vector4f(x,   y,   0f, 1f);
            vertices[1] = armos.math.Vector4f(x,   y+h, 0f, 1f);
            vertices[2] = armos.math.Vector4f(x+w, y+h, 0f, 1f);
            vertices[3] = armos.math.Vector4f(x+w, y,   0f, 1f);

            armos.math.Vector4f[] texCoords = [
                armos.math.Vector4f(0f, 0f, 0.0, 1.0f),
                armos.math.Vector4f(0,  1f, 0.0, 1.0f),
                armos.math.Vector4f(1f, 1f, 0.0, 1.0f),
                armos.math.Vector4f(1f, 0,  0.0, 1.0f),
            ];

            int[] indices = [0, 1, 2, 2, 3, 0];

            draw(
                vertices,
                null,
                null,
                texCoords,
                indices, 
                armos.graphics.PrimitiveMode.TriangleStrip, 
                _currentStyle.polyRenderMode, 
                true,
                false,
                false
            );
        }

        /++
        +/
        void draw(
            armos.graphics.Mesh mesh,
            in armos.graphics.PolyRenderMode renderMode,
            in bool useColors,
            in bool useTextures,
            in bool useNormals
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
        +/
        void draw(
            armos.math.Vector4f[] vertices,
            armos.math.Vector3f[] normals,
            armos.types.FloatColor[] colors,
            armos.math.Vector4f[] texCoords,
            int[] indices,
            in armos.graphics.PrimitiveMode primitiveMode, 
            in armos.graphics.PolyRenderMode renderMode,
            in bool useColors,
            in bool useTextures,
            in bool useNormals
        ){
            immutable freq = armos.graphics.BufferUsageFrequency.Dynamic;
            immutable nature = armos.graphics.BufferUsageNature.Draw;
            
            import armos.utils.scoped;
            const scopedVao = scoped(_bufferMesh.vao);
            
            //set attr
            _bufferMesh.attrs["vertex"].array(vertices, freq, nature);
            if(useNormals) _bufferMesh.attrs["normal"].array(normals, freq, nature);
            import std.algorithm;
            import std.array;
            if(useColors) _bufferMesh.attrs["color"].array(colors.map!(c => armos.math.Vector4f(c.r, c.g, c.b, c.a)).array, freq, nature);
            _bufferMesh.attrs["texCoord0"].array(texCoords, freq, nature);
            _bufferMesh.attrs["index"].array(indices, 0, freq, nature);
            
            _bufferEntity.updateShaderAttribs;
                
            glPolygonMode(GL_FRONT_AND_BACK, renderMode);
            _bufferEntity.primitiveMode(primitiveMode).draw();
            glPolygonMode(GL_FRONT_AND_BACK, _currentStyle.polyRenderMode);
        }

        /++
        +/
        void isUsingDepthTest(in bool b){
            if(b){
                glEnable(GL_DEPTH_TEST);
            }else{
                glDisable(GL_DEPTH_TEST);
            }
            _currentStyle.isDepthTest = b;
        }
        
        /++
        +/
        void isUsingFbo(in bool b){
            _isUseFbo = b;
        }

        /++
        +/
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

        void pushMaterialStack(armos.graphics.Material material){
            _materialStack ~= material;
            _bufferEntity.material = currentMaterial;
        }
        
        void popMaterialStack(){
            import std.range;
            if (_materialStack.length == 0) {
                assert(0, "stack is empty");
            }else{
                _materialStack.popBack;
            }
            _bufferEntity.material = currentMaterial;
            
        }
        
        armos.graphics.Material currentMaterial(){
            return _materialStack[$-1];
        }
        
        void samples(in int s){
            _fbo.samples = s;
        }
            
        int samples()const{
            return _fbo.samples;
            
        }
    }//public

    private{
        armos.graphics.Fbo _fbo;
        bool               _isUseFbo = true;
        
        armos.graphics.Style   _currentStyle = armos.graphics.Style();
        armos.graphics.Style[] _styleStack;
        
        armos.graphics.Material[]     _materialStack;
        
        armos.graphics.BufferMesh   _bufferMesh;
        armos.graphics.BufferEntity _bufferEntity;
        
        bool _isBackgrounding = true;
    }//private
}

/++
+/
void viewport(in float x, in float y, in float width, in float height, in bool vflip=true){
    Vector2f position = armos.math.Vector2f(x, y);
    import std.conv;
    Vector2f size = armos.math.Vector2f(width, height);
    viewport(position, size);
}

/++
+/
void viewport(V)(in V position, in V size, in bool vflip=true)if(isVector!V){
    V pos = position;
    if(vflip) pos[1] = size[1] - (pos[1] + size[1]);
    glViewport(cast(int)pos[0], cast(int)pos[1], cast(int)size[0], cast(int)size[1]);
}

V2 viewportSize(V2 = Vector2i)(){
    GLint[4] vp;
    glGetIntegerv(GL_VIEWPORT, vp.ptr);
    return V2(vp[2], vp[3]);
}

V2 viewportPosition(V2 = Vector2i)(){
    GLint[4] vp;
    glGetIntegerv(GL_VIEWPORT, vp.ptr);
    return V2(vp[0], vp[1]);
}

V4 viewport(V4 = Vector4i)(){
    GLint[4] vp;
    glGetIntegerv(GL_VIEWPORT, vp.ptr);
    return V4(vp[0], vp[0]);
}

///
armos.math.Matrix4f screenPerspectiveMatrix(in float width, in float height, in float fov = 60, in float nearDist = 0, in float farDist = 0){
    float viewW, viewH;
    viewW = width;
    viewH = height;

    immutable float eyeX = viewW / 2.0;
    immutable float eyeY = viewH / 2.0;
    immutable float halfFov = PI * fov / 360.0;
    immutable float theTan = tan(halfFov);
    immutable float dist = eyeY / theTan;
    immutable float aspect = viewW / viewH;
    //
    immutable float near = (nearDist==0)?dist / 10.0f:nearDist;
    immutable float far  = (farDist==0)?dist * 10.0f:farDist;

    armos.math.Matrix4f persp = perspectiveMatrix(fov, aspect, near, far);

    armos.math.Matrix4f lookAt = lookAtViewMatrix(
        armos.math.Vector3f(eyeX, eyeY, dist),
        armos.math.Vector3f(eyeX, eyeY, 0),
        armos.math.Vector3f(0, 1, 0)
    );
    
    return persp*lookAt;
}

///
armos.math.Matrix4f screenPerspectiveMatrix(V)(in V size, in float fov = 60, in float nearDist = 0, in float farDist = 0)if(isVector!V && V.dimention == 2){
    import std.conv;
    return screenPerspectiveMatrix(size.x.to!float, size.y.to!float, fov, nearDist, farDist);
}

///
armos.math.Matrix4f perspectiveMatrix(in float fov, in float aspect, in float nearDist, in float farDist){
    double tan_fovy = tan(fov*0.5*PI/180.0);
    double right  =  tan_fovy * aspect* nearDist;
    double left   = -right;
    double top    =  tan_fovy * nearDist;
    double bottom =  -top;

    return frustumMatrix(left,right,bottom,top,nearDist,farDist);
}

///
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

///
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

