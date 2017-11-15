module armos.graphics.gl.shader;

import derelict.opengl3.gl;
import colorize;

import armos.math.vector;
import armos.math.matrix;
import armos.graphics.gl.primitivemode;
import armos.graphics.gl.shadersource;
import armos.graphics.gl.shaderutils;
import armos.graphics.gl.context;

public import armos.graphics.gl.uniform;

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
            return this._log;
        }

        Shader clearLog(){
            _log = [];
            return this;
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
        Shader loadFiles(in string vertexShaderSourcePath,
                         in string geometryShaderSourcePath,
                         in string fragmentShaderSourcePath,
                         in string[] paths = [])
        {
            loadSources((vertexShaderSourcePath   != "")?(Source.load(vertexShaderSourcePath)):   null,
                        (geometryShaderSourcePath != "")?(Source.load(geometryShaderSourcePath)): null,
                        (fragmentShaderSourcePath != "")?(Source.load(fragmentShaderSourcePath)): null,
                        paths);
            return this;
        }
        
        ///
        Shader loadSources(in string vertexShaderSourceText,
                           in string geometryShaderSourceText,
                           in string fragmentShaderSourceText,
                           in string[] paths = [])
        {
            Source vertexShaderSource;
            Source geometryShaderSource;
            Source fragmentShaderSource;

            if(vertexShaderSourceText != ""){
                vertexShaderSource = new Source(vertexShaderSourceText, "main.vert", "");
            }
            if(geometryShaderSourceText != ""){
                geometryShaderSource = new Source(geometryShaderSourceText, "main.geom", "");
            }
            if(fragmentShaderSourceText != ""){
                fragmentShaderSource = new Source(fragmentShaderSourceText, "main.vert", "");
            }

            loadSources(vertexShaderSource, geometryShaderSource, fragmentShaderSource, paths);

            return this;
        }

        /++
            Load the shader from sources 
        +/
        Shader loadSources(Source vertexShaderSource,
                           Source geometryShaderSource,
                           Source fragmentShaderSource,
                           in string[] paths = [])
        {
            if(_programID){
                glDeleteProgram(_programID);
                _programID = glCreateProgram();
                _isLoaded = false;
                _attribNames.clear;
            }

            addLog("#### Vertex Shader Source ####".color(mode.bold));
            if(vertexShaderSource){
                addLog("Expanding vertex shader...");
                vertexShaderSource.expand(paths);
                addLog(("Expanded vertex shader (%d lines)".format(vertexShaderSource.numLines)).color(fg.green));
                addLog("Loading vertex shader...");
                bool isCompiled = loadShaderSource(vertexShaderSource.expanded, GL_VERTEX_SHADER);
                if(isCompiled){
                    addLog("Finish loading vertex shader successfully.".color(fg.green).color(mode.bold));
                }else{
                    addLog("Failed loading vertex shader".color(fg.red).color(mode.bold));
                }
            }else{
                addLog("Skip vertex shader");
            }
            addLog("");

            addLog("#### Geometry Shader Source ####".color(mode.bold));
            if(geometryShaderSource){
                addLog("Expanding geometry shader...");
                geometryShaderSource.expand(paths);
                addLog(("Expanded geometry shader (%d lines)".format(geometryShaderSource.numLines)).color(fg.green));
                addLog("Loading geometry shader..");
                bool isCompiled = loadShaderSource(geometryShaderSource.expanded, GL_GEOMETRY_SHADER);
                if(isCompiled){
                    addLog("Finish loading geometry shader successfully.".color(fg.green).color(mode.bold));
                }else{
                    addLog("Failed loading geometry shader".color(fg.red).color(mode.bold));
                }
                glProgramParameteri(_programID, GL_GEOMETRY_INPUT_TYPE, _geometryInput.primitiveMode);
                glProgramParameteri(_programID, GL_GEOMETRY_OUTPUT_TYPE, _geometryInput.primitiveMode);
                import std.conv:to;
                glProgramParameteri(_programID, GL_GEOMETRY_VERTICES_OUT, _maxGeometryOutputVertices.to!int);
            }else{
                addLog("Skip geometry shader");
            }

            addLog("");
            
            addLog("#### Fragment Shader Source ####".color(mode.bold));
            if(fragmentShaderSource){
                addLog("Expanding fragment shader...");
                fragmentShaderSource.expand(paths);
                addLog(("Expanded fragment shader (%d lines)".format(fragmentShaderSource.numLines)).color(fg.green));
                addLog("Loading fragment shader...");
                bool isCompiled = loadShaderSource(fragmentShaderSource.expanded, GL_FRAGMENT_SHADER);
                if(isCompiled){
                    addLog("Finish loading fragment  shader successfully.".color(fg.green).color(mode.bold));
                }else{
                    addLog("Failed loading fragment  shader".color(fg.red).color(mode.bold));
                }
            }else{
                addLog("Skip fragment shader");
            }

            addLog("");

            addLog("#### Link Sources ####".color(mode.bold));
            glLinkProgram(_programID);

            int isLinked;
            glGetProgramiv(_programID, GL_LINK_STATUS, &isLinked);
            if (isLinked == GL_FALSE) {
                addLog("Link error.".color(fg.red).color(mode.bold));
                addLog(logProgram(_programID));
                _isLoaded = false;
            }else{
                addLog("Link success.".color(fg.green).color(mode.bold));
                _isLoaded = true;
            }

            addLog("");

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
            currentContext.pushShader(this);
            return this;
        }

        /++
            End adapted process
        +/
        Shader end(){
            currentContext.popShader();
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

    package{
        Shader bind(){
            return Shader.bind(this);
        }

        static Shader bind(Shader shader){
            if(!shader){
                glUseProgram(0);
                return shader;
            }
            glUseProgram(shader._programID);
            return shader;
        }
    }

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
            this._log ~= (str ~ "\n");
        }

        bool loadShaderFile(in string shaderPath, GLuint shaderType){
            auto shaderSource = loadedSource(shaderPath);
            return loadShaderSource(shaderSource, shaderType);
        }
        
        bool loadShaderSource(in string shaderSource, GLuint shaderType){
            int shaderID = glCreateShader(shaderType);
            scope(exit) glDeleteShader(shaderID);

            bool isCompleted = compile(shaderID, shaderSource);
            if(!isCompleted)return false;
            glAttachShader(_programID, shaderID);
            return true;
        }

        bool compile(in int id, in string source){
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
                return false;
            }else{
                addLog("compile success".color(fg.green));
                return true;
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


