armos
====
armos is a free and open source library for creative coding in D programming language.

#Example
	import std.stdio;
	import armos.app;

	class TestApp : armos.app.BaseApp{
		void draw(){
			writeln("Hoge!");
		};
	}

	void main(){
		armos.app.run(new TestApp());
	}

#Why use D?
