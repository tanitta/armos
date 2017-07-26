module armos.command;

auto execCommand(string[] args){
    import std.algorithm;

    immutable verb = args[1];
    if(["generate", "g", "init"].canFind(verb)){
        import armos.command.generator;
        generate(args[2..$]);
    }
}
