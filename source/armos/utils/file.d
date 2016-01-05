module armos.utils.file;
/**
 **/
string toDataPath(in string dataPath, in bool makeAbsolute = true){
	import std.string;
	import std.file;
	return thisExePath.split("/")[0..$-1].join("/") ~ "/data/" ~ dataPath;
}
