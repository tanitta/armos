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
		
		/++
		++/
		void setAttrib(Args...)(in string name, Args v){
			if(_isLoaded){
				begin;{
					int location = attribLocation(name);
					if(location != -1){
						static if(Args.length == 0){
							int dim = 2;
							glVertexAttribPointer(location, dim, GL_FLOAT, GL_FALSE, 0, null);
						}else{
							static if(__traits(isArithmetic, Args[0])){
								mixin(glFunctionString!(typeof(v[0]), v.length)("glVertexAttrib"));
							}else{
								int dim = 2;
								glVertexAttribPointer(location, dim, GL_FLOAT, GL_FALSE, 0, v[0].ptr);
							}
						}
					}
				}end;
			}
		}
		
		
		/++
		+/
		void enableAttrib(in string name){
			glEnableVertexAttribArray(attribLocation(name));
		}
		
		/++
		+/
		void disableAttrib(in string name){
			glDisableVertexAttribArray(attribLocation(name));
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
		
		int attribDim(in string name)
		out(dim){assert(dim>0);}
		body{
			int dim = 0;
			if(_isLoaded){
				begin;{
					import std.stdio;
					int location = attribLocation(name);
					if(location != -1){
						int maxLength;
						glGetProgramiv(_programID, GL_ACTIVE_ATTRIBUTE_MAX_LENGTH, &maxLength);
						
						uint type = GL_ZERO;
						char[100] nameBuf;
						int l;
						int s;
						
						glGetActiveAttrib(
							_programID, 1, maxLength,
							&l, &s, &type, nameBuf.ptr 
						);
						
						switch (type) {
							case GL_FLOAT:
								dim = 1;
								 break;
							case GL_FLOAT_VEC2:
								dim = 2;
								 break;
							case GL_FLOAT_VEC3:
								dim = 3;
								 break;
							default:
								dim = 0;
						}
					}
				}end;
			}
			return dim;
		}
	}//private
}//class Shader

private template glFunctionString(T, size_t Dim){
	import std.conv;
	
	string glFunctionString(string functionString){
		return glFunctionNameString(functionString) ~ "(location, " ~ args ~ ");";
	}
	
	string glFunctionNameString(string functionString){
		return functionString ~ Dim.to!string ~ suffix;
	}
	
	private string suffix(){
		string type;
		static if(is(T == float)){
			type = "f";
		}else if(is(T == double)){
			type = "d";
		}else if(is(T == int)){
			type = "i";
		}
		
		static if(is(T == float[])){
			type = "fv";
		}else if(is(T == double[])){
			type = "bv";
		}else if(is(T == int[])){
			type = "iv";
		}
		return type;
	}
	
	private string args(){
		string argsStr = "v[0]";
		for (int i = 1; i < Dim; i++) {
			argsStr ~= ", v[" ~ i.to!string~ "]";
		}
		return argsStr;
	}
	
}
static unittest{
	import std.stdio;
	assert( glFunctionString!(float, 3)("glUniform") == "glUniform3f(location, v[0], v[1], v[2]);" );
}

