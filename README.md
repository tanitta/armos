English/[日本語](https://github.com/tanitta/armos/blob/master/README.ja.md)

armos
====

[![Dub version](https://img.shields.io/dub/v/armos.svg)](https://code.dlang.org/packages/armos)
[![Dub downloads](https://img.shields.io/dub/dt/armos.svg)](https://code.dlang.org/packages/armos)
[![Build Status](https://travis-ci.org/tanitta/armos.svg?branch=dev)](https://travis-ci.org/tanitta/armos)

armos is a free and open source library for creative coding in D programming language.


## Demo

```
import armos.app;
import armos.graphics;
class TestApp : BaseApp{
    Mesh line = new Mesh;

    override void setup(){
        lineWidth(2);
        line.primitiveMode = PrimitiveMode.LineStrip;
    }

    override void draw(){
        line.drawWireFrame;
    }

    override void mouseMoved(int x, int y, int button){
        line.addVertex(x, y, 0);
        line.addIndex(cast(int)line.numVertices-1);
    }
}

void main(){run(new TestApp);}
```


## Require
- [dmd](https://dlang.org/)
- [ldc](https://github.com/ldc-developers/ldc)(optional)
- [dub](http://code.dlang.org/)
- GLFW3
- OpenGL3
- FreeImage
- OpenAL
- libogg
- libvorbis
- Assimp


## Install
1. Install some packages to build with dlang.
  - macOS
  ```
  brew install dmd dub
  ```

1. Download this repository.
  - via github
  ```
  git clone git@github.com:tanitta/armos.git
  ```
  ```
  dub add-local <repository-path>
  ```

  - via dub(deprecated)
  ```
  dub fetch armos
  ```


1. Install dependency dynamic libraries.
  - macOS
  ```
  brew install glfw3 assimp freeimage libogg libvorbis
  ```

## Usage  
1. put the following dependency into your project's dub.sdl or dub.json.
  ```
  dependency "armos" version="~>0.0.1"
	```

## Why use D?

- Processing Speed : D is as fast as C++ programs.

- Build Speed : The compilation is more faster than a speed of C++. Because of that, we can repeat trial and error.

- Extensibility : We can use C/C++/Objective-C via D binding.

- Easiness to learn : It isn't so much complex than C++!

- Other point is [here](http://dlang.org/index.html)


## ScreenShots

![ss1](https://github.com/tanitta/armos/blob/dev/ss/ss1.png)

![ss2](https://github.com/tanitta/armos/blob/dev/ss/ss2.png)


## Contribution

Contributions are very welcome!

1. Fork it
2. Create your feature branch from dev branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create new Pull Request
