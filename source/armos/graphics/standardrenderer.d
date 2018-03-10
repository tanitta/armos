module armos.graphics.standardrenderer;

import armos.graphics.renderer:Renderer,
                               uniform, 
                               backgroundColor;

import armos.graphics.defaultrenderer:DefaultRenderer;
import armos.graphics.gl.shader:Shader;
import armos.graphics.gl.vao:Vao;
import armos.graphics.gl.uniform:Uniform, uniform, uniformTexture;
import armos.graphics.gl.primitivemode;
import armos.graphics.gl.texture:Texture;

class StandardRenderer : DefaultRenderer{
    import armos.math:Matrix4f;
    private alias This = this;
    override This setup(){
        import armos.graphics.material:defaultVertexShaderSource,
               defaultFragmentShaderSource;
        _shader = (new Shader).loadSources(defaultVertexShaderSource,
                "",
                defaultFragmentShaderSource);
        import std.stdio;
        _shader.log.writeln;
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
            // this.uniform("modelViewProjectionMatrix", (projectionMatrix*viewMatrix*modelMatrix).transpose.array!2);
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
