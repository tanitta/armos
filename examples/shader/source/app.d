import std.stdio, std.math;
static import ar = armos;

class TestApp : ar.app.BaseApp{
    ar.graphics.Shader _shader;
    ar.graphics.Mesh _rect;
    float c = 0;

    override void setup(){
        _shader = (new ar.graphics.Shader).load("data/simple");
        _shader.log.writeln;
        
        ar.graphics.currentMaterial.texture("tex", (new ar.graphics.Image).load("data/lena_std.tif").texture);
        ar.graphics.currentMaterial.shader = _shader;
        
        _rect = new ar.graphics.Mesh;

        _rect.vertices = [
            ar.math.Vector4f(0f,   0f,   0f, 1f),
            ar.math.Vector4f(0f,   512f, 0f, 1f),
            ar.math.Vector4f(512f, 512f, 0f, 1f),
            ar.math.Vector4f(512f, 0f,   0f, 1f),
        ];
        
        _rect.texCoords0= [
            ar.math.Vector4f(0f, 0f,  0f, 1f),
            ar.math.Vector4f(0f, 1f,  0f, 1f),
            ar.math.Vector4f(1f, 1f,  0f, 1f),
            ar.math.Vector4f(1f, 0f,  0f, 1f),
        ];
        
        _rect.indices = [
            0, 1, 2,
            2, 3, 0,
        ];
    }

    override void update(){
        c += 0.2;
        _shader.uniform("time", c);
    }
    
    override void mouseMoved(ar.math.Vector2i p, int button){
        import std.conv:to;
        _shader.uniform("shift", p.to!(ar.math.Vector2f));
    }

    override void draw(){
        _rect.drawFill;
    }
}

void main(){
    version(unittest){
    }else{
        ar.app.run(new TestApp);
    }
}
