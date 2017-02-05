static import ar = armos;
import std.stdio;

private immutable string gourandVertexShaderSource = q{
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
    vec3 n = (modelViewMatrix * vec4(normal.x, normal.y, normal.z, 0)).xyz;
    float diffuse = max(dot(lightDirection, n), 0.0);
    vec3 view = -normalize(gl_Position.xyz);
    vec3 halfway = normalize(lightDirection + view);
    float shininess = 0.5;
    float specular = pow(max(dot(n, halfway), 0.0), shininess);
    f_color = vec4(normal.x*specular, normal.y*specular, normal.z*specular, 1);
}
};

private immutable gourandFragmentShaderSource = q{
#version 330
    
in vec4 f_color;
in vec2 outtexCoord0;
in vec2 outtexCoord1;

out vec4 fragColor;

uniform sampler2D tex0;
uniform sampler2D tex1;

void main(void) {
    fragColor = f_color;
}
};

class TestApp : ar.app.BaseApp{
    override void setup(){
        ar.graphics.enableDepthTest;
        _camera = (new ar.graphics.DefaultCamera).position(ar.math.Vector3f(0, 0.1, -0.25))
                                                 .target(ar.math.Vector3f(0, 0, 0));
        
        auto shader = (new ar.graphics.Shader).loadSources(
            gourandVertexShaderSource, 
            "",
            gourandFragmentShaderSource
        );
        
        shader.log.writeln;
        
        _gourandShadingMaterial = (new ar.graphics.DefaultMaterial).shader(shader);
        _gourandShadingMaterial.attr("lightDirection", ar.math.Vector3f(0.5, 0.5, 0.5).normalized);
        
        _model = (new ar.graphics.Model).load("bunny.fbx");
        import std.algorithm:each;
        _model.entities.each!(e => e.mesh.calcNormal);
        _model.entities.each!(e => e.material = _gourandShadingMaterial);
    }

    override void update(){
        counter += 0.01;
    }

    override void draw(){
        _camera.begin;scope(exit)_camera.end;
        ar.graphics.pushMatrix;scope(exit)ar.graphics.popMatrix;
        ar.graphics.rotate(counter, 0, 1, 0);
        _model.drawFill;
    }

    override void mouseMoved(int x, int y, int button){
        import std.conv:to;
        float u = x.to!float/ar.app.windowSize.x.to!float - 0.5f;
        float v = y.to!float/ar.app.windowSize.y.to!float - 0.5f;
        _gourandShadingMaterial.attr("lightDirection", ar.math.Vector3f(u, v, 0.1).normalized);
    }
    
    private{
        float counter = 0f;
        ar.graphics.Camera _camera;
        ar.graphics.Material _gourandShadingMaterial;
        ar.graphics.Model _model;
    }
}

void main(){
    version(unittest){
    }else{
        ar.app.run(new TestApp);
    }
}
