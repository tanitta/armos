import armos.command;

import std.getopt;

void main(string[] args){
    if(args.length < 2) return;
    execCommand(args);
}
