static import ar = armos;
import std.stdio;

private immutable string gaussianBlurVertexShaderSource = q{
#version 330

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform mat4 modelViewProjectionMatrix;
uniform mat4 textureMatrix;
uniform vec3 lightDirection;

in vec4 vertex;
in vec3 normal;
in vec3 tangent;
in vec4 texCoord0;
in vec4 texCoord1;
in vec4 color;

out vec4 f_color;
out vec2 outtexCoord0;
out vec2 outtexCoord1;

void main(void) {
    gl_Position = modelViewProjectionMatrix * vertex;
    outtexCoord0 = texCoord0.xy;
}
};

private string gaussianbBurFragmentShaderSource(size_t R)(){ 
import std.conv:to;
return q{
#version 330
in vec2 outtexCoord0;
in vec2 outtexCoord1;

out vec4 fragColor;

uniform sampler2D tex0;
uniform bool horizontal;
uniform int width;
uniform int height;
uniform float weight[}~R.to!string~q{];

void main(void) {
    vec2 fc = outtexCoord0;
    vec3 destColor = vec3(0.0);
    if(horizontal){
        float tFrag = 1.0 / float(width);
        destColor += texture(tex0, fc + vec2(-9.0, 0.0) * tFrag).rgb * weight[9];
        destColor += texture(tex0, fc + vec2(-8.0, 0.0) * tFrag).rgb * weight[8];
        destColor += texture(tex0, fc + vec2(-7.0, 0.0) * tFrag).rgb * weight[7];
        destColor += texture(tex0, fc + vec2(-6.0, 0.0) * tFrag).rgb * weight[6];
        destColor += texture(tex0, fc + vec2(-5.0, 0.0) * tFrag).rgb * weight[5];
        destColor += texture(tex0, fc + vec2(-4.0, 0.0) * tFrag).rgb * weight[4];
        destColor += texture(tex0, fc + vec2(-3.0, 0.0) * tFrag).rgb * weight[3];
        destColor += texture(tex0, fc + vec2(-2.0, 0.0) * tFrag).rgb * weight[2];
        destColor += texture(tex0, fc + vec2(-1.0, 0.0) * tFrag).rgb * weight[1];
        destColor += texture(tex0, fc + vec2( 0.0, 0.0) * tFrag).rgb * weight[0];
        destColor += texture(tex0, fc + vec2( 1.0, 0.0) * tFrag).rgb * weight[1];
        destColor += texture(tex0, fc + vec2( 2.0, 0.0) * tFrag).rgb * weight[2];
        destColor += texture(tex0, fc + vec2( 3.0, 0.0) * tFrag).rgb * weight[3];
        destColor += texture(tex0, fc + vec2( 4.0, 0.0) * tFrag).rgb * weight[4];
        destColor += texture(tex0, fc + vec2( 5.0, 0.0) * tFrag).rgb * weight[5];
        destColor += texture(tex0, fc + vec2( 6.0, 0.0) * tFrag).rgb * weight[6];
        destColor += texture(tex0, fc + vec2( 7.0, 0.0) * tFrag).rgb * weight[7];
        destColor += texture(tex0, fc + vec2( 8.0, 0.0) * tFrag).rgb * weight[8];
        destColor += texture(tex0, fc + vec2( 9.0, 0.0) * tFrag).rgb * weight[9];
    }else{
        float tFrag = 1.0 / float(height);
        destColor += texture(tex0, fc + vec2(0.0, -9.0) * tFrag).rgb * weight[9];
        destColor += texture(tex0, fc + vec2(0.0, -8.0) * tFrag).rgb * weight[8];
        destColor += texture(tex0, fc + vec2(0.0, -7.0) * tFrag).rgb * weight[7];
        destColor += texture(tex0, fc + vec2(0.0, -6.0) * tFrag).rgb * weight[6];
        destColor += texture(tex0, fc + vec2(0.0, -5.0) * tFrag).rgb * weight[5];
        destColor += texture(tex0, fc + vec2(0.0, -4.0) * tFrag).rgb * weight[4];
        destColor += texture(tex0, fc + vec2(0.0, -3.0) * tFrag).rgb * weight[3];
        destColor += texture(tex0, fc + vec2(0.0, -2.0) * tFrag).rgb * weight[2];
        destColor += texture(tex0, fc + vec2(0.0, -1.0) * tFrag).rgb * weight[1];
        destColor += texture(tex0, fc + vec2(0.0,  0.0) * tFrag).rgb * weight[0];
        destColor += texture(tex0, fc + vec2(0.0,  1.0) * tFrag).rgb * weight[1];
        destColor += texture(tex0, fc + vec2(0.0,  2.0) * tFrag).rgb * weight[2];
        destColor += texture(tex0, fc + vec2(0.0,  3.0) * tFrag).rgb * weight[3];
        destColor += texture(tex0, fc + vec2(0.0,  4.0) * tFrag).rgb * weight[4];
        destColor += texture(tex0, fc + vec2(0.0,  5.0) * tFrag).rgb * weight[5];
        destColor += texture(tex0, fc + vec2(0.0,  6.0) * tFrag).rgb * weight[6];
        destColor += texture(tex0, fc + vec2(0.0,  7.0) * tFrag).rgb * weight[7];
        destColor += texture(tex0, fc + vec2(0.0,  8.0) * tFrag).rgb * weight[8];
        destColor += texture(tex0, fc + vec2(0.0,  9.0) * tFrag).rgb * weight[9];
    }
    fragColor = vec4(destColor, 1.0);
}
};
}
/++
+/
class GaussianBlur(int length) : ar.graphics.Material{
    import armos.math;
    import armos.types.color;
    import armos.graphics;
    mixin ar.graphics.MaterialImpl;
    public{
        this(){
            _shader = (new ar.graphics.Shader).loadSources(gaussianBlurVertexShaderSource,
                                                           "",
                                                           gaussianbBurFragmentShaderSource!length)
                                              .uniform("width", 640)
                                              .uniform("height", 480)
                                              .uniformArray("weight", gaussianPDF!length(1000.0f));
        }
    }//public

    private{
    }//private
}//class GaussianBlur

class TestApp : ar.app.BaseApp{
    override void setup(){
        // ar.graphics.enableDepthTest;
        // ar.graphics.disableUsingFbo;
        _camera = (new ar.graphics.DefaultCamera).position(ar.math.Vector3f(0, 0.1, -0.25))
                                                 .target(ar.math.Vector3f(0, 0, 0));
        
        _gaussianblurShadingMaterial = (new GaussianBlur!10);
        _fbo = new ar.graphics.Fbo;
        
        _model = (new ar.graphics.Model).load("data/bunny.fbx");
        // import std.algorithm:each;
        // _model.entities.each!(e => e.mesh.calcNormal);
        // _model.entities.each!(e => e.material = _gaussianblurShadingMaterial);
    }

    override void update(){
        _fbo.resize(ar.app.currentWindow.size);

        counter += 0.01;
        
        _fbo.begin;
            ar.graphics.fillBackground(ar.types.Color(0.125, 0.125, 0.125));
            _camera.begin;scope(exit)_camera.end;
            ar.graphics.pushMatrix;scope(exit)ar.graphics.popMatrix;
            ar.graphics.rotate(counter, 0, 1, 0);
            _model.drawFill;
        _fbo.end;
    }

    override void draw(){
        _gaussianblurShadingMaterial.shader.uniform("horizontal", true);
        _fbo.filteredBy(_gaussianblurShadingMaterial);
        _gaussianblurShadingMaterial.shader.uniform("horizontal", false);
        _fbo.filteredBy(_gaussianblurShadingMaterial)
            .draw;
    }

    private{
        float counter = 0f;
        ar.graphics.Camera _camera;
        ar.graphics.Material _gaussianblurShadingMaterial;
        ar.graphics.Model _model;
        ar.graphics.Fbo _fbo;

    }
}

void main(){
    version(unittest){
    }else{
        ar.app.run(new TestApp);
    }
}

private float[length] gaussianPDF(int length)(in float d){
    float[length] weight;
    float t = 0.0f;
    for(size_t i = 0; i < length; i++){
        float r = 1.0 + 2.0 * i;
        import std.math;
        float w = exp(-0.5 * (r * r) / d);
        weight[i] = w;
        if(i > 0){w *= 2.0;}
        t += w;
    }
    for(size_t i = 0; i < length; i++){
        weight[i] /= t;
    }
    return weight;
}
