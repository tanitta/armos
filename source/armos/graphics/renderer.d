module armos.graphics.renderer;

import std.math;
import derelict.opengl3.gl;
import armos.app;
import armos.graphics;
import armos.math;
import armos.types;

/// ポリゴンのレンダリング方法を表します
enum PolyRenderMode {
    Points    = GL_POINTS, /// 頂点のみ描画します．
    WireFrame = GL_LINE,   /// 線のみ描画します．
    Fill      = GL_FILL,   /// 面を塗りつぶして描画します．
}

/// ポリゴンのプリミティブを指定します．
enum PrimitiveMode{
    Triangles     = GL_TRIANGLES,
    TriangleStrip = GL_TRIANGLE_STRIP,
    TriangleFan   = GL_TRIANGLE_FAN,
    Lines         = GL_LINES,
    LineStrip     = GL_LINE_STRIP,
    LineLoop      = GL_LINE_LOOP,
    Points        = GL_POINTS,
}

/// openGLで扱うMatrixの種類を表します．
enum MatrixMode{
    ModelView  = GL_MODELVIEW,
    Projection = GL_PROJECTION,
    Texture    = GL_TEXTURE
}

///
enum BlendMode{
    Disable,
    Alpha,
    Add,
    Screen,
    Subtract
}

///
armos.graphics.Renderer currentRenderer(){
    return armos.app.mainLoop.renderer;
}

///
void background(const armos.types.Color color){
    currentRenderer.backgroundColor = color;
}

///
void background(const float gray){
    currentRenderer.backgroundColor = armos.types.Color(gray, gray, gray, 1);
}

///
void background(in float r, in float g, in float b, in float a = 1){
    currentRenderer.backgroundColor = armos.types.Color(r, g, b, a);
}

///
void isBackgrounding(in bool b){
    currentRenderer.isBackgrounding = b;
}

// ///
// void fillBackground(){
//     currentRenderer.fillBackground = currentRenderer.background;
// }
//
// ///
// void fillBackground(const armos.types.Color color){
//     currentRenderer.fillBackground = color;
// }
//
// ///
// void fillBackground(const float gray){
//     currentRenderer.fillBackground = armos.types.Color(gray, gray, gray, 1);
// }
// ///
// void fillBackground(in float r, in float g, in float b, in float a = 1){
//     currentRenderer.fillBackground = armos.types.Color(r, g, b, a);
// }

// ///
// void clear(in armos.types.Color c){
//     currentRenderer.fillBackground(c);
// }

/++
+/
pragma(msg, __FILE__, "(", __LINE__, "): ",
       "TODO: move armos.graphics.defaultrenderer");
void color(in float r, in float g, in float b, in float a = 1){
    pragma(msg, __FILE__, "(", __LINE__, "): ",
           "TODO: work if called by defaultrenderer");
    pragma(msg, __FILE__, "(", __LINE__, "): ",
           "TODO: enable to work");
    // currentRenderer.color = armos.types.Color(r, g, b, a);
}

/++
+/
pragma(msg, __FILE__, "(", __LINE__, "): ",
       "TODO: move armos.graphics.defaultrenderer");
void color(const armos.types.Color c){
    pragma(msg, __FILE__, "(", __LINE__, "): ",
           "TODO: work if called by defaultrenderer");
    pragma(msg, __FILE__, "(", __LINE__, "): ",
           "TODO: enable to work");
    // currentRenderer.color = c;
}

/++
+/
pragma(msg, __FILE__, "(", __LINE__, "): ",
       "TODO: move armos.graphics.defaultrenderer");
void color(const float gray){
    pragma(msg, __FILE__, "(", __LINE__, "): ",
           "TODO: work if called by defaultrenderer");
    pragma(msg, __FILE__, "(", __LINE__, "): ",
           "TODO: enable to work");
    // currentRenderer.color = armos.types.Color(gray, gray, gray, 1);
}

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

///
enum Capability {
    DepthTest = GL_DEPTH_TEST, 
}//enum GlCapability
/++
+/
void isUsing(in Capability cap, in bool b){
    currentRenderer.capability(cap, b);
}

/++
+/
void blendMode(armos.graphics.BlendMode mode){
    currentRenderer.blendMode(mode);
}

///
mixin armos.graphics.matrixstack.MatrixStackFunction!("Model");

///
mixin armos.graphics.matrixstack.MatrixStackFunction!("View");

///
mixin armos.graphics.matrixstack.MatrixStackFunction!("Projection");

///
mixin armos.graphics.matrixstack.MatrixStackFunction!("Texture");

// armos.math.Matrix4f modelViewProjectionMatrix(){
//     return projectionMatrix * viewMatrix * modelMatrix;
// }

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
    return ScopedMatrixStack(currentScene.modelMatrixStack, matrix);
}

ScopedMatrixStack scopedViewMatrix(in armos.math.Matrix4f matrix = armos.math.Matrix4f.identity){
    return ScopedMatrixStack(currentScene.viewMatrixStack, matrix);
}

ScopedMatrixStack scopedProjectionMatrix(in armos.math.Matrix4f matrix = armos.math.Matrix4f.identity){
    return ScopedMatrixStack(currentScene.projectionMatrixStack, matrix);
}

ScopedMatrixStack scopedTextureMatrix(in armos.math.Matrix4f matrix = armos.math.Matrix4f.identity){
    return ScopedMatrixStack(currentScene.textureMatrixStack, matrix);
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


///
pragma(msg, __FILE__, "(", __LINE__, "): ",
       "TODO: check VAO support");

interface Renderer {
    alias This = this;
    public{
        //inputs
        This vao(Vao, in bool save = false);
        This attribute(in string name, Buffer, in bool save = false);
        This indices(Buffer, in bool save = false);
        This texture(in string name, Texture, in bool save = false);
        This polyRenderMode(PolyRenderMode mode, in bool save = false);

        This capability(Capability cap, bool b, in bool save = false);
        bool capability(Capability cap);
        This blendMode(BlendMode blendMode, in bool save = false);
        This isBackgrounding(in bool b);
        
        //output
        Fbo  target();
        This target(Fbo);

        This shader(Shader);
        This render();
    }//public

    protected{
        This setUniformImpl(in string name, Uniform u, in bool save = false);
        This setBackgroundColor(in float r, in float g, in float b, in float a, in bool save = false);

    }//private
}//interface Renderer

import std.meta:staticIndexOf;
Renderer uniform(T)(Renderer r, in string name, T v, in bool save = false)if(staticIndexOf!(T, AcceptableUniformTypes)!=-1)
{
    return r.setUniformImpl(name, Uniform(v), save);
}

Renderer uniform(Renderer r, in string name, Uniform u, in bool save = false){
    return r.setUniformImpl(name, u, save);
}

///
Renderer viewMatrix(Renderer r, Matrix4f m, in bool save = false){
    return r.uniform("viewMatrix", m.nestedArray, save);
} //set from camera

///
Renderer modelMatrix(Renderer r, Matrix4f m, in bool save = false){
    return r.uniform("modelMatrix", m.nestedArray, save);
} //set from scene

///
Renderer textureMatrix(Renderer r, Matrix4f m, in bool save = false){
    return r.uniform("textureMatrix", m.nestedArray, save);
}

///
Renderer projectionMatrix(Renderer r, Matrix4f m, in bool save = false){
    return r.uniform("projectionMatrix", m.nestedArray, save);
} // set from camera and target buffer size

Renderer backgroundColor(Renderer r, Color color, in bool save = false){
    return r.setBackgroundColor(color.r, color.g, color.b, color.a, save);
};

///
private struct Cachable(T) {
    T content;
    bool isSaved;
    bool hasChanged;
}//struct Cachable

Cachable!T cachable(T)(T content, in bool save = false){
    return Cachable!T(content, save, true);
}

class DefaultRenderer: Renderer{
    public{
        import armos.utils.scoped: scoped;
        this(){
            _target = new Fbo(Vector2i(0, 0));

            import armos.graphics.material:defaultVertexShaderSource,
                                           defaultFragmentShaderSource;
            _shader = (new Shader).loadSources(defaultVertexShaderSource,
                                               "",
                                               defaultFragmentShaderSource);
            import std.stdio;
            _shader.log.writeln;
            _defaultVao = new Vao;
            _primitiveMode = PrimitiveMode.Triangles;
            _isBackgrounding = true;
            setupBuildinUniforms();

            auto bitmap = (new armos.graphics.Bitmap!(char))
                         .allocate(2, 2, armos.graphics.ColorFormat.RGBA)
                         .setAllPixels(0, 255)
                         .setAllPixels(1, 255)
                         .setAllPixels(2, 255)
                         .setAllPixels(3, 255);
            _textures["tex0"] = (new armos.graphics.Texture).allocate(bitmap);
        }

        //inputs
        // // This scene(Scene);

        ///
        This vao(Vao vao, in bool save = false){
            _isUsingUserVao = true;
            _vao = vao;
            return this;
        };
        
        ///
        This attribute(in string name, Buffer buffer, in bool save = false){
            _isUsingUserVao = false;
            _attributes[name] = cachable(buffer, save);
            return this;
        }

        ///
        This indices(Buffer buffer, in bool save = false){
            _indices = cachable(buffer, save);
            return this;
        }

        ///
        This texture(in string name, Texture texture, in bool save = false){
            _textures[name] = texture;
            return this;
        }

        ///
        This polyRenderMode(PolyRenderMode mode, in bool save = false){
            _polyRenderMode = cachable(mode, save);
            return this;
        }

        ///
        This isBackgrounding(in bool b){
            _isBackgrounding = b;
            return this;
        }

        ///
        This capability(Capability cap, bool b, in bool save = false){
            _capabilities[cap] = cachable(b, save);
            return this;
        }

        ///
        bool capability(Capability cap){
            return _capabilities[cap].content;
        }

        ///
        This blendMode(BlendMode blendMode, in bool save = false){
            _blendMode = cachable(blendMode, save);
            return this;
        }
        
        //output
        ///
        Fbo  target(){
            return _target;
        }

        ///
        This target(Fbo fbo){
            _target = fbo;
            return this;
        }

        ///
        This shader(Shader shader){
            _shader = shader;
            return this;
        }

        ///
        This render(){
            if(_isBackgrounding){
                glClearColor(0, 1, 0, 0);
                glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
            }

            updateBuildinUniforms();
            if(_isUsingUserVao){
                auto vaoScope = scoped(_vao);
                sendAttribsToShaderWithBindedVao();
                renderWithBindedVao();
            }else{
                auto vaoScope = scoped(_defaultVao);
                sendBuffersToBindedVao;
                sendAttribsToShaderWithBindedVao();
                renderWithBindedVao();
            }
            return this;
        }
    }//public

    protected{
        ///
        This setUniformImpl(in string name, Uniform u, in bool save = false){
            _uniforms[name] = Cachable!Uniform(u, save);
            return this;
        }

        This setBackgroundColor(in float r, in float g, in float b, in float a, in bool save = false){
            _backgroundColor.content = [r, g, b, a];
            return this;
        }
    }//protected

    private{
        Fbo _target;

        Cachable!Uniform[string] _uniforms;
        Cachable!Buffer[string] _attributes;
        Cachable!(float[4]) _backgroundColor;
        Cachable!Buffer _indices;
        Cachable!PolyRenderMode _polyRenderMode;
        bool _isBackgrounding;
        Cachable!bool[Capability] _capabilities;
        Cachable!BlendMode _blendMode;
        Shader _shader;
        Vao _vao;
        Vao _defaultVao;
        bool _isUsingUserVao = false;
        PrimitiveMode _primitiveMode;
        Texture[string] _textures;

        This setupBuildinUniforms(){
            this.uniform("modelMatrix",               Matrix4f.identity.array!2);
            this.uniform("viewMatrix",                Matrix4f.identity.array!2);
            this.uniform("projectionMatrix",          Matrix4f.identity.array!2);
            this.uniform("textureMatrix",             Matrix4f.identity.array!2);
            this.uniform("modelViewMatrix",           Matrix4f.identity.array!2);
            this.uniform("modelViewProjectionMatrix", Matrix4f.identity.array!2);
            return this;
        }

        This updateBuildinUniforms(){
            auto viewMatrix       = Matrix4f.array(*_uniforms["viewMatrix"].content.peek!(float[4][4]));
            auto modelMatrix      = Matrix4f.array(*_uniforms["modelMatrix"].content.peek!(float[4][4]));
            auto projectionMatrix = Matrix4f.array(*_uniforms["projectionMatrix"].content.peek!(float[4][4]));
            this.uniform("modelViewMatrix",           (viewMatrix*modelMatrix).array!2);
            this.uniform("modelViewProjectionMatrix", (projectionMatrix*viewMatrix*modelMatrix).array!2);
            return this;
        }

        // binding requirement
        // shader : no
        // vao    : yes 
        This sendAttribsToShaderWithBindedVao(){
            import std.array:byPair;
            foreach (pair; _attributes.byPair){
                auto name   = pair[0];
                auto buffer = pair[1].content;
                buffer.begin;
                _shader.attr(name);
                buffer.end;
            }
            return this;
        }

        // binding requirement
        // shader : no 
        // vao    : yes 
        This renderWithBindedVao(){
            import std.array:byPair;
            import std.algorithm:each;
            import armos.graphics.shader.uniform:uniform;

            assert(_indices.content);

            const shaderScope= scoped(_shader);
            _uniforms.byPair.each!(u => _shader.uniform(u[0], u[1].content));

            const texturesScope = scoped(Textures(_textures));
            uint textureIndex;
            foreach (pair; _textures.byPair) {
                auto name = pair[0];
                auto texture  = pair[1];
                _shader.uniformTexture(name, texture , textureIndex);
                textureIndex++;
            }

            const iboScope       = scoped(_indices.content);
            _shader.enableAttribs();
                int elements;
                import derelict.opengl3.gl;
                glGetBufferParameteriv(GL_ELEMENT_ARRAY_BUFFER, GL_BUFFER_SIZE, &elements);
                import std.conv;
                immutable int size = (elements/GLuint.sizeof).to!int;
                glDrawElements(_primitiveMode, size, GL_UNSIGNED_INT, null);
            _shader.disableAttribs();

            return this;
        }

        This sendBuffersToBindedVao(){
            import std.algorithm;
            _attributes.values.map!(cachable => cachable.content)
                              .each!(b => b.sendToBindedVao);
            return this;
        }

        This sendBuffersToDefaultVao(){
            return this;
        }
    }//private
}//class DefaultRenderer

private struct Textures {
    import std.array:byPair;
    public{
        Textures begin(){
            foreach (pair; _textures.byPair) {
                auto texture  = pair[1];
                texture.begin;
            }
            return this;
        }

        Textures end(){
            foreach (pair; _textures.byPair) {
                auto texture  = pair[1];
                texture.end;
            }
            return this;
        }
    }//public

    private{
        Texture[string] _textures;
    }//private
}//struct Textures


/++
+/
// class Renderer {
//     mixin armos.graphics.matrixstack.MatrixStackManipulator!("Model");
//     mixin armos.graphics.matrixstack.MatrixStackManipulator!("View");
//     mixin armos.graphics.matrixstack.MatrixStackManipulator!("Projection");
//     mixin armos.graphics.matrixstack.MatrixStackManipulator!("Texture");
//    
//     public{
//        
//         /++
//         +/
//         this(){
//             _bufferMesh   = new armos.graphics.BufferMesh;
//             _materialStack ~= new armos.graphics.DefaultMaterial;
//             auto bitmap = (new armos.graphics.Bitmap!(char))
//                          .allocate(2, 2, armos.graphics.ColorFormat.RGBA)
//                          .setAllPixels(0, 255)
//                          .setAllPixels(1, 255)
//                          .setAllPixels(2, 255)
//                          .setAllPixels(3, 255);
//             currentMaterial.texture("tex0", (new armos.graphics.Texture).allocate(bitmap));
//             _bufferEntity = new armos.graphics.BufferEntity(_bufferMesh, currentMaterial);
//            
//             _modelMatrixStack.push;
//             _viewMatrixStack.push;
//             _projectionMatrixStack.push;
//             _textureMatrixStack.push;
//         }
//        
//         /++
//         +/
//         void isBackgrounding(bool b){
//             _isBackgrounding = b;
//         };
//
//         /++
//         +/
//         void background(in armos.types.Color color){
//             _currentStyle.backgroundColor = cast(armos.types.Color)color;
//             glClearColor(color.r/Color.limit,
//                          color.g/Color.limit, 
//                          color.b/Color.limit,
//                          color.a/Color.limit);
//         }
//        
//         ///
//         armos.types.Color background(){
//             return _currentStyle.backgroundColor;
//         }
//
//         /++
//         +/
//         void fillBackground(in armos.types.Color color){
//             background = color;
//             glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
//         }
//
//         /++
//         +/
//         void color(in armos.types.Color c){
//             import std.conv:to;
//             _currentStyle.color = cast(armos.types.Color)c; 
//             _materialStack[0].uniform("diffuse", armos.math.Vector4f(c.r.to!float,c.g.to!float,c.b.to!float,c.a.to!float)/Color.limit);
//             glColor4f(c.r/Color.limit,c.g/Color.limit,c.b/Color.limit,c.a/Color.limit);
//         }
//
//         /++
//         +/
//         void color(in int colorCode){
//             auto c=  armos.types.Color(colorCode);
//             color(c);
//         }
//
//         /++
//         +/
//         void style(armos.graphics.Style s){
//             color(s.color);
//             background = s.backgroundColor;
//             blendMode = s.blendMode;
//             lineWidth = s.lineWidth;
//             isSmoothingLine = s.isSmoothing;
//             isUsingDepthTest(s.isDepthTest);
//             _currentStyle.polyRenderMode = s.polyRenderMode;
//         }
//
//         /++
//         +/
//         ref armos.graphics.Style currentStyle(){
//             return _currentStyle;
//         };
//
//         /++
//         +/
//         void pushStyle(){
//             _styleStack ~= _currentStyle;
//         }
//
//         /++
//         +/
//         void popStyle(){
//             import std.range;
//             if(_styleStack.length == 0){
//                 assert(0, "stack is empty");
//             }else{
//                 _currentStyle = _styleStack[$-1];
//                 _styleStack.popBack;
//                 style(_currentStyle);
//             }
//         }
//        
//         /++
//         +/
//         void translate(T)(in T x, in T y, in T z)if(__traits(isArithmetic, T)){
//             import std.conv;
//             _modelMatrixStack.mult(translationMatrix!(float)(x, y, z));
//         }
//
//         /++
//         +/
//         void translate(V)(in V vec)if(armos.math.isVector!(V)){
//             translate(vec[0], vec[1], vec[2]);
//         };
//
//         /++
//         +/
//         void scale(T)(in T x, in T y, in T z)if(__traits(isArithmetic, T)){
//             import std.conv;
//             _modelMatrixStack.mult(scalingMatrix!(float)(x, y, z));
//         }
//
//         /++
//         +/
//        
//         void scale(V)(in V vec)if(armos.math.isVector!(V)){
//             scale(vec[0], vec[1], vec[2]);
//         }
//
//         /++
//         +/
//         void rotate(T)(in T degrees, in T vecX, in T vecY, in T vecZ)if(__traits(isArithmetic, T)){
//             import std.conv;
//             _modelMatrixStack.mult(rotationMatrix!(float)(degrees, vecX, vecY, vecZ));
//         }
//        
//         ///
//         void rotate(T, V)(in T degrees, in V vec)if(__traits(isArithmetic, T) && armos.math.isVector!(V)){
//             rotate(degrees, vec[0], vec[1], vec[2]);
//         }
//
//         /++
//         +/
//         void lineWidth(T)(in T width)if(__traits(isArithmetic, T)){
//             import std.conv;
//             _currentStyle.lineWidth = width.to!float;
//             glLineWidth(width.to!float);
//         }
//
//         /++
//         +/
//         void isSmoothingLine(in bool smooth){
//             _currentStyle.isSmoothing = smooth;
//         }
//
//         /++
//         +/
//         void setup(){
//             _fbo = (new armos.graphics.Fbo).minFilter(TextureMinFilter.Linear);
//             glEnable(GL_LINE_SMOOTH);
//             glHint(GL_POINT_SMOOTH_HINT, GL_NICEST);
//             import std.conv;
//             viewport(Vector2f.zero, armos.app.currentWindow.frameBufferSize.to!Vector2f);
//
//             if(_isUseFbo){
//                 _fbo.begin;
//             }
//
//             fillBackground(currentStyle.backgroundColor);
//
//             if(_isUseFbo){
//                 _fbo.end;
//             }
//         };
//
//         /++
//         +/
//         void resize(){
//             if(_isUseFbo){
//                 import std.conv;
//                 _fbo.resize((armos.app.currentWindow.frameBufferSize.to!Vector2f/armos.app.currentWindow.pixelScreenCoordScale).to!Vector2i);
//                 _fbo.begin;
//             }
//
//             fillBackground(currentStyle.backgroundColor );
//
//             if(_isUseFbo){
//                 _fbo.end;
//             }
//         }
//
//         /++
//         +/
//         void startRender(){
//             _projectionMatrixStack.push;
//             import std.conv;
//             auto windowSize = (armos.app.currentWindow.frameBufferSize.to!Vector2f/armos.app.currentWindow.pixelScreenCoordScale).to!Vector2i;
//             _projectionMatrixStack.load(screenPerspectiveMatrix(windowSize));
//             _projectionMatrixStack.mult(scalingMatrix!float(1f, -1f, 1f)*translationMatrix!float(0, -windowSize.y, 0));
//             if(_isUseFbo){
//                 _fbo.begin;
//             }
//             if( _isBackgrounding ){
//                 fillBackground(currentStyle.backgroundColor);
//             }
//         };
//
//         /++
//         +/
//         void finishRender(){
//             armos.types.Color tmp = currentStyle.color;
//             bool isEnableDepthTest;
//             if(_isUseFbo){
//                 _fbo.end;
//                 color(0xFFFFFF);
//
//                 glGetBooleanv(GL_DEPTH_TEST, cast(ubyte*)&isEnableDepthTest);
//                 disableDepthTest;
//             }
//
//             import std.conv;
//             viewport(Vector2f.zero, armos.app.currentWindow.frameBufferSize.to!Vector2f);
//
//             if(_isUseFbo) _fbo.draw;
//             _projectionMatrixStack.pop;
//             color(tmp);
//             if(isEnableDepthTest){
//                 enableDepthTest;
//             }
//         };
//
//         /++
//         +/
//         void drawLine(in float x1, in float y1, in float z1, in float x2, in float y2, in float z2){
//             armos.math.Vector4f[2] vertices = [
//                 armos.math.Vector4f(x1, y1, z1, 1f), 
//                 armos.math.Vector4f(x2, y2, z2, 1f)
//             ];
//             immutable freq = armos.graphics.BufferUsageFrequency.Dynamic;
//             immutable nature = armos.graphics.BufferUsageNature.Draw;
//             auto shader = currentMaterial.shader;
//            
//             import armos.utils.scoped;
//             const scopedVao    = scoped(_bufferMesh.vao);
//             const scopedMaterial = scoped(currentMaterial);
//            
//             _bufferMesh.attrs["vertex"].array(vertices, freq, nature);
//            
//             _bufferMesh.attrs["vertex"].begin;
//             shader.attr("vertex");
//             _bufferMesh.attrs["vertex"].end;
//            
//             shader.uniform("modelViewMatrix", viewMatrix * modelMatrix);
//             shader.uniform("projectionMatrix", projectionMatrix);
//             shader.uniform("modelViewProjectionMatrix", modelViewProjectionMatrix);
//            
//             const scopedShader = scoped(shader);
//             shader.enableAttrib("vertex");
//             glDrawArrays(GL_LINES, 0, vertices.length);
//             shader.disableAttrib("vertex");
//         };
//
//         /++
//         +/
//         void drawRectangle(in float x, in float y, in float w, in float h){
//             armos.math.Vector4f[4] vertices;
//             vertices[0] = armos.math.Vector4f(x,   y,   0f, 1f);
//             vertices[1] = armos.math.Vector4f(x,   y+h, 0f, 1f);
//             vertices[2] = armos.math.Vector4f(x+w, y+h, 0f, 1f);
//             vertices[3] = armos.math.Vector4f(x+w, y,   0f, 1f);
//
//             armos.math.Vector4f[] texCoords = [
//                 armos.math.Vector4f(0f, 0f, 0.0, 1.0f),
//                 armos.math.Vector4f(0,  1f, 0.0, 1.0f),
//                 armos.math.Vector4f(1f, 1f, 0.0, 1.0f),
//                 armos.math.Vector4f(1f, 0,  0.0, 1.0f),
//             ];
//
//             int[] indices = [0, 1, 2, 2, 3, 0];
//
//             draw(
//                 vertices,
//                 null,
//                 null,
//                 texCoords,
//                 indices, 
//                 armos.graphics.PrimitiveMode.TriangleStrip, 
//                 _currentStyle.polyRenderMode, 
//                 true,
//                 false,
//                 false
//             );
//         }
//
//         /++
//         +/
//         void draw(
//             armos.graphics.Mesh mesh,
//             in armos.graphics.PolyRenderMode renderMode,
//             in bool useColors,
//             in bool useTextures,
//             in bool useNormals
//         ){
//             draw(
//                 mesh.vertices,
//                 mesh.normals,
//                 mesh.colors, 
//                 mesh.texCoords,
//                 mesh.indices, 
//                 mesh.primitiveMode,
//                 renderMode,
//                 useColors,
//                 useTextures,
//                 useNormals
//             );
//         }
//
//         /++
//         +/
//         void draw(
//             armos.math.Vector4f[] vertices,
//             armos.math.Vector3f[] normals,
//             armos.types.FloatColor[] colors,
//             armos.math.Vector4f[] texCoords,
//             int[] indices,
//             in armos.graphics.PrimitiveMode primitiveMode, 
//             in armos.graphics.PolyRenderMode renderMode,
//             in bool useColors,
//             in bool useTextures,
//             in bool useNormals
//         ){
//             immutable freq = armos.graphics.BufferUsageFrequency.Dynamic;
//             immutable nature = armos.graphics.BufferUsageNature.Draw;
//            
//             import armos.utils.scoped;
//             const scopedVao = scoped(_bufferMesh.vao);
//            
//             //set attr
//             _bufferMesh.attrs["vertex"].array(vertices, freq, nature);
//             if(useNormals) _bufferMesh.attrs["normal"].array(normals, freq, nature);
//             import std.algorithm;
//             import std.array;
//             if(useColors) _bufferMesh.attrs["color"].array(colors.map!(c => armos.math.Vector4f(c.r, c.g, c.b, c.a)).array, freq, nature);
//             _bufferMesh.attrs["texCoord0"].array(texCoords, freq, nature);
//             _bufferMesh.attrs["index"].array(indices, 0, freq, nature);
//            
//             _bufferEntity.updateShaderAttribs;
//                
//             glPolygonMode(GL_FRONT_AND_BACK, renderMode);
//             _bufferEntity.primitiveMode(primitiveMode).draw();
//             glPolygonMode(GL_FRONT_AND_BACK, _currentStyle.polyRenderMode);
//         }
//
//         /++
//         +/
//         void isUsingDepthTest(in bool b){
//             if(b){
//                 glEnable(GL_DEPTH_TEST);
//             }else{
//                 glDisable(GL_DEPTH_TEST);
//             }
//             _currentStyle.isDepthTest = b;
//         }
//        
//         /++
//         +/
//         void isUsingFbo(in bool b){
//             _isUseFbo = b;
//         }
//
//         /++
//         +/
//         void blendMode(armos.graphics.BlendMode mode){
//             switch (mode) {
//                 case BlendMode.Alpha:
//                     glEnable(GL_BLEND);
//                     glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
//                     break;
//                 case BlendMode.Add:
//                     glEnable(GL_BLEND);
//                     glBlendFunc(GL_ONE, GL_ONE);
//                     break;
//                 case BlendMode.Disable:
//                     glDisable(GL_BLEND);
//                     break;
//                 default:
//                     assert(0);
//             }
//             _currentStyle.blendMode = mode;
//         }
//
//         void pushMaterialStack(armos.graphics.Material material){
//             _materialStack ~= material;
//             _bufferEntity.material = currentMaterial;
//         }
//        
//         void popMaterialStack(){
//             import std.range;
//             if (_materialStack.length == 0) {
//                 assert(0, "stack is empty");
//             }else{
//                 _materialStack.popBack;
//             }
//             _bufferEntity.material = currentMaterial;
//            
//         }
//        
//         armos.graphics.Material currentMaterial(){
//             return _materialStack[$-1];
//         }
//        
//         void samples(in int s){
//             _fbo.samples = s;
//         }
//            
//         int samples()const{
//             return _fbo.samples;
//            
//         }
//     }//public
//
//     private{
//         armos.graphics.Fbo _fbo;
//         bool               _isUseFbo = true;
//        
//         armos.graphics.Style   _currentStyle = armos.graphics.Style();
//         armos.graphics.Style[] _styleStack;
//        
//         armos.graphics.Material[]     _materialStack;
//        
//         armos.graphics.BufferMesh   _bufferMesh;
//         armos.graphics.BufferEntity _bufferEntity;
//        
//         bool _isBackgrounding = true;
//     }//private
// }

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

deprecated("Use armos.utils.debugtool"){
    ///
    void drawGridPlane(
            in float stepSize, in int numberOfSteps,
            in bool labels=false 
            ){
        for (int i = -numberOfSteps; i <= numberOfSteps; i++) {
            drawLine( -stepSize*numberOfSteps, 0.0,  i*stepSize,              stepSize*numberOfSteps, 0.0, i*stepSize             );
            drawLine( i*stepSize,              0.0,  -stepSize*numberOfSteps, i*stepSize            , 0.0, stepSize*numberOfSteps );
        }
    }

    ///
    void drawAxis(in float size){
        // pushStyle;{
        //     lineWidth = 2.0;
        //     color(1, 0, 0);
        //     drawLine(-size*0.5, 0.0, 0.0, size, 0.0,  0.0);
        //     color(0, 1, 0);
        //     drawLine(0.0, -size*0.5, 0.0, 0.0,  size, 0.0);
        //     color(0, 0, 1);
        //     drawLine(0.0, 0.0, -size*0.5, 0.0,  0.0,  size);
        // }popStyle;
    }

    ///
    void drawGrid(
            in float stepSize, in int numberOfSteps,
            in bool labels=false, in bool x=true, in bool y=true, in bool z=true
            ){
        // pushStyle;{
        //     pushMatrix;{
        //         rotate(90.0, 0, 0, 1);
        //         if(x){
        //             color(1, 0, 0);
        //             drawGridPlane(stepSize, numberOfSteps);
        //         }
        //         rotate(-90.0, 0, 0, 1);
        //         if(y){
        //             color(0, 1, 0);
        //             drawGridPlane(stepSize, numberOfSteps);
        //         }
        //         rotate(90.0, 1, 0, 0);
        //         if(z){
        //             color(0, 0, 1);
        //             drawGridPlane(stepSize, numberOfSteps);
        //         }
        //     }popMatrix;
        // }popStyle;
    }
}

// ///
// armos.graphics.Style currentStyle(){
//     return armos.graphics.currentRenderer.currentStyle;
// }
//
// ///
// void style(in armos.graphics.Style s){
//     currentRenderer.style(s);
// }
//
// ///
// void pushStyle(){
//     currentRenderer.pushStyle;
// }
//
// ///
// void popStyle(){
//     currentRenderer.popStyle;
// }
