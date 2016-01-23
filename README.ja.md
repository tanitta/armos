[English](https://github.com/tanitta/armos/blob/master/README.md)/日本語

armos
====
D言語によるクリエイティブコーディングのためのオープンソースライブラリです．

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
1. このpackageを利用できるようにするため，dubのプロジェクトのdub.sdlに以下の記述を追加します．
	```
	dependency "armos" version="~>0.0.1"
	```

2. ライブラリのビルドを行います
	```
	dub build
	```
	
#Why use D?
- 処理速度 : D言語はC++と同程度の速度で動作します．

- ビルド速度 : コンパイルはC++よりもずっと高速です．そのため，開発者はより多くの試行錯誤を繰り返すことができます．

- 拡張性 : DのバインディングによりC/C++/Objective-Cのコードを利用することができます．

- 学習が簡単 : C++ほど複雑ではありません．

- [その他のDの特徴](http://www.kmonos.net/alang/d/overview.html)

#ScreenShots
![ss0](https://41.media.tumblr.com/2297723261811b737966bc353aa3fb5b/tumblr_o1eruzJSFd1u9jb8mo1_1280.png)

![ss1](https://41.media.tumblr.com/34ca170f2fc91b8b7d789faa6fd85ba3/tumblr_o1bl8yAazQ1u9jb8mo2_r1_1280.png)

#Contribution
1. このリポジトリをForkします
2. feature branch を作ってください(git checkout -b my-new-feature)
3. 変更をcommitします(git commit -am 'Add some feature')
4. 2.で作ったbranchにPush(git push origin my-new-feature)
5. Pull Requestを飛ばしましょう
