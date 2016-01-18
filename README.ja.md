[English](https://github.com/tanitta/armos/blob/master/README.md)/日本語

armos
====
D言語によるクリエイティブコーディングのためのオープンソースライブラリです．

#Description
手軽でパワフルなD言語から使うことができる，[p5](https://processing.org/)や[oF](http://openframeworks.jp/)のような強力なライブラリを目標にしています．
とりあえずは[D言語くん](http://www.kmonos.net/alang/d/images/d3.gif)を画面に召喚するあたりを最初のマイルストーンとして考えています．

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
1. このリポジトリをcloneしましょう

	$git clone https://github.com/tanitta/armos.git
	
2. 次にcloneしたリポジトリをdubのpackageに追加します

	$dub add-local /local/repository/path/

3. dubのプロジェクトのdub.jsonにpackageを追加します

	{
	...
		"dependencies": {
			"armos": ">=0.0.1"
		}
	}
	
4. 仕上げにビルドします

	$dub build
	
#Why use D?
- 処理速度

D言語はC++と同程度の速度で動作します．

- ビルド速度

コンパイルはC++よりもずっと高速です．そのため，開発者はより多くの試行錯誤を繰り返すことができます．

- 拡張性

DのバインディングによりC/C++/Objective-Cのコードを利用することができます．

- 学習が簡単

C++ほど複雑ではありません！

- [その他のDの特徴](http://www.kmonos.net/alang/d/overview.html)

#Contribution
1. このリポジトリをFork
2. feature branch を作ってください(git checkout -b my-new-feature)
3. 変更をcommit(git commit -am 'Add some feature')
4. 2.で作ったbranchにPush(git push origin my-new-feature)
5. Pull Requestを飛ばしましょう
