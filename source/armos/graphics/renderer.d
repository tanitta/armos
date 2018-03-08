module armos.graphics.renderer;

import std.math;
import derelict.opengl3.gl;

import armos.graphics.gl.vao;
import armos.graphics.gl.fbo;
import armos.graphics.gl.buffer;
import armos.graphics.gl.texture;
import armos.graphics.gl.shader;
import armos.graphics.gl.polyrendermode;
import armos.graphics.gl.primitivemode;
import armos.graphics.gl.blendmode;
import armos.graphics.gl.capability;
import armos.app;
import armos.math;
import armos.types;


pragma(msg, __FILE__, "(", __LINE__, "): ",
       "TODO: check VAO support");
///
interface Renderer {
    alias This = this;
    public{
        //inputs
        This vao(Vao);
        This attribute(in string name, Buffer);
        This indices(Buffer);
        This texture(in string name, Texture);
        This polyRenderMode(PolyRenderMode mode);
        This capability(Capability cap, bool b);
        This blendMode(BlendMode blendMode);
        This fillBackground();
        This target(Fbo);
        This shader(Shader);
        This uniformImpl(in string name, Uniform u);
        This backgroundColorImpl(in float r, in float g, in float b, in float a);
        
        //output
        Fbo  target();

        This setup();
        This render();
        // This renderer(Renderer);
    }//public

}//interface Renderer

template isRenderer(R){
    enum bool isRenderer = __traits(compiles, (){
        R r;
        Renderer ir = r;
    });
}

version(unittest){
    class RendererMock: Renderer{
        private alias This = this;
        public {
            This vao(Vao){return this;}
            This attribute(in string name, Buffer){return this;}
            This indices(Buffer){return this;}
            This texture(in string name, Texture){return this;}
            This polyRenderMode(PolyRenderMode mode){return this;}
            This capability(Capability cap, bool b){return this;}
            This blendMode(BlendMode blendMode){return this;}
            This fillBackground(){return this;}
            This target(Fbo){return this;}
            This shader(Shader){return this;}
            This uniformImpl(in string name, Uniform u){return this;}
            This backgroundColorImpl(in float r, in float g, in float b, in float a){return this;}

            //output
            Fbo  target(){return new Fbo;}

            This setup(){return this;}
            This render(){return this;}
        }
    }
}
unittest{
    assert(isRenderer!(RendererMock));
}

Renderer currentRenderer()
out(renderer){
    assert(renderer);
}body{
    import armos.app.runner;
    return mainLoop.currentEnvironment.renderer;
}

///
Renderer viewMatrix(Renderer r, Matrix4f m){
    return r.uniform("viewMatrix", m.transpose.nestedArray);
} //set from camera

///
Renderer modelMatrix(Renderer r, Matrix4f m){
    return r.uniform("modelMatrix", m.transpose.nestedArray);
} //set from scene

///
Renderer textureMatrix(Renderer r, Matrix4f m){
    return r.uniform("textureMatrix", m.transpose.nestedArray);
}

///
Renderer projectionMatrix(Renderer r, Matrix4f m){
    return r.uniform("projectionMatrix", m.transpose.nestedArray);
} // set from camera and target buffer size

Renderer backgroundColor(Renderer renderer, in float r, in float g, in float b, in float a){
    return renderer.backgroundColorImpl(r, g, b, a);
};

Renderer backgroundColor(Renderer r, Color color){
    return r.backgroundColorImpl(color.r, color.g, color.b, color.a);
};

Renderer backgroundColor(Renderer r, float[4] c){
    return r.backgroundColorImpl(c[0], c[1], c[2], c[3]);
};


/++
+/
pragma(msg, __FILE__, "(", __LINE__, "): ",
       "TODO: move armos.graphics.defaultRenderer");
void drawLine(T)(in T x1, in T y1, in T z1, in T x2, in T y2, in T z2){
    import std.conv;
    pragma(msg, __FILE__, "(", __LINE__, "): ",
           "TODO: enable to work");
    // currentRenderer.drawLine(x1.to!float, y1.to!float, z1.to!float, x2.to!float, y2.to!float, z2.to!float);
}

/++
+/
pragma(msg, __FILE__, "(", __LINE__, "): ",
       "TODO: move armos.graphics.defaultRenderer");
void drawLine(T)(in T x1, in T y1, in T x2, in T y2){
    drawLine(x1, y1, 0, x2, y2, 0);
}	

/++
+/
pragma(msg, __FILE__, "(", __LINE__, "): ",
       "TODO: move armos.graphics.defaultRenderer");
void drawLine(V)(in V vec1, in V vec2)if(armos.math.isVector!(V) && V.dimention == 3){
    drawLine(vec1[0], vec1[1], vec1[2], vec2[0], vec2[1], vec2[2]);
}

/++
+/
pragma(msg, __FILE__, "(", __LINE__, "): ",
       "TODO: move armos.graphics.defaultRenderer");
void drawLine(V)(in V vec1, in V vec2)if(armos.math.isVector!(V) && V.dimention == 2){
    drawLine(vec1[0], vec1[1], 0, vec2[0], vec2[1], 0);
}

/++
+/
pragma(msg, __FILE__, "(", __LINE__, "): ",
       "TODO: move armos.graphics.defaultRenderer");
void drawRectangle(T)(in T x, in T y, in T w, in T h){
    import std.conv;
    pragma(msg, __FILE__, "(", __LINE__, "): ",
           "TODO: enable to work");
    // currentRenderer.drawRectangle(x.to!float, y.to!float, w.to!float, h.to!float);
}

/++
+/
void drawRectangle(Vector)(in Vector position, in Vector size){
    drawRectangle(position[0], position[1], size[0], size[1]);
}

///
void pushMatrix(){
    currentContext.pushModelMatrix;
}

///
void popMatrix(){
    currentContext.popModelMatrix;
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
    immutable ans = M.array(
        [
            [1, 0, 0, 2], 
            [0, 1, 0, 3], 
            [0, 0, 1, 4], 
            [0, 0, 0, 1], 
        ]);
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
    immutable ans = M.array(
        [
            [1, 0, 0, 2], 
            [0, 1, 0, 3], 
            [0, 0, 1, 4], 
            [0, 0, 0, 1], 
        ]);
    assert(M.identity.translate(2.0, 3.0, 4.0) == ans);
}

/++
+/
void translate(T)(in T x, in T y, in T z)if(__traits(isArithmetic, T)){
    import std.conv;
    currentContext.multModelMatrix(translationMatrix(x.to!float, y.to!float, z.to!float));
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
    immutable ans = M.array(
        [
            [2, 0, 0, 0], 
            [0, 3, 0, 0], 
            [0, 0, 4, 0], 
            [0, 0, 0, 1], 
        ]);
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
    immutable ans = M.array(
        [
            [2, 0, 0, 0], 
            [0, 3, 0, 0], 
            [0, 0, 4, 0], 
            [0, 0, 0, 1], 
        ]);
    assert(M.identity.scale(2, 3, 4) == ans);
}

/++
+/
void scale(in float x, in float y, in float z){
    currentContext.multModelMatrix(scalingMatrix(x, y, z));
}

/++
+/
void scale(in float s){
    scale(s, s, s);
}

/++
+/
void scale(in armos.math.Vector3f vec){
    scale(vec[0], vec[1], vec[2]);
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
    immutable r = M3.array([
        [E(0),     -n[2], n[1] ], 
        [n[2],  E(0),     -n[0]], 
        [-n[1], n[0],  E(0)    ], 
    ]);
    immutable m = M3.identity + sin(d)*r + (1-cos(d))*r*r;
    immutable t = M4.identity.setMatrix(m);
    return t;
}

unittest{
    alias M = armos.math.Matrix4d;
    immutable m = rotationMatrix(PI, 0.0, 1.0, 0.0);
    immutable ans = M.array([
        [-1, 0, 0, 0], 
        [0, 1, 0, 0], 
        [0, 0, -1, 0], 
        [0, 0, 0, 1], 
    ]);
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
    immutable ans = M.array([
        [-1, 0, 0, 0], 
        [0, 1, 0, 0], 
        [0, 0, -1, 0], 
        [0, 0, 0, 1], 
    ]);
    
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
    currentContext.multModelMatrix(rotationMatrix!float(rad, vec_x, vec_y, vec_z));
}

/++
+/
void rotate(T, V)(in T rad, V vec)if(__traits(isArithmetic, T) && armos.math.isVector!(V)){
    rotate(rad, vec[0], vec[1], vec[2], vec[3]);
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

///
// mixin armos.graphics.matrixstack.MatrixStackFunction!("Model");
//
// ///
// mixin armos.graphics.matrixstack.MatrixStackFunction!("View");
//
// ///
// mixin armos.graphics.matrixstack.MatrixStackFunction!("Projection");
//
// ///
// mixin armos.graphics.matrixstack.MatrixStackFunction!("Texture");

// armos.math.Matrix4f modelViewProjectionMatrix(){
//     return projectionMatrix * viewMatrix * modelMatrix;
// }

import armos.graphics.gl.stack;

///
private struct ScopedMatrixStack{
    public{
        this(Stack!Matrix4f stack, in armos.math.Matrix4f matrix){
            _stack = stack;
            _stack.push(matrix);
            _stack.mult(matrix);
        }
        
        ~this(){
            _stack.pop;
        }
    }//public

    private{
        Stack!Matrix4f _stack;
    }//private
}//struct ScopedMatrixStack

import armos.graphics.gl.context;

///
ScopedMatrixStack scopedModelMatrix(in armos.math.Matrix4f matrix = armos.math.Matrix4f.identity){
    return ScopedMatrixStack(currentContext.matrixStack(MatrixType.Model), matrix);
}

///
ScopedMatrixStack scopedViewMatrix(in armos.math.Matrix4f matrix = armos.math.Matrix4f.identity){
    return ScopedMatrixStack(currentContext.matrixStack(MatrixType.View), matrix);
}

///
ScopedMatrixStack scopedProjectionMatrix(in armos.math.Matrix4f matrix = armos.math.Matrix4f.identity){
    return ScopedMatrixStack(currentContext.matrixStack(MatrixType.Projection), matrix);
}

///
ScopedMatrixStack scopedTextureMatrix(in armos.math.Matrix4f matrix = armos.math.Matrix4f.identity){
    return ScopedMatrixStack(currentContext.matrixStack(MatrixType.Texture), matrix);
}

// ///
// void currentMaterial(armos.graphics.Material material){
//     currentRenderer.currentMaterial = material;
// }

// ///
// void pushMaterialStack(armos.graphics.Material material){
//     currentRenderer.pushMaterialStack(material);
// }
//
// ///
// void popMaterialStack(){
//     currentRenderer.popMaterialStack;
// }
//
// ///
// armos.graphics.Material currentMaterial(){
//     return currentRenderer.currentMaterial;
// }
///



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

    return armos.math.Matrix4f.array([
        [2.0*zNear/(right-left), 0.0,                    A,    0.0 ],
        [0.0,                    2.0*zNear/(top-bottom), B,    0.0 ],
        [0.0,                    0.0,                    C,    D   ],
        [0.0,                    0.0,                    -1.0, 0.0 ]
    ]);
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

    return armos.math.Matrix4f.array([
        [xaxis[0], xaxis[1], xaxis[2], -xaxis.dotProduct(eye)],
        [yaxis[0], yaxis[1], yaxis[2], -yaxis.dotProduct(eye)],
        [zaxis[0], zaxis[1], zaxis[2], -zaxis.dotProduct(eye)],
        [0f,       0f,       0f,       1f                    ]
    ]);
};
