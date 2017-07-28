[English](https://github.com/tanitta/armos/blob/master/README.md)/日本語

armos
====

[![Dub version](https://img.shields.io/dub/v/armos.svg)](https://code.dlang.org/packages/armos)
[![Dub downloads](https://img.shields.io/dub/dt/armos.svg)](https://code.dlang.org/packages/armos)
[![Build Status](https://travis-ci.org/tanitta/armos.svg?branch=dev)](https://travis-ci.org/tanitta/armos)

D言語によるクリエイティブコーディングのためのオープンソースライブラリです．


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

1. dlangのビルドのためにパッケージを入れます．
  - macOS
  ```
  $ brew install dmd dub
  ```

2. このリポジトリをダウンロードします．
  - 最新版(github)
  ```
  $ git clone git@github.com:tanitta/armos.git
  ```
  ```
  $ dub add-local <repository-path>
  ```

  - 安定版(dub)
  ```
  $ dub fetch armos
  ```

3. ダイナミックライブラリと and glslのパッケージの管理のためにnpmをインストールします．
  - macOS
  ```
  $ brew install glfw3 assimp freeimage libogg libvorbis npm
  ```

4. armosをビルドします．
  ```
  $ dub build armos
  ```

## Usage

新規にProjectを生成します．

```
$ dub run armos -- generate project <projectpath>
```

armosへのaliasを設定することをオススメします． (`$ dub list | grep "armos"`コマンドでarmosのパスを調べることができます)

```
alias armos="path/to/armos"
```

または，既に存在するパッケージに追加することもできます．
以下の依存関係を既存のプロジェクトのdub.sdlまたはdub.jsonのdependencies sectionへ追記します．

- dub.json

  ```
  "armos": "~>0.1.0"
  ```

- dub.sdl

  ```
  dependency "armos" version="~>0.0.1"
  ```

## Why use D?

- 処理速度 : D言語はC++と同程度の速度で動作します．

- ビルド速度 : コンパイルはC++よりもずっと高速です．そのため，開発者はより多くの試行錯誤を繰り返すことができます．

- 拡張性 : DのバインディングによりC/C++/Objective-Cのコードを利用することができます．

- 学習が簡単 : C++ほど複雑ではありません．

- [その他のDの特徴](http://www.kmonos.net/alang/d/overview.html)


## ScreenShots

![ss0](https://41.media.tumblr.com/2297723261811b737966bc353aa3fb5b/tumblr_o1eruzJSFd1u9jb8mo1_1280.png)

![ss1](https://41.media.tumblr.com/34ca170f2fc91b8b7d789faa6fd85ba3/tumblr_o1bl8yAazQ1u9jb8mo2_r1_1280.png)


## Contribution

1. このリポジトリをForkします
2. feature branch を作ってください(git checkout -b my-new-feature)
3. 変更をcommitします(git commit -am 'Add some feature')
4. 2.で作ったbranchにPush(git push origin my-new-feature)
5. Pull Requestを飛ばしましょう
