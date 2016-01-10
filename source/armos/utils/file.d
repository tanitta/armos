module armos.utils.file;
/**
 **/
string toDataPath(in string fileName, in bool makeAbsolute = true){
	import std.string;
	import std.file;
	import std.path;
	return buildPath(thisExePath.dirName, "data", fileName);
}

/++
	Return absolutePath
++/
string absolutePath(string path){
	import std.path;
	string absolutePath;
	if(isAbsolute(path)){
		absolutePath = path;
	}else{
		absolutePath = armos.utils.toDataPath(path);
	}
	return absolutePath;
}
