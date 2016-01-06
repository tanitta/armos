module armos.utils.file;
/**
 **/
string toDataPath(in string fileName, in bool makeAbsolute = true){
	import std.string;
	import std.file;
	import std.path;
	return buildPath(thisExePath.dirName, "data", fileName);
}
