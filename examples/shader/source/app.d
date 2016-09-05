import std.stdio, std.math;
static import ar = armos;

class TestApp : ar.app.BaseApp{
	ar.graphics.Shader shader;
	ar.graphics.Image image;
	float c = 0;
	
	override void setup(){
		shader = new ar.graphics.Shader();
		image = new ar.graphics.Image();
		image.load("lena_std.tif");
		
		shader.load("simple");
		shader.setUniformTexture("tex", image.texture, 0);
	}
	
	override void update(){
		c += 0.01;
	}
	
	override void draw(){
		shader.setUniform("color", c%1f, c%1f, c%1f, 1.0f);
		shader.begin;
			image.draw(0, 0);
		shader.end;
	}
}

void main(){ar.app.run(new TestApp);}
