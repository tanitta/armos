module armos.utils.gui;
import armos.graphics;
import armos.types.color;
import armos.app;
import armos.math;

/++
値にアクセスするGuiを表すclassです．

Examples:
---
class TestApp : ar.BaseApp{
	ar.Gui gui;
	float f=128;
	
	void setup(){
		gui = (new ar.Gui)
		.add(
			(new ar.List)
			.add(new ar.Partition)
			.add(new ar.Label("some text"))
			.add(new ar.Partition("*"))
		)
		.add(
			(new ar.List)
			.add(new ar.Partition)
			.add(new ar.Slider!float("slider!float", f, 0, 255))
		);
	}
	
	void draw(){
		f.writeln;
		gui.draw;
	}
}
void main(){ar.run(new TestApp);}
---
++/
class Gui {
	public{
		/++
		++/
		this(){
			_style = new Style;
			_style.font = new armos.graphics.BitmapFont;
			_style.font.load("font.png", 8, 8);
			_style.colors["font1"] = Color(200, 200, 200);
			_style.colors["font2"] = Color(105, 105, 105);
			_style.colors["background"] = Color(40, 40, 40, 200);
			_style.colors["base1"] = Color(105, 105, 105);
			_style.colors["base2"] = Color(150, 150, 150);
			_style.width = 256;
		}
		
		/++
			Listを自身に追加します．また自身を返すためメソッドチェインが可能です．
		++/
		Gui add(List list){
			_lists ~= list;
			list.style = _style;
			return this;
		};
		
		/++
			Guiの内部のウィジェットを再帰的に描画します．
		++/
		void draw(){
			armos.graphics.pushStyle;
				armos.graphics.blendMode(armos.graphics.BlendMode.Alpha);
				armos.graphics.disableDepthTest;
				
				int currentWidth = 0;
				foreach (list; _lists) {
					armos.graphics.pushMatrix;
					armos.graphics.translate(currentWidth, 0, 0);
					list.draw(currentWidth);
					armos.graphics.popMatrix;
					currentWidth += list.width + _style.font.width;
				}
			armos.graphics.popStyle;
		}
		
	}//public

	private{
		List[] _lists;
		Style _style;
	}//private
}//class Gui

class Style {
	public{
		this(){}
		
		int width = 256;
		armos.graphics.BitmapFont font;
		
		armos.types.color.Color[string] colors;
	}//public

	private{
	}//private
}//class Style

/++
Guiの構成要素でWidgetを複数格納するclassです．
++/
class List {
	public{

		/++
			Widgetを追加します．また自身を返すためメソッドチェインが可能です．
		++/
		List add(lazy Widget widget){
			_widgets ~= widget;
			return this;
		}
		
		/++
		++/
		void style(Style stl){
			foreach (widget; _widgets) {
				widget.style = stl;
			}
		}
		
		/++
			Widgetを描画します．
		++/
		void draw(in int posX){
			int currentHeight= 0;
			foreach (widget; _widgets) {
				armos.graphics.pushMatrix;
				armos.graphics.translate(0, currentHeight, 0);
				widget.position = armos.math.Vector2i(posX, currentHeight);
				widget.draw();
				armos.graphics.popMatrix;
				currentHeight += widget.height;
			}
		}
		
		/++
		++/
		int width()const{
			return _width;
		}
	}//public

	private{
		Widget[] _widgets;
		int _width = 256;
	}//private
}//class List

/++
LabelやSlider等の基底クラスです．Listの構成要素となります．
++/
class Widget {
	public{
		/++
			描画を行います．
		++/
		void draw(){};
		
		/++
			Widgetの高さを返します．
		++/
		int height(){return _height;}
		
		/++
		++/
		void style(Style stl){_style = stl;}
		
		/++
			Widgetの座標を返します．
		++/
		void position(armos.math.Vector2i pos){_position = pos;}
		
		/++
			マウスが動いた時に呼ばれるイベントハンドラです．
		++/
		void mouseMoved(ref armos.events.MouseMovedEventArg message){}
		
		/++
			マウスのボタンが離された時に呼ばれるイベントハンドラです．
		++/
		void mouseReleased(ref armos.events.MouseReleasedEventArg message){}
		
		/++
			マウスのボタンが押された時に呼ばれるイベントハンドラです．
		++/
		void mousePressed(ref armos.events.MousePressedEventArg message){}
	}//public

	private{
		int _height = 128;
	}//private
	
	protected{
		armos.math.Vector2i _position;
		Style _style;
	}//protected
}//class Widget

/++
文字列を表示するWidgetを継承したclassです．
++/
class Label : Widget{
	public{
		/++
			表示する文字列を指定して初期化を行います．
		++/
		this(string str){
			_str = str;
			_height = 16;
		};
		
		/++
		++/
		void draw(){
			armos.graphics.setColor(_style.colors["background"]);
			armos.graphics.drawRectangle(0, 0, _style.width, _style.font.height*2);
			armos.graphics.setColor(_style.colors["font1"]);
			_style.font.draw(_str, _style.font.width, 0);
		};
	}//public

	private{
		string _str;
	}//private
}//class Label

/++
パーティションを表示するWidgetを継承したclassです．
++/
class Partition : Widget{
	public{
		/++
			初期化を行います．区切り文字を指定することもできます．
		++/
		this(string str = "/"){
			_str = str;
			_height = 16;
		};
		
		/++
		++/
		void draw(){
			armos.graphics.setColor(_style.colors["background"]);
			armos.graphics.drawRectangle(0, 0, _style.width, _style.font.height*2);
			armos.graphics.setColor(_style.colors["font2"]);
			string str;
			for (int i = 0; i < _style.width/_style.font.width/_str.length; i++) {
				str ~= _str;
			}
			_style.font.draw(str, 0, 0);
		};
		
		/++
		++/
		int height(){return _height;};
	}//public

	private{
		string _str;
	}//private
}//class Partition

/++
値を操作するSliderを表す，Widgetを継承したclassです．
++/
class Slider(T) : Widget{
	import std.format:format;
	import std.conv;
	public{
		/++
			初期化を行います．Slider固有の名前と操作する値，その上限下限を設定します．
		++/
		this(string name, ref T var, T min, T max){
			_var = &var;
			_varMin = min;
			_varMax = max;
			_name = name;
			_height = 32;
			armos.events.addListener(armos.app.currentWindow.events.mouseMoved, this, &this.mouseMoved);
			armos.events.addListener(armos.app.currentWindow.events.mouseReleased, this, &this.mouseReleased);
			armos.events.addListener(armos.app.currentWindow.events.mousePressed, this, &this.mousePressed);
		};
		
		/++
		++/
		void draw(){
			armos.graphics.setColor(_style.colors["background"]);
			armos.graphics.drawRectangle(0, 0, _style.width, _style.font.height*4);
			
			string varString = "";
			static if(__traits(isIntegral, *_var)){
				varString = format("%d", *_var).to!string;
			}else if(__traits(isFloating, *_var)){
				varString = format("%f", *_var).to!string;
			}
			armos.graphics.setColor(_style.colors["font1"]);
			_style.font.draw(_name ~ " : " ~ varString, _style.font.width, 0);
			
			int currentValueAsSliderPosition = armos.math.map.map( cast(float)( *_var ), _varMin.to!float, _varMax.to!float, 0.0, _style.width.to!float - _style.font.width.to!float*2.0).to!int;
			armos.graphics.setColor(_style.colors["base1"]);
			armos.graphics.drawRectangle(_style.font.width, _style.font.height, _style.width - _style.font.width*2, _style.font.height*2);
			armos.graphics.setColor(_style.colors["base2"]);
			armos.graphics.drawRectangle(_style.font.width, _style.font.height, cast(int)currentValueAsSliderPosition, _style.font.height*2);
		};
		
		/++
		++/
		int height(){return _height;};
		
		/++
		++/
		void mousePressed(ref armos.events.MousePressedEventArg message){
			_isPressing = isOnMouse(message.x, message.y);
		}
		
		/++
		++/
		void mouseMoved(ref armos.events.MouseMovedEventArg message){
			if(_isPressing){
				*_var = armos.math.map.map( cast(float)( message.x-_position[0]),
						_style.font.width.to!float, _style.width.to!float - _style.font.width.to!float, 
						_varMin.to!float, _varMax.to!float
						, true).to!T;
			}
		}
		
		/++
		++/
		void mouseReleased(ref armos.events.MouseReleasedEventArg message){
			if(_isPressing){
				*_var = armos.math.map.map( cast(float)( message.x-_position[0]),
						_style.font.width.to!float, _style.width.to!float - _style.font.width.to!float, 
						_varMin.to!float, _varMax.to!float
						, true).to!T;
				_isPressing = false;
			}
		}
	}//public

	private{
		string _name;
		T* _var;
		T _varMin;
		T _varMax;
		bool _isPressing = false;
		
		bool isOnMouse(int x, int y){
			int localX = x-_position[0];
			int localY = y-_position[1];
			if(_style.font.width<localX && localX<_style.width - _style.font.width){
				if(_style.font.height<localY && localY<_height - _style.font.height){
					return true;
				}
			}
			return false;
		}
	}//private
}//class Slider

