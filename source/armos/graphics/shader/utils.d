module armos.graphics.shader.utils;

template glFunctionString(T, size_t DimC = 1, size_t DimR = 1){
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
            }else if(is(T == uint)){
                type = "ui";
            }else if(is(T == int)){
                type = "i";
            }

            static if(is(T == float[])){
                type = "fv";
            }else if(is(T == double[])){
                type = "bv";
            }else if(is(T == uint[])){
                type = "uiv";
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

static unittest{
    assert( glFunctionString!(float, 3).normal("glUniform") == "glUniform3f(location, v[0], v[1], v[2]);");
    assert( glFunctionString!(float[], 3, 3).name("glUniform") == "glUniformMatrix3fv" );
    assert( glFunctionString!(float[], 2, 3).name("glUniform") == "glUniformMatrix2x3fv" );
    import std.stdio;
    assert( glFunctionString!(float[], 3).array("glUniform") == "glUniform3fv(location, v.length.to!int, v.ptr);");
}

