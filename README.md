English/[Japanese](https://github.com/tanitta/armos/blob/master/README.ja.md)

armos
====
armos is a free and open source library for creative coding in D programming language.

#Description
D is very powerfull and easily programming language. But, I couldn't find anything that is able to write easily such as [p5](https://processing.org/) and [oF](http://www.openframeworks.cc/). Thereupon, I began to create this project.
I think that first mileStone is probably summoning D-man into display for the time being.

#Demo
	import std.stdio;
	import armos.app;

	class TestApp : armos.app.BaseApp{
		void setup(){
			writeln("setup");
		}
		void update(){
			writeln("update");
		}
		void draw(){
			writeln("draw");
		}
		void keyPressed(int key){
			writeln("keyPressed: ", key);
		}
		void keyReleased(int key){
			writeln("keyReleased: ", key);
		}
	}

	void main(){
		armos.app.run(new TestApp());
	}
	
#Require
- [dub](http://code.dlang.org/)

#Install
1. Clone this repository.

	$git clone https://github.com/tanitta/armos.git
	
2. Add to dub package.

	$dub add-local /local/repository/path/

#Why use D?
- Processing Speed

D is as fast as C++ programs.

- Build Speed

The compilation is more faster than a speed of C++. Because of that, we can repeat trial and error.

- Extensibility

We can use C/C++/Objective-C via D binding.

- Easiness to learn

It isn't so much complex than C++!

- Other point is [here](http://dlang.org/index.html)

#Contribution
1. Fork it
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create new Pull Request
