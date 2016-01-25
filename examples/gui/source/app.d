import armos, std.stdio, std.math;

class TestApp : ar.BaseApp{
	ar.Camera camera = new ar.Camera();
	ar.Gui gui;
	ar.Mesh mesh;
	float f=128;
	int i=128;
	
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
			.add(new ar.Slider!int("slider!int", i, 0, 255))
			.add(new ar.Slider!float("slider!float", f, 0, 255))
			.add(new ar.Partition)
		);
		
		mesh = ar.boxPrimitive(ar.Vector3f(0, 0, 0), ar.Vector3f( 100, 10, 10 ));
	}
	
	void update(){
	}
	
	
	void draw(){
		camera.begin;
		ar.pushMatrix;
		ar.rotate(f, 1, 1, 1);
			ar.setColor(i, 255-i, i*0.5);
			mesh.drawWireFrame;
		ar.popMatrix;
		camera.end;
		gui.draw;
	}
}

void main(){ar.run(new TestApp);}
