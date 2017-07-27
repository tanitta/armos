module armos.command.generator.material;

import std.path;
import std.file;
import std.uni:toLower;

auto generateMaterial(string[] args){
    MaterialConfig config;
    config.className = args[0];
    config.path = buildPath(packageName(), "materials", config.className.toLower~".d");
    import std.getopt;
    args.getopt("path|p", &config.path);
    import std.array;
    import std.algorithm;
    import std.conv;
    config.path = config.path.toLower.filter!(c => c!='-').array.to!string;

    immutable source = generateMaterialSource(config);

    string writenPath = buildPath(getcwd, "source", config.path);
    if(!writenPath.dirName.exists){
        writenPath.dirName.mkdirRecurse;
    }
    write(writenPath, source);
}

/++
+/
struct MaterialConfig {
    public{
        string className;
        string path;
    }//public

    private{
    }//private
}//struct MaterialConfig

auto generateMaterialSource(in MaterialConfig config){
    string absolutePath;
    if(isAbsolute(config.path)){
        absolutePath = config.path;
    }else{
        absolutePath = buildPath(getcwd, config.path);
    }

    import std.array;
    import std.algorithm;
    import std.conv;
    auto moduleName = config.path.setExtension("").pathSplitter.array;
    return materialSourceTemplate(moduleName, config.className);
}

unittest{
    // MaterialConfig config = {className:"BunnyMaterialm", path:packageName ~ "/" ~ "materials/bunny"};
    // import std.stdio;
    // generateMaterialSource(config).writeln;
}

    
string materialSourceTemplate(in string[] moduleName, in string className){
    import std.array;
    return `module `~moduleName.join('.')~`;
import armos.graphics.material;
class `~ className ~` : Material{
    mixin MaterialImpl;
}
`;
}

string packageName(){
    import dub.package_:Package;
    import dub.internal.vibecompat.inet.path:Path;
    auto thisPackage = Package.load(Path(buildPath(getcwd)));
    return thisPackage.recipe.name;
}

unittest{
    assert(packageName == "armos");
}
