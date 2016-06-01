import armos, std.stdio, std.math, std.conv;

class TestApp : ar.BaseApp{
	ar.Camera camera = new ar.Camera();
	ar.Gui gui;
	ar.Mesh mesh;
	float _fpsUseRate = 0.0;
	float f = 128;
	int i = 128;
	float c = 0;
	float cX = 0;
	float cY = 0;
	bool isFill = false;
	
	void setup(){
		ar.blendMode(ar.BlendMode.Alpha);
		camera.position = ar.Vector3f(0, 0, -100);
		camera.target= ar.Vector3f(0, 0, 0);
		
		gui = (new ar.Gui)
		.add(
			(new ar.List)
			.add(new ar.Partition(" "))
			.add(new ar.Label("armos-gui-example"))
			.add(new ar.Partition)
		)
		.add(
			(new ar.List)
			.add(new ar.Partition(" "))
			.add(new ar.Label("list2"))
			.add(new ar.Partition)
			.add(new ar.MovingGraph!float("fpsUseRate", _fpsUseRate, 0.0, 100.0))
			.add(new ar.Partition)
			.add(new ar.Slider!int("slider!int", i, 0, 255))
			.add(new ar.Slider!float("slider!float", f, 0, 255))
			.add(new ar.Partition)
			.add(new ar.MovingGraph!float("x", cX, -2, 2))
			.add(new ar.MovingGraphXY!float("x", cX, -2, 2, "y", cY, -2, 2))
			.add(new ar.ToggleButton("isFill", isFill))
			.add(new ar.ToggleButton("isFill", isFill))
			.add(new ar.Partition)
		);
		
		mesh = ar.boxPrimitive(ar.Vector3f(0, 0, 0), ar.Vector3f( 100, 10, 10 ));
	}
	
	void update(){
		_fpsUseRate = ar.fpsUseRate*100.0;
		c += 0.2;
		cX = cos(c*f/128f);
		cY = sin(c);
	}
	
	void draw(){
		camera.begin;
		ar.pushMatrix;
		ar.rotate(f, 1, 1, 1);
			ar.setColor(i, 255-i, i*0.5);
			if(isFill){
				mesh.drawFill;
			}else{
				mesh.drawWireFrame;
			}
		ar.popMatrix;
		camera.end;
		gui.draw;
	}
}

void main(){ar.run(new TestApp);}
