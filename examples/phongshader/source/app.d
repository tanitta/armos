static import ar = armos;
import std.stdio;

private immutable string phongVertexShaderSource = q{
#version 330

uniform mat4 modelViewMatrix;
uniform mat4 modelViewProjectionMatrix;

in vec4 vertex;
in vec3 normal;

out vec4 f_position;
out vec3 f_normal;

void main(void) {
    gl_Position = modelViewProjectionMatrix * vertex;
    f_position = gl_Position;
    f_normal = (modelViewMatrix * vec4(normal.x, normal.y, normal.z, 0)).xyz;
}
};

private immutable phongFragmentShaderSource = q{
#version 330
    
in vec4 f_position;
in vec3 f_normal;

out vec4 fragColor;

uniform vec3 lightDirection;

void main(void) {
    float diffuse = max(dot(lightDirection, f_normal), 0.0);
    vec3 view = -normalize(f_position.xyz);
    vec3 halfway = normalize(lightDirection + view);
    float shininess = 0.5;
    float specular = pow(max(dot(f_normal, halfway), 0.0), shininess);
    fragColor = vec4(f_normal.x*specular, f_normal.y*specular, f_normal.z*specular, 1);
}
};

class TestApp : ar.app.BaseApp{
    override void setup(){
        ar.graphics.enableDepthTest;
        _camera = (new ar.graphics.DefaultCamera).position(ar.math.Vector3f(0, 0.1, -0.25))
                                                 .target(ar.math.Vector3f(0, 0, 0));
        
        auto shader = (new ar.graphics.Shader).loadSources(
            phongVertexShaderSource, 
            "",
            phongFragmentShaderSource
        );
        
        shader.log.writeln;
        
        _gourandShadingMaterial = (new ar.graphics.DefaultMaterial).shader(shader);
        _gourandShadingMaterial.uniform("lightDirection", ar.math.Vector3f(0.5, 0.5, 0.5).normalized);
        
        _model = (new ar.graphics.Model).load("data/bunny.fbx");
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
        _gourandShadingMaterial.uniform("lightDirection", ar.math.Vector3f(u, v, 0.1).normalized);
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
