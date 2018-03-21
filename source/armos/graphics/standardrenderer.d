module armos.graphics.standardrenderer;

import armos.graphics.renderer:Renderer,
                               uniform, 
                               backgroundColor;
import armos.graphics.defaultrenderer:DefaultRenderer;
import armos.graphics.renderer;
import armos.graphics.gl.shader:Shader;
import armos.graphics.gl.vao:Vao;
import armos.graphics.gl.uniform:Uniform,
                                 uniform,
                                 uniformTexture;
import armos.graphics.gl.primitivemode;
import armos.graphics.gl.texture:Texture;
import armos.graphics.gl.buffer;

import armos.math;

class StandardRenderer : DefaultRenderer{
    import armos.math:Matrix4f;
    private alias This = this;
    public{
        // This vertices(T)(T[] arr, size_t dim){
        //     return this;
        // }
        //
        // This indices(T)(T arr){
        //     return this;
        // }

        override This setup(){
            import armos.graphics.material:defaultVertexShaderSource,
                   defaultFragmentShaderSource;
            _shader = (new Shader).loadSources(defaultVertexShaderSource,
                    "",
                    defaultFragmentShaderSource);
            import std.stdio;
            _shader.log.writeln;

            // lazy allocate on time of setting attribute
            // setupBuffers();

            _defaultVao = new Vao;
            _primitiveMode = PrimitiveMode.Triangles;
            _backgroundColor = [0.1, 0.1, 0.1, 1.0];
            this.diffuse = [1.0f, 1.0f, 1.0f, 1.0f];
            setupBuildinUniforms();

            import armos.graphics.pixel;
            auto bitmap = (new armos.graphics.Bitmap!(char))
                .allocate(1, 1, ColorFormat.RGBA)
                .setAllPixels(0, 255)
                .setAllPixels(1, 255)
                .setAllPixels(2, 255)
                .setAllPixels(3, 255);
            _textures["tex0"] = (new Texture).allocate(bitmap);
            return this;
        }
    }

    override This render(){
        updateBuildinUniforms;
        if(_isUsingUserVao){
            renderVao(_vao);
        }else{
            registerBuffersToDefaultVao;
            renderVao(_defaultVao);
        }
        return this;
    }

    private{
        void setupBuffers(){
            _attributes["position"]  = new Buffer();
            _attributes["normal"]    = new Buffer();
            _attributes["tangent"]   = new Buffer();
            _attributes["texCoord0"] = new Buffer();
            _attributes["texCoord1"] = new Buffer();
            _attributes["color"]     = new Buffer();
            _indexBuffer             = new Buffer(BufferType.ElementArray);
        }
        
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
            auto viewMatrix       = Matrix4f.array(*_uniforms["viewMatrix"].peek!(float[4][4]));
            auto modelMatrix      = Matrix4f.array(*_uniforms["modelMatrix"].peek!(float[4][4]));
            auto projectionMatrix = Matrix4f.array(*_uniforms["projectionMatrix"].peek!(float[4][4]));
            this.uniform("modelViewMatrix",           (modelMatrix*viewMatrix).array!2);
            this.uniform("modelViewProjectionMatrix", (modelMatrix*viewMatrix*projectionMatrix).array!2);
            return this;
        }
    }
}

///
Renderer diffuse(Renderer renderer, float[4] c){
    renderer.uniform("diffuse", c);
    return renderer;
}

///
Renderer diffuse(Renderer renderer, in float r, in float g, in float b, in float a = 1){
    float[4] arr = [r, g, b, a];
    renderer.uniform("diffuse", arr);
    return renderer;
}

import armos.types.color;
///
Renderer diffuse(Renderer renderer, Color c){
    float[4] arr = [c.r, c.g, c.b, c.a];
    renderer.uniform("diffuse", arr);
    return renderer;
}

import armos.graphics.standardvertex;

///
Renderer vertices(
    Renderer renderer,
    StandardVertex[] vertices,
    BufferUsageFrequency freq   = BufferUsageFrequency.Dynamic,
    BufferUsageNature    nature = BufferUsageNature.Draw
){
    // if(!renderer.attrBuffer("position")) renderer.attrBuffer("position", new Buffer());
    // import std.algorithm;
    // import std.array;
    // renderer.attrBuffer("position").array(vertices.map!(vert => vert.position).array, 
    //                               freq, 
    //                               nature);
    // _attributes["normal"]    = new Buffer();
    // _attributes["tangent"]   = new Buffer();
    // _attributes["texCoord0"] = new Buffer();
    // _attributes["texCoord1"] = new Buffer();
    // _attributes["color"]     = new Buffer();
    return renderer;
}

///
Renderer positions(Renderer renderer, Buffer buffer){
    return renderer.attribute("position", buffer);
}

///
Renderer positions(
    Renderer renderer,
    Vector4f[] arr,
    BufferUsageFrequency freq   = BufferUsageFrequency.Dynamic,
    BufferUsageNature    nature = BufferUsageNature.Draw
){
    if(!renderer.attrBuffer("position")) renderer.attrBuffer("position", new Buffer());
    import std.algorithm;
    import std.array;
    renderer.attrBuffer("position").array(arr, freq, nature);
    return renderer;
}

///
Renderer indices(
    Renderer renderer,
    int[] arr,
    BufferUsageFrequency freq   = BufferUsageFrequency.Dynamic,
    BufferUsageNature    nature = BufferUsageNature.Draw
){
    if(!renderer.indexBuffer) renderer.indexBuffer(new Buffer(BufferType.ElementArray));
    import std.algorithm;
    import std.array;
    renderer.indexBuffer().array(arr, 1, freq, nature);
    return renderer;
}

///
Renderer colors(Renderer renderer, Buffer buffer){
    return renderer.attribute("color", buffer);
}

///
Renderer colors(
    Renderer renderer,
    Vector4f[] arr,
    BufferUsageFrequency freq   = BufferUsageFrequency.Dynamic,
    BufferUsageNature    nature = BufferUsageNature.Draw
){
    if(!renderer.attrBuffer("color")) renderer.attrBuffer("color", new Buffer());
    import std.algorithm;
    import std.array;
    renderer.attrBuffer("color").array(arr, freq, nature);
    return renderer;
}

///
Renderer normals(Renderer renderer, Buffer buffer){
    return renderer.attribute("normal", buffer);
}

///
Renderer normals(
    Renderer renderer,
    Vector3f[] arr,
    BufferUsageFrequency freq   = BufferUsageFrequency.Dynamic,
    BufferUsageNature    nature = BufferUsageNature.Draw
){
    if(!renderer.attrBuffer("normal")) renderer.attrBuffer("normal", new Buffer());
    import std.algorithm;
    import std.array;
    renderer.attrBuffer("normal").array(arr, freq, nature);
    return renderer;
}

///
Renderer tangents(Renderer renderer, Buffer buffer){
    return renderer.attribute("tangent", buffer);
}

Renderer tangents(
    Renderer renderer,
    Vector3f[] arr,
    BufferUsageFrequency freq   = BufferUsageFrequency.Dynamic,
    BufferUsageNature    nature = BufferUsageNature.Draw
){
    if(!renderer.attrBuffer("tangent")) renderer.attrBuffer("tangent", new Buffer());
    import std.algorithm;
    import std.array;
    renderer.attrBuffer("tangent").array(arr, freq, nature);
    return renderer;
}

///
Renderer texCoords0(Renderer renderer, Buffer buffer){
    return renderer.attribute("texCoord0", buffer);
}

///
Renderer texCoords0(
    Renderer renderer,
    Vector4f[] arr,
    BufferUsageFrequency freq   = BufferUsageFrequency.Dynamic,
    BufferUsageNature    nature = BufferUsageNature.Draw
){
    if(!renderer.attrBuffer("texCoord0")) renderer.attrBuffer("texCoord0", new Buffer());
    import std.algorithm;
    import std.array;
    renderer.attrBuffer("texCoord0").array(arr, freq, nature);
    return renderer;
}

///
Renderer texCoords1(Renderer renderer, Buffer buffer){
    return renderer.attribute("texCoord1", buffer);
}

Renderer texCoords1(
    Renderer renderer,
    Vector4f[] arr,
    BufferUsageFrequency freq   = BufferUsageFrequency.Dynamic,
    BufferUsageNature    nature = BufferUsageNature.Draw
){
    if(!renderer.attrBuffer("texCoord1")) renderer.attrBuffer("texCoord1", new Buffer());
    import std.algorithm;
    import std.array;
    renderer.attrBuffer("texCoord1").array(arr, freq, nature);
    return renderer;
}
