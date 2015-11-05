import std.stdio;
import armos.app;

class TestApp : armos.app.BaseApp{
	void setup(){
		writeln("setup");
	}
	
	void update(){
		writeln("update");
	}
	
	void draw(){
		writeln("draw");
	};
}

void main(){
	armos.app.run(new TestApp());
}
