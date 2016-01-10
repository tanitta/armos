module armos.graphics.shader;
import derelict.opengl3.gl;
import armos.math.vector;

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
			}else{
				_isLoaded = true;
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
		
		/++
		++/
		bool isLoaded(){
			return _isLoaded;
		}
		
		/++
		++/
		int uniformLocation(in string name){
			import std.string;
			return glGetUniformLocation(_programID, name.toStringz);
		}
		
		/++
		++/
		// void setUniform(T, int N)(string name, armos.math.Vector!(T,N) v){
		// 	if(_isLoaded){
		// 		int location = uniformLocation(name);
		// 		if(location != -1){
		// 			mixin(glFunctionString!(N, T)("glUniform"));
		// 		}
		// 	}
		//
		// }
		// unittest{
		// 	auto shader = new Shader;
		// 	auto vector = armos.math.Vector!(float, 3)(0, 0, 0);
		// 	shader.setUniform("hoge", vector);
		// }
		
		/++
		++/
		void setUniform(Args...)(string name, Args v){
			if(_isLoaded){
				begin;
				int location = uniformLocation(name);
				if(location != -1){
					mixin(glFunctionString!(typeof(v[0]), v.length)("glUniform"));
				}
				end;
			}
		}
	}//public

	private{
		int _vertexID;
		int _fragmentID;
		int _programID;
		int _savedProgramID;
		bool _isLoaded = false;
		
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

string glFunctionString(T, size_t Dim)(string functionString){
	import std.conv;
	string type;
	static if(is(T == float)){
		type = "f";
	}else if(is(T == double)){
		type = "d";
	}

	string args = "v[0]";
	for (int i = 1; i < Dim; i++) {
		args ~= ", v[" ~ i.to!string~ "]";
	}
	return functionString ~ Dim.to!string~ type ~ "(location, " ~ args ~ ");";
}
static unittest{
	import std.stdio;
	assert( glFunctionString!(float, 3)("glUniform") == "glUniform3f(location, v[0], v[1], v[2]);" );
}

