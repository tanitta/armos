import std.stdio, std.math, std.conv;

static import ar = armos;

class TestApp : ar.app.BaseApp{
	ar.graphics.Camera camera = new ar.graphics.DefaultCamera();
	ar.utils.Gui gui;
	ar.graphics.Mesh mesh;
	float _fpsUseRate = 0.0;
	float f = 128;
	int i = 128;
	float c = 0;
	float cX = 0;
	float cY = 0;
	bool isFill = false;
	
		
	override void setup(){
		ar.graphics.blendMode(ar.graphics.BlendMode.Alpha);
		camera.position = ar.math.Vector3f(0, 0, -100);
		camera.target= ar.math.Vector3f(0, 0, 0);
		gui = (new ar.utils.Gui)
		.add(
			(new ar.utils.List)
			.add(new ar.utils.Partition(" "))
			.add(new ar.utils.Label("armos-gui-example"))
			.add(new ar.utils.Partition)
		)
		.add(
			(new ar.utils.List)
			.add(new ar.utils.Partition(" "))
			.add(new ar.utils.Label("list2"))
			.add(new ar.utils.Partition)
			.add(new ar.utils.MovingGraph!float("fpsUseRate", _fpsUseRate, 0.0, 100.0))
			.add(new ar.utils.Partition)
			.add(new ar.utils.Slider!int("slider!int", i, 0, 255))
			.add(new ar.utils.Slider!float("slider!float", f, 0, 255))
			.add(new ar.utils.Partition)
			.add(new ar.utils.MovingGraph!float("x", cX, -2, 2))
			.add(new ar.utils.MovingGraphXY!float("x", cX, -2, 2, "y", cY, -2, 2))
			.add(new ar.utils.ToggleButton("isFill", isFill))
			.add(new ar.utils.ToggleButton("isFill", isFill))
			.add(new ar.utils.Partition)
		);
		
		mesh = ar.graphics.boxPrimitive(ar.math.Vector3f(0, 0, 0), ar.math.Vector3f( 100, 10, 10 ));
	}
	
	override void update(){
		_fpsUseRate = ar.app.fpsUseRate*100.0;
		c += 0.2;
		cX = cos(c*f/128f);
		cY = sin(c);
	}
	
	override void draw(){
		camera.begin;
		ar.graphics.pushMatrix;
		ar.graphics.rotate(f, 1, 1, 1);
			ar.graphics.color(i, 255-i, i*0.5);
			if(isFill){
				mesh.drawFill;
			}else{
				mesh.drawWireFrame;
			}
		ar.graphics.popMatrix;
		camera.end;
		gui.draw;
	}
}

void main(){ar.app.run(new TestApp);}
