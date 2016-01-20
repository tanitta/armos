module armos.utils.gui;
import armos.graphics;
import armos.types.color;
import armos.app;

/++
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
			_style.colors["background"] = Color(50, 50, 50, 128);
			_style.colors["base1"] = Color(105, 105, 105);
			_style.colors["base2"] = Color(150, 150, 150);
		}
		
		/++
		++/
		// Gui add(lazy List list){
		Gui add(List list){
			_lists ~= list;
			import std.stdio;
			"gui add".writeln;
			return this;
		};
		
		/++
		++/
		void draw(){
			int currentWidth = 0;
			foreach (list; _lists) {
				armos.graphics.pushMatrix;
				armos.graphics.translate(currentWidth, 0, 0);
				list.draw(_style);
				armos.graphics.popMatrix;
				currentWidth += list.width;
			}
			armos.graphics.blendMode(armos.graphics.BlendMode.Alpha);
		}
		
	}//public

	private{
		List[] _lists;
		Style _style;
	}//private
}//class Gui

/++
++/
class Style {
	public{
		this(){}
		
		armos.graphics.BitmapFont font;
		
		armos.types.color.Color[string] colors;
	}//public

	private{
	}//private
}//class Style

/++
++/
class List {
	public{

		/++
		++/
		List add(lazy Widget widget){
			_widgets ~= widget;
			import std.stdio;
			"list add".writeln;
			return this;
		}
		
		/++
		++/
		void style(Style stl){
			_style = stl;
		}
		
		/++
		++/
		void draw(Style style){
			_style = style;
			int currentHeight= 0;
			foreach (widget; _widgets) {
				armos.graphics.pushMatrix;
				armos.graphics.translate(0, currentHeight, 0);
				widget.draw(_style, _width);
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
		Style _style;
	}//private
}//class List

/++
++/
class Widget {
	public{
		/++
		++/
		void draw(Style style, in int width){};
		
		/++
		++/
		int height(){return _height;};
		
		/++
		++/
		void mouseMoved(ref armos.events.MouseMovedEventArg message){}
		
		/++
		++/
		void mouseReleased(ref armos.events.MouseReleasedEventArg message){}
		
		/++
		++/
		void mousePressed(ref armos.events.MousePressedEventArg message){}
	}//public

	private{
		int _height = 128;
	}//private
	
	protected{
	}//protected
}//class Widget

/++
++/
class Label : Widget{
	public{
		/++
		++/
		this(string str){
			_str = str;
			_height = 16;
		};
		
		/++
		++/
		void draw(Style style, in int width){
			armos.graphics.setColor(style.colors["background"]);
			armos.graphics.drawRectangle(0, 0, width, style.font.height*2);
			armos.graphics.setColor(style.colors["font1"]);
			style.font.draw(_str, 0, 0);
		};
	}//public

	private{
		string _str;
		// armos.math.Vector2i _position;
	}//private
}//class Label

/++
++/
class Partition : Widget{
	public{
		/++
		++/
		this(string str = "-"){
			_str = str;
			_height = 16;
		};
		
		/++
		++/
		void draw(Style style, in int width){
			armos.graphics.setColor(style.colors["background"]);
			armos.graphics.drawRectangle(0, 0, width, style.font.height*2);
			armos.graphics.setColor(style.colors["font2"]);
			string str;
			for (int i = 0; i < width/style.font.width/_str.length; i++) {
				str ~= _str;
			}
			style.font.draw(str, 0, 0);
		};
		
		/++
		++/
		int height(){return _height;};
	}//public

	private{
		string _str;
	}//private
}//class Partition

// /++
// ++/
// class Slider : Widget{
// 	public{
// 		/++
// 		++/
// 		this(Style style){
// 			_style = style;
// 			_height = 16;
// 			armos.events.addListener(armos.app.currentWindow.events.mouseMoved, this, &this.mouseMoved);
// 			armos.events.addListener(armos.app.currentWindow.events.mouseReleased, this, &this.mouseReleased);
// 			armos.events.addListener(armos.app.currentWindow.events.mousePressed, this, &this.mousePressed);
// 		};
//		
// 		/++
// 		++/
// 		void draw(in int width){};
//		
// 		/++
// 		++/
// 		int height(){return _height;};
// 	}//public
//
// 	private{
// 	}//private
// }//class Slider
//
