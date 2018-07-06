English/[日本語](https://github.com/tanitta/armos/blob/master/README.ja.md)

armos
====

[![Dub version][dub-version]][dub-version-url]
[![Dub downloads][dub-downloads]][dub-downloads-url]
[![License][license-badge]][license-badge-url]
[![Build Status][build-status]][build-status-url]

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

## Platform

- Linux
- macOS
- Windows

## Require

- [dmd](https://dlang.org/)
- [ldc](https://github.com/ldc-developers/ldc)(optional)
- [dub](http://code.dlang.org/)
- npm
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
  $ brew install dmd dub
  ```

2. Download this repository.
  - Latest(via github)
  ```
  $ git clone git@github.com:tanitta/armos.git
  ```
  ```
  $ dub add-local <repository-path>
  ```

  - Stable(via dub)
  ```
  $ dub fetch armos
  ```

3. Install dependent dynamic libraries and npm for glsl package management.
  - macOS
  ```
  $ brew install glfw3 assimp freeimage libogg libvorbis npm
  ```

4. Build armos.
  ```
  $ dub build armos
  ```

## Usage

Generate new project.

```
$ dub run armos -- generate project <projectpath>
```

We recoment to set alias. (This command: `$ dub list | grep "armos"` will find a package  path of armos)

```
alias armos="path/to/armos"
```

Or, add to aleady existing package.

put the following dependency into your project's dub.sdl or dub.json.

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


[dub-version]:       https://img.shields.io/dub/v/armos.svg
[dub-version-url]:   https://code.dlang.org/packages/armos
[dub-downloads]:     https://img.shields.io/dub/dt/armos.svg
[dub-downloads-url]: https://code.dlang.org/packages/armos
[license-badge]:     https://img.shields.io/badge/License-BSL%20v1.0-blue.svg
[license-badge-url]: ./LICENSE
[build-status]:      https://travis-ci.org/tanitta/armos.svg?branch=dev
[build-status-url]:  https://travis-ci.org/tanitta/armos
