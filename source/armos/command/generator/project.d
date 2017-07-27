module armos.command.generator.project;

auto generateProject(string[] args, ){
    ProjectConfig config = parseProject(args);
    import std.process;
    import std.conv;
    import std.string;
    auto pipes = pipeProcess(["dub","init", "-n", "--format="~config.format.to!string, config.path], Redirect.stdin | Redirect.stdout);
    pipes.stdin.close;
    pipes.stdout.close;
    wait(pipes.pid);

    addArmosDependency(config);
    setupMainAppSource(config);
    setupGlslify(config);
}

import armos.command.generator.component;

private struct ProjectConfig {
    string path;
    string name;
    PackageRecipeFormat format = PackageRecipeFormat.json;
    Component[] components;
    //camera
    //fbo
    //material
    //bufferentity
}

private enum PackageRecipeFormat{
    json, 
    sdl 
}

private ProjectConfig  parseProject(string[] args){
    import std.functional;
    string path = (args.length>0 && args[0][0] != '-')?args[0]:"./";
    import std.path;
    if(!path.isAbsolute){
        import std.file;
        path = buildPath(getcwd, path);
    }
    string name = path.baseName;

    Component[] components;
    DefaultCamera.add(components, args);

    ProjectConfig config = {
        path: path, 
        name: name, 
        components: components, 

    };
    return config;
}

private auto addArmosDependency(in ProjectConfig config){
    switch (config.format) {
        case PackageRecipeFormat.sdl:
            addArmosDependencyToSDL(config);
            break;
        case PackageRecipeFormat.json:
            addArmosDependencyToJSON(config);
            break;
        default:
            assert(0);
    }
}

private auto addArmosDependencyToSDL(in ProjectConfig config){
    import std.file;
    import std.path;
    string text = readText(buildPath(config.path, "dub.sdl"));
    import std.stdio;
    text.writeln;
    assert(0, "TODO");
}

private auto addArmosDependencyToJSON(in ProjectConfig config){
    import std.file;
    import std.path;
    immutable dubFilePath = buildPath(config.path, "dub.json");
    string text = readText(dubFilePath);
    import std.json;
    JSONValue json = parseJSON(text);
    JSONValue armosPackage = JSONValue("armos");
    json.object["dependencies"] = JSONValue();
    json.object["dependencies"]["armos"] = JSONValue(latestPackageVersion("armos"));
    write(dubFilePath, toJSON(json, true));
}

private string latestPackageVersion(in string name){
    import std.process;
    import std.algorithm;
    import std.array;
    import std.string;
    import std.typecons;
    auto packages = executeShell("dub list").output.strip.split("\n").map!((p){auto splitted = p.strip.split(" ");return tuple!("name", "ver", "path")(splitted[0], splitted[1][0..$-1], splitted[2]);});
    return packages.filter!(p => p.name == name).array[$-1].ver;
}

private void setupMainAppSource(in ProjectConfig config){
    string[] defines;
    string[] setups;
    string[] updates;
    string[] draws;
    foreach (component; config.components) {
        defines ~= component.define;
        setups  ~= component.setup;
        updates ~= component.update;
        draws   ~= component.draw;
    }

    import armos.command.generator.mainapp;
    immutable sourceText = mainAppSourceTemplate(defines, setups, updates, draws);
    import std.file;
    import std.path;
    immutable appSourcePath = buildPath(config.path, "source", "app.d");
    write(appSourcePath, sourceText);
}

private void setupGlslify(in ProjectConfig config){
    import std.process;
    if(execute(["which", "glslify"]).status != 0){
        execute(["npm", "install", "-g", "glslify"], null, Config.none, size_t.max, config.path); 
    }
    execute(["npm", "init", "-y"], null, Config.none, size_t.max, config.path); 
}

