module armos.graphics.shader;
import derelict.opengl3.gl;
import armos.math.vector;
import armos.math.matrix;

/++
+/
class Shader {
    public{
        this(){
            _programID = glCreateProgram();
        }

        ~this(){
            _programID = glCreateProgram();
            glDeleteProgram(_programID);
        }
        
        string log()const{
            return _log;
        }

        /++
            Load the shader from shaderName
        +/
        void load(in string shaderName){
            loadFiles(shaderName ~ ".vert", shaderName ~ ".frag");
        }

        /++
            Load the shader from path
        +/
        void loadFiles(in string vertexShaderSourcePath, in string fragmentShaderSourcePath){
            loadSources(vertexShaderSourcePath.loadedSource, fragmentShaderSourcePath.loadedSource);
        }
        
        /++
            Load the shader from sources 
        +/
        void loadSources(in string vertexShaderSource, in string fragmentShaderSource){
            import std.stdio;
            
            if(vertexShaderSource != ""){
                addLog("load vertex shader");
                loadShaderSource(vertexShaderSource, GL_VERTEX_SHADER);
            }
            
            if(fragmentShaderSource != ""){
                addLog("load fragment shader");
                loadShaderSource(fragmentShaderSource, GL_FRAGMENT_SHADER);
            }

            glLinkProgram(_programID);

            int isLinked;
            glGetProgramiv(_programID, GL_LINK_STATUS, &isLinked);
            import colorize;
            if (isLinked == GL_FALSE) {
                addLog("link error".color(fg.red));
            }else{
                _isLoaded = true;
            }
        }

        /++
            Return gl program id.
        +/
        int id()const{return _programID;}

        /++
            Begin adapted process
        +/
        void begin(){
            int savedProgramID;
            glGetIntegerv(GL_CURRENT_PROGRAM,&savedProgramID);
            _savedProgramIDs ~= savedProgramID;
            glUseProgram(_programID);
        }

        /++
            End adapted process
        +/
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
        +/
        bool isLoaded()const{
            return _isLoaded;
        }

        /++
        +/
        int uniformLocation(in string name){
            import std.string;
            immutable location = glGetUniformLocation(_programID, name.toStringz);
            assert(location != -1, "Could not find uniform \"" ~ name ~ "\"");
            return location;
        }

        /++
            Set vector to uniform.
            example:
            ----
            auto v = ar.Vector!(float, 3)(1.0, 2.0, 3.0);
        shader.setUniform("v", v);
        ----
        +/
        void setUniform(V)(in string name, V v)
            if(isVector!(V) && V.dimention <= 4){
                if(_isLoaded){
                    begin;
                    int location = uniformLocation(name);
                    if(location != -1){
                        mixin(glFunctionString!(typeof(v[0]), v.data.length)("glUniform"));
                    }
                    end;
                }
            }

        /++
            Set matrix to uniform.
            example:
            ----
            auto m = ar.Matrix!(float, 3, 3)(
                    [0, 0, 0], 
                    [0, 0, 0], 
                    [0, 0, 0], 
                    );
        shader.setUniform("m", m);
        ----
        +/
        void setUniform(M)(in string name, M m)
            if(isMatrix!(M) && M.rowSize<=4 && M.colSize<=4){
                if(_isLoaded){
                    begin;
                    int location = uniformLocation(name);
                    if(location != -1){
                        mixin( glFunctionString!(typeof(m[0][0])[], m.rowSize, m.colSize).glFunctionNameString("glUniform") ~ "(location, 1, GL_FALSE, m.array.ptr);" );
                    }
                    end;
                }
            }

        /++
            Set as an uniform.
            example:
            ----
            // Set variables to glsl uniform named "v".
            float a = 1.0;
        float b = 2.0;
        float c = 3.0;
        shader.setUniform("v", a, b, c);
        ----
        +/
        void setUniform(Args...)(in string name, Args v)if(0 < Args.length && Args.length <= 4 && __traits(isArithmetic, Args[0])){
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
        +/
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
        +/
        int attribLocation(in string name)const{
            import std.string;
            immutable location = glGetAttribLocation(_programID, name.toStringz);
            assert(location != -1, "Could not find attribute \"" ~ name ~ "\"");
            return location;
        }

        /++
            Set as an attribute.
            example:
            ----
            // Set variables to glsl attribute named "v".
            float a = 1.0;
        float b = 2.0;
        float c = 3.0;
        shader.setAttrib("v", a, b, c);
        ----
        +/
        void setAttrib(Args...)(in string name, Args v)if(Args.length > 0 && __traits(isArithmetic, Args[0])){
            if(_isLoaded){
                begin;{
                    int location = attribLocation(name);
                    if(location != -1){
                        mixin(glFunctionString!(typeof(v[0]), v.length)("glVertexAttrib"));
                    }
                }end;
            }
        }

        /++
            Set as an attribute.
            example:
            ----
            // Set a array to glsl vec2 attribute named "coord2d".
            float[] vertices = [
            0.0,  0.8,
            -0.8, -0.8,
            0.8, -0.8,
            ];
        shader.setAttrib("coord2d", vertices);
        ----
        +/
        void setAttrib(Args...)(in string name, Args v)if(Args.length > 0 && !__traits(isArithmetic, Args[0])){
            if(_isLoaded){
                begin;{
                    int location = attribLocation(name);
                    if(location != -1){
                        int dim = attribDim(name);
                        glVertexAttribPointer(location, dim, GL_FLOAT, GL_FALSE, 0, v[0].ptr);
                    }
                }end;
            }
        }

        /++
            Set current selected buffer as an attribute.
        +/
        void setAttrib(in string name){
            if(_isLoaded){
                begin;{
                    int location = attribLocation(name);
                    if(location != -1){
                        int dim = attribDim(name);
                        glVertexAttribPointer(location, dim, GL_FLOAT, GL_FALSE, 0, null);
                    }
                }end;
            }
        }

        /++
            Set vector as an attribute.
            example:
            ----
            auto v = ar.Vector!(float, 3)(1.0, 2.0, 3.0);
        shader.setAttrib("v", v);
        ----
        +/
        void setAttrib(V)(in string name, V v)if(isVector!(V) && V.dimention <= 4){
            if(_isLoaded){
                begin;{
                    int location = attribLocation(name);
                    if(location != -1){
                        mixin(glFunctionString!(typeof(v[0]), v.data.length)("glVertexAttrib"));
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
        int _programID;
        int[] _savedProgramIDs;
        bool _isLoaded = false;
        string _log;

        void addLog(in string str){
            _log ~= str ~ "\n";
        }

        void loadShaderFile(in string shaderPath, GLuint shaderType){
            auto shaderSource = loadedSource(shaderPath);
            loadShaderSource(shaderSource, shaderType);
        }
        
        void loadShaderSource(in string shaderSource, GLuint shaderType){
            int shaderID = glCreateShader(shaderType);
            scope(exit) glDeleteShader(shaderID);

            compile(shaderID, shaderSource);
            glAttachShader(_programID, shaderID);
        }

        void compile(in int id, in string source){
            const char* sourcePtr = source.ptr;
            const int sourceLength = cast(int)source.length;

            glShaderSource(id, 1, &sourcePtr, &sourceLength);
            glCompileShader(id);

            int isCompiled;
            glGetShaderiv(id, GL_COMPILE_STATUS, &isCompiled);

            import colorize;
            if (isCompiled == GL_FALSE) {
                addLog("compile error".color(fg.red));
                addLog(logShader(id));
            }else{
                addLog("compile success".color(fg.green));
            }
        }

        string logShader(in int id)const{
            int strLength;
            glGetShaderiv(id, GL_INFO_LOG_LENGTH, &strLength);
            char[] log = new char[strLength];
            glGetShaderInfoLog(id, strLength, null, log.ptr);
            import std.string;
            import std.conv;
            return log.to!string[0..$-1].strip;
        }

        int attribDim(in string name)
        out(dim){assert(dim>0);}
            body{
                int dim = 0;
                if(_isLoaded){
                    begin;{
                        int location = attribLocation(name);
                        if(location != -1){
                            int maxLength;
                            glGetProgramiv(_programID, GL_ACTIVE_ATTRIBUTE_MAX_LENGTH, &maxLength);

                            uint type = GL_ZERO;
                            char[100] nameBuf;
                            int l;
                            int s;

                            glGetActiveAttrib(
                                    _programID, location, maxLength,
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

private template glFunctionString(T, size_t DimC, size_t DimR = 1){
    import std.conv;

    public{
        static if(DimR == 1){
            string glFunctionString(in string functionString){
                return glFunctionNameString(functionString) ~ "(location, " ~ args ~ ");";
            }
        }

        string glFunctionNameString(in string functionString){
            return functionString ~ suffix;
        }
    }//public

    private{
        string suffix(){
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

            string str = "";
            if(isMatrix){str ~= "Matrix";}
            str ~= dim;
            str ~= type;
            return str;
        }

        string dim(){
            auto str = DimC.to!string;
            static if(isMatrix){
                str ~= (DimC == DimR)?"":( "x" ~ DimR.to!string );
            }
            return str;
        }

        string args(){
            string argsStr = "v[0]";
            for (int i = 1; i < DimC; i++) {
                argsStr ~= ", v[" ~ i.to!string~ "]";
            }
            return argsStr;
        }

        bool isMatrix(){
            return (DimR > 1);
        }

        // bool isVector(){
        // 	return false;
        // }
    }//private
}

private{
    string loadedSource(in string path){
        static import armos.utils;
        immutable absolutePath = armos.utils.absolutePath(path);
        import std.file;
        return readText(absolutePath);
    }
}

static unittest{
    import std.stdio;
    assert( glFunctionString!(float, 3)("glUniform") == "glUniform3f(location, v[0], v[1], v[2]);" );
    assert( glFunctionString!(float[], 3, 3).glFunctionNameString("glUniform") == "glUniformMatrix3fv" );
    assert( glFunctionString!(float[], 2, 3).glFunctionNameString("glUniform") == "glUniformMatrix2x3fv" );
    assert( glFunctionString!(float[], 3, 3).glFunctionNameString("glUniform") == "glUniformMatrix3fv" );
}
