module armos.graphics.shader;
import derelict.opengl3.gl;

/++
++/
class Shader {
	public{
		/++
			Load the shader from shaderName
		++/
		void load(string shaderName){
			load(shaderName ~ ".vert", shaderName ~ ".frag");
		}
		
		/++
			Load the shader from path
		++/
		void load(string vertexShaderSourcePath, string fragmentShaderSourcePath){
			_programID = glCreateProgram();
			
			if(vertexShaderSourcePath != ""){
				load(_vertexID, vertexShaderSourcePath, GL_VERTEX_SHADER);
			}
			
			if(fragmentShaderSourcePath != ""){
				load(_fragmentID, fragmentShaderSourcePath, GL_FRAGMENT_SHADER);
			}
			
			glLinkProgram(_programID);
			
			int isLinked;
			glGetProgramiv(_programID, GL_LINK_STATUS, &isLinked);
			if (isLinked == GL_FALSE) {
				import std.stdio;
				"link error".writeln;
			}
		}
		
		/++
			Begin adapted process
		++/
		void begin(){
			glGetIntegerv(GL_CURRENT_PROGRAM,&_savedProgramID);
			glUseProgram(_programID);
		}
		
		/++
			End adapted process
		++/
		void end(){
			glUseProgram(_savedProgramID);
		}
	}//public

	private{
		int _vertexID;
		int _fragmentID;
		int _programID;
		int _savedProgramID;
		
		string loadedSource(string path){
			auto absolutePath = armos.utils.absolutePath(path);
			import std.file;
			return readText(absolutePath);
		}
		
		void load(ref int shaderID, string shaderPath, GLuint shaderType){
				shaderID = glCreateShader(shaderType);
				scope(exit) glDeleteShader(shaderID);

				auto shaderSource = loadedSource(shaderPath);
				

				compile(shaderID, shaderSource);

				glAttachShader(_programID, shaderID);
				// scope(exit) glDetachShader(_programID, shaderID);
				import std.stdio;
				shaderID.writeln;
		}
		
		void compile(int id, string source){
			const char* sourcePtr = source.ptr;
			glShaderSource(id, 1, &sourcePtr, null);
			glCompileShader(id);
			
			int isCompiled;
			glGetShaderiv(id, GL_COMPILE_STATUS, &isCompiled);
			if (isCompiled == GL_FALSE) {
				import std.stdio;
				"compile error".writeln;
			}
		}
	}//private
}//class Shader
