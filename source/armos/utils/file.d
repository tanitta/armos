module armos.utils.file;
/**
 **/
string toDataPath(in string fileName, in bool makeAbsolute = true){
    import std.string;
    import std.file;
    import std.path;
    return buildPath(thisExePath.dirName, fileName);
}

/++
Return absolutePath from absolute or relative
+/
string absolutePath(string path){
    import std.path;
    import armos.utils;
    string absolutePath;
    if(isAbsolute(path)){
        absolutePath = path;
    }else{
        absolutePath = toDataPath(path);
    }
    return absolutePath;
}
