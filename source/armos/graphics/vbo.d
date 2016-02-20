module armos.graphics.vbo;
import derelict.opengl3.gl;

/++
++/
class Vbo {
	public{
		this(){
			glGenBuffers(1, cast(uint*)&_id);
		}
		
	}//public

	private{
		int _id;
	}//private
}//class Vbo
