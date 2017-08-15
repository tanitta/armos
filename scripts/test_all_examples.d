#!/usr/bin/env dub
/+ dub.sdl:
	name "test_all_examples"
+/

/++
+/
enum TestStatus {
    Waiting, 
    Red, 
    Green, 
}//enum TestStatus

/++
+/
enum Compiler {
    dmd,
    ldc,
}//enum Compiler

import std.path;
import std.file;
import std.stdio;
/++
+/
class TestCase {
    public{
        this(in string examplePath, in Compiler compilerName, in string skipRegistry = "none"){
            _path = examplePath;
            _compilerName = compilerName;
            _skipRegistry = skipRegistry;
        }

        typeof(this) test(){
            import std.stdio : writeln;
            string[] command = ["dub", "test", "-f", "--skip-registry="~ _skipRegistry];
            switch (_compilerName) {
                case Compiler.dmd:
                    break;
                case Compiler.ldc:
                    command ~= ["--compiler=ldc2"];
                    break;
                default:
                    assert(false);
            }
            import std.process;
            string workingDir = __FILE__.dirName.buildPath("..", _path).absolutePath;
            auto dub = execute(command, null, Config.none, size_t.max, workingDir);
            _status = (dub.status == 0)?TestStatus.Green:TestStatus.Red;
            _output = dub.output;
            return this;
        }

        TestStatus status()const{
            return _status;
        }

        string output()const{
            return _output;
        }

        string path()const{
            return _path;
        }

        string compiler()const{
            import std.conv;
            return _compilerName.to!string;
        }
    }//public

    private{
        TestStatus _status = TestStatus.Waiting;
        string _path;
        string _output;
        string _skipRegistry;
        Compiler _compilerName;
    }//private
}//struct TestCase

void main() {
    string travisConfigPath = __FILE__.dirName.buildPath("..", ".travis.yml").absolutePath;
    auto travisConfig = readText(travisConfigPath);
    import std.algorithm;
    import std.regex;
    auto r = regex(r"- TEST_DIR=");
    import std.array:array;
    import std.conv;
    import std.string;
    string[] testDirs  = travisConfig.splitLines
                                     .filter!(e => !e.matchAll(r).empty)
                                     .map!(e => e.match(regex(r"(?<=- TEST_DIR=)(.*)")).array[0][0])
                                     .map!(e => e.to!string)
                                     .array;
    string[] compilers = travisConfig.splitLines
                                     .findSplitBefore(["env:"])[0]
                                     .findSplitAfter(["d:"])[1]
                                     .map!(e => e.match(regex(r"(?<= - )(.*)")).array[0][0])
                                     .array;
    
    TestCase[] testCases;

    foreach (compiler; compilers) {
        foreach (testDir; testDirs) {
            auto testCase = new TestCase(testDir, compiler.to!Compiler, testDir=="."?"none":"standard");
            testCases ~= testCase;
        }
    }

    foreach (testCase; testCases) {
        writeln("Compiler:", testCase.compiler);
        writeln("Path:", testCase.path);
        testCase.test;
        writeln("Status:", testCase.status);
        if(testCase.status == TestStatus.Red){
            writeln("output:");
            writeln(testCase.output);
        }
        writeln("");
    }
}
