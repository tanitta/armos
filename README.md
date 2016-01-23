English/[日本語](https://github.com/tanitta/armos/blob/master/README.ja.md)

armos
====
armos is a free and open source library for creative coding in D programming language.

#Demo
```
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
```
	
#Require
- [dub](http://code.dlang.org/)
- GLFW
- SDL2(optional)
- openGL3
- FreeImage

#Install
1. To use this package, put the following dependency into your project's dub.sdl.
	```
	dependency "armos" version="~>0.0.1"
	```

2. Add to dub package.
	```
	dub build
	```

#Why use D?
- Processing Speed : D is as fast as C++ programs.

- Build Speed : The compilation is more faster than a speed of C++. Because of that, we can repeat trial and error.

- Extensibility : We can use C/C++/Objective-C via D binding.

- Easiness to learn : It isn't so much complex than C++!

- Other point is [here](http://dlang.org/index.html)

#ScreenShots
![ss0](https://41.media.tumblr.com/2297723261811b737966bc353aa3fb5b/tumblr_o1eruzJSFd1u9jb8mo1_1280.png)

![ss1](https://41.media.tumblr.com/34ca170f2fc91b8b7d789faa6fd85ba3/tumblr_o1bl8yAazQ1u9jb8mo2_r1_1280.png)

#Contribution
Contributions are very welcome! 

1. Fork it
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create new Pull Request
