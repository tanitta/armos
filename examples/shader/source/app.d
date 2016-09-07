import std.stdio, std.math;
static import ar = armos;

class TestApp : ar.app.BaseApp{
	ar.graphics.Shader _shader;
    ar.graphics.Mesh _rect;
	float c = 0;
	
	override void setup(){
		_shader = new ar.graphics.Shader().load("simple");
        ar.graphics.currentMaterial.texture("tex", (new ar.graphics.Image).load("lena_std.tif").texture);
        ar.graphics.currentMaterial.shader = _shader;
        
        _rect = new ar.graphics.Mesh;

        _rect.vertices = [
            ar.math.Vector4f(0.0, 0.0,  0.0, 1.0f),
            ar.math.Vector4f(0.0, 512,  0.0, 1.0f),
            ar.math.Vector4f(512,  512,  0.0, 1.0f),
            ar.math.Vector4f(512,  0.0,  0.0, 1.0f),
        ];
        
        _rect.texCoords0= [
            ar.math.Vector4f(0f, 0f,  0.0, 1.0f),
            ar.math.Vector4f(0, 1f,  0.0, 1.0f),
            ar.math.Vector4f(1,  1,  0.0, 1.0f),
            ar.math.Vector4f(1.0,  0,  0.0, 1.0f),
        ];
        
        _rect.indices = [
            0, 1, 2,
            2, 3, 0,
        ];
	}
	
	override void update(){
		c += 0.01;
		_shader.uniform("color", c%1f, c%1f, c%1f, 1.0f);
	}
	
	override void draw(){
        // image.draw(0, 0);
        _rect.drawFill;
	}
}

void main(){ar.app.run(new TestApp);}
