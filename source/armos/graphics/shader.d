module armos.graphics.shader;
import derelict.opengl3.gl;

/++
++/
class Shader {
	public{
		/++
			Load shader from path
		++/
		void load(string vertexShaderSourcePath, string fragmentShaderSourcePath){
			_vertexID = glCreateShader(GL_VERTEX_SHADER);
			_fragmentID = glCreateShader(GL_FRAGMENT_SHADER);
			
			// import std.string;
			// auto fileName = armos.utils.toDataPath(localPathInDataDir);
			//
			// import std.file;
			// string vertexShaderSource = readText(vertexShaderSourcePath);
		}
		
		/++
			Begin adapted process
		++/
		void begin(){}
		
		/++
			End adapted process
		++/
		void end(){}
	}//public

	private{
		int _vertexID;
		int _fragmentID;
		
		void compile(int id, string source){
			const char* sourcePtr = source.ptr;
			glShaderSource(id, 1, &sourcePtr, null);
			glCompileShader(id);
		}
	}//private
}//class Shader
