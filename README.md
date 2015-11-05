English/Japanese

armos
====
armos is a free and open source library for creative coding in D programming language.

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
		};
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
	
2. Add to dub library.
	$dub add-local /local/repository/path/

#Why use D?
- Processing Speed
D is as fast as C++ programs.

- Build Speed
The compilation is more faster than a speed of C++. Because of that, we can repeat trial and error.

- Extensibility
We can use C/C++/Objective-C via D binding.

- Easiness to learn
It isn't so much complex than C++.

#Contribution
1. Fork it ( http://github.com//rbdock/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create new Pull Request
