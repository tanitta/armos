module armos.graphics.shader;
import derelict.opengl3.gl;
import armos.math.vector;

/++
++/
class Shader {
	public{
		this(){
			_programID = glCreateProgram();
		}
		
		~this(){
			_programID = glCreateProgram();
			glDeleteProgram(_programID);
		}
		
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
			import std.stdio;
			if(vertexShaderSourcePath != ""){
				"load vertex shader".writeln;
				loadShader(_vertexID, vertexShaderSourcePath, GL_VERTEX_SHADER);
			}
			"\n".writeln;
			if(fragmentShaderSourcePath != ""){
				"load fragment shader".writeln;
				loadShader(_fragmentID, fragmentShaderSourcePath, GL_FRAGMENT_SHADER);
			}
			
			glLinkProgram(_programID);
			
			int isLinked;
			glGetProgramiv(_programID, GL_LINK_STATUS, &isLinked);
			if (isLinked == GL_FALSE) {
				"link error".writeln;
			}else{
				_isLoaded = true;
			}
		}
		
		/++
			Return gl program id.
		++/
		int id(){return _programID;}
		
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
			auto location = glGetUniformLocation(_programID, name.toStringz);
			assert(location != -1, "Could not find uniform \"" ~ name ~ "\"");
			return location;
		}
		
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
				setUniform(name, textureLocation);
				glActiveTexture(GL_TEXTURE0);
			}
		}
		
		/++
		++/
		int attribLocation(in string name){
			import std.string;
			auto location = glGetAttribLocation(_programID, name.toStringz);
			assert(location != -1, "Could not find attribute \"" ~ name ~ "\"");
			return location;
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
		
		void loadShader(ref int shaderID, string shaderPath, GLuint shaderType){
				shaderID = glCreateShader(shaderType);
				scope(exit) glDeleteShader(shaderID);

				auto shaderSource = loadedSource(shaderPath);
				

				compile(shaderID, shaderSource);

				glAttachShader(_programID, shaderID);
				// scope(exit) glDetachShader(_programID, shaderID);
		}
		
		void compile(int id, string source){
			const char* sourcePtr = source.ptr;
			const int sourceLength = cast(int)source.length;
			
			glShaderSource(id, 1, &sourcePtr, &sourceLength);
			glCompileShader(id);
			
			int isCompiled;
			glGetShaderiv(id, GL_COMPILE_STATUS, &isCompiled);
			
			import std.stdio;
			if (isCompiled == GL_FALSE) {
				"compile error".writeln;
				logShader(id).writeln;
			}else{
				"compile success".writeln;
			}
		}
		
		string logShader(int id){
			int strLength;
			glGetShaderiv(id, GL_INFO_LOG_LENGTH, &strLength);
			char[] log = new char[strLength];
			glGetShaderInfoLog(id, strLength, null, log.ptr);
			return cast(string)log;
		}
		
	}//private
}//class Shader

private string glFunctionString(T, size_t Dim)(string functionString){
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

