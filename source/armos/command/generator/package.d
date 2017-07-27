module armos.command.generator;

import std.path;
import std.file;

auto generate(string[] args){
    parse(args);
}

private auto parse(string[] args){
    bool hasTarget = false;
    immutable target = args[0];
    switch (target) {
        case "project":
            import armos.command.generator.project;
            args[1..$].generateProject;
            break;
        case "material":
            assert(getcwd.isProjectRoot);
            import armos.command.generator.material;
            args[1..$].generateMaterial;
            break;
        default:
            assert(false, "No implementation");
    }
}

private bool isProjectRoot(in string path){
    return (buildPath(path, "dub.json").exists || buildPath(path, "dub.sdl").exists);
}
