static import ar = armos;
import std.stdio;

private immutable offRegistrationFilterShaderSource = q{
#version 330
    
in vec4 f_color;
in vec2 outtexCoord0;
in vec2 outtexCoord1;

out vec4 fragColor;

uniform sampler2D colorTexture;
uniform sampler2D depthTexture;

void main(void) {
    float l = 0.01;
    float r = texture(colorTexture, outtexCoord0+vec2(l, 0)).r;
    float g = texture(colorTexture, outtexCoord0+vec2(0, 0)).g;
    float b = texture(colorTexture, outtexCoord0+vec2(-l, 0)).b;
    fragColor = vec4(r, g, b, 1.0);
}
};

class TestApp : ar.app.BaseApp{
    override void setup(){
        _camera = (new ar.graphics.DefaultCamera).position(ar.math.Vector3f(0, 0, -0.5))
                                                 .target(ar.math.Vector3f(0, 0, 0));
        
        _fbo = new ar.graphics.Fbo;
        
        _simpleMaterial = new ar.graphics.AutoReloadMaterial("simple");
        
        _model = (new ar.graphics.Model).load("bunny.fbx");
    }

    override void update(){
        _fbo.resize(ar.app.currentWindow.size);
        
        counter += 0.01;
        import std.math:sin, cos;
        _camera.position = ar.math.Vector3f(-0.5*sin(counter), 0.1, -0.5*cos(counter));
        
        _fbo.begin;scope(exit)_fbo.end;
        ar.graphics.fillBackground(ar.types.Color(32, 32, 32));
        _camera.begin;scope(exit)_camera.end;
        _model.drawFill;
    }

    override void draw(){
        _fbo.filteredBy(_simpleMaterial)
            .draw;
    }
    
    private{
        float counter = 0f;
        ar.graphics.Camera _camera;
        ar.graphics.Fbo _fbo;
        ar.graphics.Material _simpleMaterial;
        ar.graphics.Model _model;
    }
}

void main(){
    version(unittest){
    }else{
        ar.app.run(new TestApp);
    }
}
