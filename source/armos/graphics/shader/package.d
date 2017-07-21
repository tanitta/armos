module armos.graphics.shader;

import derelict.opengl3.gl;
import armos.math.vector;
import armos.math.matrix;
import armos.graphics;
import armos.graphics.shader.source;

/++
+/
class Shader {
    public{
        this(){
            maximizeMaxGeometryOutputVertices;
            _programID = glCreateProgram();
        }

        ~this(){
            glDeleteProgram(_programID);
        }
        
        string log()const{
            return _log;
        }

        /++
            Load the shader from shaderName
        +/
        Shader load(in string shaderName, in string[] paths = []){
            import armos.utils.file;
            string absVertPath = (shaderName ~ ".vert").absolutePath;
            string absGeomPath = (shaderName ~ ".geom").absolutePath;
            string absFragPath = (shaderName ~ ".frag").absolutePath;
            import std.file;
            if(!absVertPath.exists) absVertPath = "";
            if(!absGeomPath.exists) absGeomPath = "";
            if(!absFragPath.exists) absFragPath = "";
            loadFiles(absVertPath,
                      absGeomPath,
                      absFragPath,
                      paths);
            return this;
        }

        /++
            Load the shader from path
        +/
        Shader loadFiles(in string vertexShaderSourcePath, in string geometryShaderSourcePath, in string fragmentShaderSourcePath, in string[] paths = []){
            loadSources((vertexShaderSourcePath   != "")?(Source.load(vertexShaderSourcePath)):   null,
                        (geometryShaderSourcePath != "")?(Source.load(geometryShaderSourcePath)): null,
                        (fragmentShaderSourcePath != "")?(Source.load(fragmentShaderSourcePath)): null,
                        paths);
            return this;
        }
        
        ///
        Shader loadSources(in string vertexShaderSourceText, in string geometryShaderSourceText, in string fragmentShaderSourceText, in string[] paths = []){
            Source vertexShaderSource;
            Source geometryShaderSource;
            Source fragmentShaderSource;

            if(vertexShaderSourceText != ""){
                vertexShaderSource = new Source(vertexShaderSourceText, "root.vert", "");
            }
            if(geometryShaderSourceText != ""){
                geometryShaderSource = new Source(geometryShaderSourceText, "root.geom", "");
            }
            if(fragmentShaderSourceText != ""){
                fragmentShaderSource = new Source(fragmentShaderSourceText, "root.vert", "");
            }

            loadSources(vertexShaderSource, geometryShaderSource, fragmentShaderSource, paths);

            return this;
        }

        /++
            Load the shader from sources 
        +/
        Shader loadSources(Source vertexShaderSource, Source geometryShaderSource, Source fragmentShaderSource, in string[] paths = []){
            if(vertexShaderSource){
                addLog("load vertex shader");
                vertexShaderSource.expand(paths);
                loadShaderSource(vertexShaderSource.expanded, GL_VERTEX_SHADER);
            }
            
            if(geometryShaderSource){
                addLog("load geometry shader");
                geometryShaderSource.expand(paths);
                loadShaderSource(geometryShaderSource.expanded, GL_GEOMETRY_SHADER);
                glProgramParameteri(_programID, GL_GEOMETRY_INPUT_TYPE, _geometryInput.primitiveMode.getGLPrimitiveMode);
                glProgramParameteri(_programID, GL_GEOMETRY_OUTPUT_TYPE, _geometryInput.primitiveMode.getGLPrimitiveMode);
                import std.conv:to;
                glProgramParameteri(_programID, GL_GEOMETRY_VERTICES_OUT, _maxGeometryOutputVertices.to!int);
            }
            
            if(fragmentShaderSource){
                addLog("load fragment shader");
                fragmentShaderSource.expand(paths);
                loadShaderSource(fragmentShaderSource.expanded, GL_FRAGMENT_SHADER);
            }

            glLinkProgram(_programID);

            int isLinked;
            glGetProgramiv(_programID, GL_LINK_STATUS, &isLinked);
            import colorize;
            if (isLinked == GL_FALSE) {
                addLog("link error".color(fg.red));
                addLog(logProgram(_programID));
                _isLoaded = false;
            }else{
                _isLoaded = true;
            }
            return this;
        }

        /++
            Return gl program id.
        +/
        int id()const{return _programID;}

        /++
            Begin adapted process
        +/
        Shader begin(){
            int savedID;
            glGetIntegerv(GL_CURRENT_PROGRAM, &savedID);
            _savedIDs ~= savedID;
            glUseProgram(_programID);
            return this;
        }

        /++
            End adapted process
        +/
        Shader end(){
            // TODO
            glUseProgram(_savedIDs[$-1]);
            if (_savedIDs.length == 0) {
                assert(0, "stack is empty");
            }else{
                import std.range;
                _savedIDs.popBack;
            }
            return this;
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
            // assert(location != -1, "Could not find uniform \"" ~ name ~ "\"");
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
        Shader uniform(V)(in string name, V v)
        if(isVector!(V) && V.dimention <= 4){
            if(_isLoaded){
                begin;
                int location = uniformLocation(name);
                if(location != -1){
                    mixin(glFunctionString!(typeof(v[0]), V.dimention).normal("glUniform"));
                }
                end;
            }
            return this;
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
        Shader uniform(M)(in string name, M m)
        if(isMatrix!(M) && M.rowSize<=4 && M.colSize<=4){
            if(_isLoaded){
                begin;
                int location = uniformLocation(name);
                if(location != -1){
                    mixin( glFunctionString!(typeof(m[0][0])[], m.rowSize, m.colSize).name("glUniform") ~ "(location, 1, GL_FALSE, m.array.ptr);" );
                }
                end;
            }
            return this;
        }

        /++
            Set bool as int to uniform.
            example:
            ----
            // Set variables to glsl uniform named "v".
            bool a = 1.0;
            bool b = 2.0;
            bool c = 3.0;
            shader.setUniform("v", a, b, c);
            ----
        +/
        Shader uniform(Args...)(in string name, Args v)if(0 < Args.length && Args.length <= 4 && is(Args[0]==bool)){
            if(_isLoaded){
                begin;
                int location = uniformLocation(name);
                if(location != -1){
                    mixin(glFunctionString!(int, v.length).normal("glUniform"));
                }
                end;
            }
            return this;
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
        Shader uniform(Args...)(in string name, Args v)if(0 < Args.length && Args.length <= 4 && __traits(isArithmetic, Args[0]) && !is(Args[0]==bool)){
            if(_isLoaded){
                begin;
                int location = uniformLocation(name);
                if(location != -1){
                    mixin(glFunctionString!(typeof(v[0]), v.length).normal("glUniform"));
                }
                end;
            }
            return this;
        }

        ///
        Shader uniformArray(T)(in string name, T[] v)if(is(T==bool)){
            if(_isLoaded){
                begin;
                int location = uniformLocation(name);
                if(location != -1){
                    import std.conv:to;
                    mixin(glFunctionString!(int[]).array("glUniform"));
                }
                end;
            }
            return this;
        }

        ///
        Shader uniformArray(T)(in string name, T[] v)if(__traits(isArithmetic, T) && !is(T==bool)){
            if(_isLoaded){
                begin;
                int location = uniformLocation(name);
                if(location != -1){
                    import std.conv:to;
                    mixin(glFunctionString!(T[]).array("glUniform"));
                }
                end;
            }
            return this;
        }

        /++
        +/
        Shader uniformTexture(in string name, Texture texture, int textureLocation){
            import std.string;
            if(_isLoaded){
                begin;scope(exit)end;
                glActiveTexture(GL_TEXTURE0 + textureLocation);
                texture.begin;
                uniform(name, textureLocation);
            }
            return this;
        }

        /++
        +/
        int attrLocation(in string name)const{
            import std.string;
            immutable location = glGetAttribLocation(_programID, name.toStringz);
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
        Shader attr(Args...)(in string name, Args v)if(Args.length > 0 && __traits(isArithmetic, Args[0])){
            if(_isLoaded){
                begin;{
                    int location = attribLocation(name);
                    if(location != -1){
                        _attribNames[name] = true;
                        mixin(glFunctionString!(typeof(v[0]), v.length)("glVertexAttrib"));
                    }else{
                        addLog("Could not find attribute \"" ~ name ~ "\"");
                    }
                }end;
            }
            return this;
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
        Shader attr(Args...)(in string name, Args v)if(Args.length > 0 && !__traits(isArithmetic, Args[0])){
            if(_isLoaded){
                begin;{
                    int location = attribLocation(name);
                    if(location != -1){
                        int dim = attribDim(name);
                        _attribNames[name] = true;
                        glVertexAttribPointer(location, dim, GL_FLOAT, GL_FALSE, 0, v[0].ptr);
                    }else{
                        addLog("Could not find attribute \"" ~ name ~ "\"");
                    }
                }end;
            }
            return this;
        }

        /++
            Set current selected buffer as an attribute.
        +/
        Shader attr(in string name){
            if(_isLoaded){
                begin;{
                    int location = attrLocation(name);
                    if(location != -1){
                        int dim = attribDim(name);
                        _attribNames[name] = true;
                        glVertexAttribPointer(location, dim, GL_FLOAT, GL_FALSE, 0, null);
                    }else{
                        addLog("Could not find attribute \"" ~ name ~ "\"");
                    }
                }end;
            }
            return this;
        }

        /++
            Set vector as an attribute.
            example:
            ----
            auto v = ar.Vector!(float, 3)(1.0, 2.0, 3.0);
        shader.setAttrib("v", v);
        ----
        +/
        Shader attr(V)(in string name, V v)if(isVector!(V) && V.dimention <= 4){
            if(_isLoaded){
                begin;{
                    int location = attribLocation(name);
                    if(location != -1){
                        _attribNames[name] = true;
                        mixin(glFunctionString!(typeof(v[0]), v.elements.length)("glVertexAttrib"));
                    }else{
                        addLog("Could not find attribute \"" ~ name ~ "\"");
                    }
                }end;
            }
            return this;
        }

        /++
        +/
        Shader enableAttrib(in string name){
            glEnableVertexAttribArray(attrLocation(name));
            return this;
        }

        /++
        +/
        Shader disableAttrib(in string name){
            glDisableVertexAttribArray(attrLocation(name));
            return this;
        }
        
        ///
        Shader enableAttribs(){
            import std.algorithm;
            _attribNames.keys.each!(attribName => enableAttrib(attribName));
            return this;
        }

        ///
        Shader disableAttribs(){
            import std.algorithm;
            _attribNames.keys.each!(attribName => disableAttrib(attribName));
            return this;
        }
        
        string[] attribNames()const{
            return _attribNames.keys;
        }
        
        ///
        size_t maxGeometryOutputVertices()const{return _maxGeometryOutputVertices;}
        
        ///
        Shader maxGeometryOutputVertices(in size_t vertices){
            _maxGeometryOutputVertices = vertices;
            return this;
        }
        
        ///
        Shader maximizeMaxGeometryOutputVertices(){
            import std.conv;
            int maxGeometryOutputVerticesTemp;
            glGetIntegerv(GL_MAX_GEOMETRY_OUTPUT_VERTICES, &maxGeometryOutputVerticesTemp);
            _maxGeometryOutputVertices = maxGeometryOutputVerticesTemp;
            return this;
        }
        
        ///
        PrimitiveMode geometryInput()const{
            assert(_geometryInput.hasDefined, "Set geometryInput before loading shader");
            return _geometryInput.primitiveMode;
        }
        
        ///
        Shader geometryInput(in PrimitiveMode p){_geometryInput.primitiveMode = p;return this;}
        
        ///
        PrimitiveMode geometryOutput()const{
            assert(_geometryInput.hasDefined, "Set geometryOutput before loading shader");
            return _geometryOutput.primitiveMode;
        }
        
        ///
        Shader geometryOutput(in PrimitiveMode p){_geometryOutput.primitiveMode = p;return this;}
    }//public

    private{
        int _programID;
        bool[string] _attribNames;
        bool _isLoaded = false;
        string _log;
        int[] _savedIDs;
        
        //geometry shader parameters
        size_t _maxGeometryOutputVertices;
        MustDefinedPrimitiveMode _geometryInput;
        MustDefinedPrimitiveMode _geometryOutput;

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
            import std.string; import std.conv;
            return log.ptr.fromStringz.to!string.chomp;
        }

        string logProgram(in int id)const{
            int strLength;
            glGetProgramiv(id, GL_INFO_LOG_LENGTH, &strLength);
            char[] log = new char[strLength];
            glGetProgramInfoLog(id, strLength, null, log.ptr);
            import std.string; import std.conv;
            return log.ptr.fromStringz.to!string.chomp;
        }

        int attribDim(in string name)
        out(dim){assert(dim>0);}
        body{
            int dim = 0;
            if(_isLoaded){
                begin;scope(exit)end;
                int location = attrLocation(name);
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
                        case GL_FLOAT_VEC4:
                            dim = 4;
                            break;
                        default:
                            dim = 0;
                    }
                }
            }
            return dim;
        }
    }//private
}//class Shader

private template glFunctionString(T, size_t DimC = 1, size_t DimR = 1){
    import std.conv;

    public{
        static if(DimR == 1){
            string normal(in string functionString, in string variableName = "v"){
                return name(functionString) ~ "(location, " ~ args(variableName) ~ ");";
            }

            string array(in string functionString, in string variableName = "v"){
                return name(functionString) ~ "(location, " ~ arrayArgs(variableName) ~ ");";
            }
        }

        string name(in string functionString){
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

        string args(in string variableName){
            string argsStr = variableName~"[0]";
            for (int i = 1; i < DimC; i++) {
                argsStr ~= ", "~variableName~"[" ~ i.to!string~ "]";
            }
            return argsStr;
        }

        string arrayArgs(in string variableName){
            return  variableName ~ ".length.to!int, " ~ variableName ~ ".ptr";
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
        import armos.utils;
        immutable absolutePath = absolutePath(path);
        import std.file:exists, readText;
        if(absolutePath.exists){
            return readText(absolutePath);
        }else{
            return "";
        }
    }
    
    struct MustDefinedPrimitiveMode{
        public{
           PrimitiveMode primitiveMode()const{assert(_hasDefined);return _primitiveMode;}
           void primitiveMode(in PrimitiveMode p){_primitiveMode = p;_hasDefined = true;}
           bool hasDefined()const{return _hasDefined;}
        }//public

        private{
            bool _hasDefined = false;
            PrimitiveMode _primitiveMode;
        }//private
    }//struct GeometryIO
}

static unittest{
    assert( glFunctionString!(float, 3).normal("glUniform") == "glUniform3f(location, v[0], v[1], v[2]);");
    assert( glFunctionString!(float[], 3, 3).name("glUniform") == "glUniformMatrix3fv" );
    assert( glFunctionString!(float[], 2, 3).name("glUniform") == "glUniformMatrix2x3fv" );
    import std.stdio;
    assert( glFunctionString!(float[]).array("glUniform") == "glUniform1fv(location, v.length.to!int, v.ptr);");
}


