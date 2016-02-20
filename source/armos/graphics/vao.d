module armos.graphics.vao;
import armos.graphics.vbo;
import derelict.opengl3.gl;

/++
++/
class Vao {
	public{
		this(){
			glGenVertexArrays(1, cast(uint*)&_id);
		}
		
		void begin(){
			int savedID;
			glGetIntegerv(GL_VERTEX_ARRAY_BINDING,&savedID);
			_savedIDs ~= savedID;
			
			glBindVertexArray(_id);
		}
		
		void end(){
			import std.range;
			glBindVertexArray(_savedIDs[$-1]);
			if (_savedIDs.length == 0) {
				assert(0, "stack is empty");
			}else{
				_savedIDs.popBack;
			}
		}
		
		void set(Vbo vbo){
			begin;
			end;
		}
	}//public

	private{
		int _id;
		int[] _savedIDs;
	}//private
}//class Vao
