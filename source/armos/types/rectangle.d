module armos.types.rectangle;
import armos.math;
class Rectangle {
	armos.math.Vector2f position;
	armos.math.Vector2f size;
	
	this(){
		// auto position = new armos.math.Vector2f;
		// auto size = new armos.math.Vector2f;
	};
	
	this(armos.math.Vector2f p, armos.math.Vector2f s){
		position = p;
		size = s;
	}
	
	void set(in float x, in float y, in float width, in float height){
		position = armos.math.Vector2f(x, y);
		size = armos.math.Vector2f(width, height);
	}
	
	void set(in armos.math.Vector2f p, in armos.math.Vector2f s){
		position = cast( armos.math.Vector2f )p;
		size = cast( armos.math.Vector2f )s;
	}
	
	float x(){return position[0];}
	void x(float x_){position[0] = x_;}
	
	float y(){return position[1];}
	void y(float y_){position[1] = y_;}
	
	float width(){return size[0];}
	void width(float width_){size[0] = width_;}
	
	float height(){return size[1];}
	void height(float height_){size[1] = height_;}
}

