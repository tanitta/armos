module armos.utils.file;
/**
 **/
string toPublicPath(in string fileName, in bool makeAbsolute = true){
	import std.string;
	import std.file;
	import std.path;
	// return thisExePath.dirName ~ dirSeparator ~ "data" ~ dirSeparator ~ dataPath;
	return buildPath(thisExePath.dirName, "public", fileName);
}
