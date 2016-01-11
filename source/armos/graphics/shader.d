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
			int savedProgramID;
			glGetIntegerv(GL_CURRENT_PROGRAM,&savedProgramID);
			_savedProgramIDs ~= savedProgramID;
			glUseProgram(_programID);
		}
		
		/++
			End adapted process
		++/
		void end(){
			import std.range;
			glUseProgram(_savedProgramIDs[$-1]);
			if (_savedProgramIDs.length == 0) {
				assert(0, "stack is empty");
			}else{
				_savedProgramIDs.popBack;
			}
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
		void setUniform(Args...)(in string name, Args v){
			if(_isLoaded){
				begin;
				int location = uniformLocation(name);
				if(location != -1){
					mixin(glFunctionString!(typeof(v[0]), v.length)("glUniform"));
				}
				end;
			}
		}
		
		/++
		++/
		void setUniformTexture(in string name, armos.graphics.Texture texture, int textureLocation){
			import std.string;
			if(_isLoaded){
				begin;scope(exit)end;
				texture.begin;scope(exit)texture.end;
				glActiveTexture(GL_TEXTURE0 + textureLocation);
				glUniform1i(glGetUniformLocation(_programID, name.toStringz), textureLocation);
				// setUniform(name, textureLocation);
				glActiveTexture(GL_TEXTURE0);
			}
		}
	}//public

	private{
		int _vertexID;
		int _fragmentID;
		int _programID;
		int[] _savedProgramIDs;
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
	}else if(is(T == int)){
		type = "i";
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

