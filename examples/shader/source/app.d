import armos, std.stdio, std.math;

class TestApp : ar.BaseApp{
	auto shader = new ar.Shader;
	ar.Image image;
	float c = 0;
	
	void setup(){
		image = new ar.Image();
		image.load("lena_std.tif");
		
		shader.load("simple");
		shader.setUniformTexture("tex", image.texture, 0);
	}
	
	void update(){
		c += 0.01;
	}
	
	void draw(){
		shader.setUniform("color", c%1f, c%1f, c%1f, 1.0f);
		shader.begin;
			image.draw(0, 0);
		shader.end;
	}
}

void main(){ar.run(new TestApp);}
