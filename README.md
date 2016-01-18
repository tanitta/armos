English/[日本語](https://github.com/tanitta/armos/blob/master/README.ja.md)

armos
====
armos is a free and open source library for creative coding in D programming language.

#Description
D is very powerfull and easily programming language. But, I couldn't find anything that is able to write easily such as [p5](https://processing.org/) and [oF](http://www.openframeworks.cc/). Thereupon, I began to create this project.
I think that first mileStone will probably be summoning [D-man](http://www.kmonos.net/alang/d/images/d3.gif) into display for the time being.

#Demo
	import armos;
	class TestApp : ar.BaseApp{
		ar.Mesh line = new ar.Mesh;
		
		void setup(){
			ar.setLineWidth(2);
			line.primitiveMode = ar.PrimitiveMode.LineStrip;
		}
		
		void draw(){
			line.drawWireFrame;
		}
		
		void mouseMoved(int x, int y, int button){
			line.addVertex(x, y, 0);
			line.addIndex(cast(int)line.numVertices-1);
		}
	}
	
	void main(){ar.run(new TestApp);}

#Examples
[armos_examples](https://github.com/tanitta/armos_examples)
	
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
Contributions are very welcome! 

1. Fork it
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create new Pull Request
