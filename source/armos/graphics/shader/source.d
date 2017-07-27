module armos.graphics.shader.source;

/++
+/
class Source {
    public{
        ///
        this(in string rawText, in string name, in string path = ""){
            this.rawText = rawText;
            this.name = name;
            if(path == ""){
                this.path = name;
            }else{
                this.path = path;
            }
        }

        static Source load(in string path){
            import armos.utils.file;
            import std.path;
            import std.file;
            string absolutePath;
            if(isAbsolute(path)){
                absolutePath = path;
            }else{
                absolutePath = buildPath(thisExePath.dirName, path);
            }

            assert(absolutePath.exists, "File not found: " ~ absolutePath);
            string content = readText(absolutePath);
            Source source = new Source(content, path.baseName, path);
            return source;
        }

        ///
        Source expand(in string[] paths = [], Source[] searchableList = []){
            import armos.utils.file;
            import std.path;
            import std.file;
            string absolutePath;
            if(isAbsolute(path)){
                absolutePath = path;
            }else{
                absolutePath = buildPath(thisExePath.dirName, path);
            }

            string glslifyPath = "glslify";

            import std.process;
            auto command = "echo " ~ "\"" ~ rawText ~"\"" ~ " | " ~ glslifyPath;
            auto result = executeShell(command, null, Config.none, size_t.max, absolutePath.dirName);
            assert(!result.status, command ~ "\n" ~ result.output);
            _expanded = result.output;
            return this;
        }

        ///
        string expanded()const{
            return _expanded;
        }
    }//public

    string rawText;
    string name;
    string path;
    Line[] lines;
    string _expanded;

    /// WARNING: duplicatable
    Source[] dependencies;

    /// WARNING: duplicatable
    Source[] allDependencies(){
        import std.algorithm;
        import std.array;
        return dependencies.map!(src => src.allDependencies).join.array ~ dependencies;
    }

    private{
        size_t includeSource(in size_t currentLineIndex, in string[] paths, Source[] searchableList){
            const line = lines[currentLineIndex];
            string includingTargetPath = elementNameFromMacroStatement(line.content);
            size_t lineLength;
            import std.path;
            import std.file;
            string absIncludingTargetPath;
            if(includingTargetPath.isAbsolute){
                absIncludingTargetPath = includingTargetPath;
            }else{
                // First, attempt to search the file from local dir.
                // Next, attempt to search from searchable paths.
                foreach (p; this.path.dirName ~ paths) {
                    absIncludingTargetPath = buildPath(p, includingTargetPath);
                    if(absIncludingTargetPath.exists){
                        break;
                    }
                }
                assert(absIncludingTargetPath, "File not found: " ~ absIncludingTargetPath);
            }
            assert(absIncludingTargetPath.exists, "File not found: " ~ absIncludingTargetPath);

            Source includingTargetSource = Source.load(absIncludingTargetPath);
            includingTargetSource.expand(paths, searchableList);
            dependencies ~= includingTargetSource;

            Line LineSpecificationBegin = {origin: includingTargetSource,
                                           content: "#line 1 " ~ absIncludingTargetPath};
            import std.conv;
            Line LineSpecificationEnd   = {origin: this,
                                           content: "#line " ~ (currentLineIndex+1).to!string ~ " " ~ path};

            this.lines = this.lines[0..currentLineIndex] ~ 
                         LineSpecificationBegin ~ 
                         includingTargetSource.lines ~ 
                         LineSpecificationEnd ~ 
                         this.lines[currentLineIndex+1..$];

            lineLength = includingTargetSource.lines.length + 2;
            return lineLength;
        }
    }//private
}//class Source

version(unittest){
    mixin template SourceA() {
        auto sourceA = new Source(q{#include "sourceB.frag"
                               void main(){}
                }, "sourceA", "data/sourceA.frag");
    }//template SourceA

    mixin template SourceB() {
        auto sourceB = new Source(q{#include "sourceC.frag"
                vec4 funcB(){return vec4(1, 2, 3, 4);}
                }, "sourceB", "data/sourceB.frag");
    }//template SourceB

    mixin template SourceC() {
        auto sourceC = new Source(q{
                vec4 funcC(){return vec4(1, 2, 3, 4);}
                }, "sourceC", "data/sourceC.frag");
    }//template SourceC
}

unittest{
    //TODO
    // import std.path;
    // import std.file;
    // string dir = buildNormalizedPath(__FILE_FULL_PATH__.dirName,
    //                                  "..", "..", "..", "..",
    //                                  "test", "graphics", "shader", "precompiler", "include");
    // assert(dir.exists);
    //
    // assert(Source.load(buildPath(dir, "source_a.frag")).expand.lines.length == 11);
}

/++
+/
struct Line {
    public{
        Source origin;
        string content;
        auto expand(in Source[] searchable){
        }
    }//public

    private{
    }//private
}//struct Line

auto  elementNameFromMacroStatement(in string macroStatement){
    import std.string;
    immutable stripped = macroStatement.strip;
    immutable first = stripped.indexOf('"');
    immutable last = stripped.lastIndexOf('"');
    return stripped[first+1..last];
}

unittest{
    assert(elementNameFromMacroStatement(`#include "hoge"`) == "hoge");
}

bool isMacroStatement(in string line){
    import std.string;
    immutable stripped = line.strip;
    return stripped.length > 0 && stripped[0] == '#';
}

unittest{
    assert(isMacroStatement(`#include "hoge"`));
    assert(isMacroStatement(`    #include "hoge"`));
    assert(!isMacroStatement(`void main{}`));
}

string macroNameFrom(in string macroStatement){
    import std.string;
    immutable stripped = macroStatement.strip;
    immutable last = stripped.lastIndexOf(' ');
    return stripped[1..last];
}

unittest{
    assert(macroNameFrom(`#include "hoge"`) == "include");
    assert(macroNameFrom(`    #include "hoge"`) == "include");
}
