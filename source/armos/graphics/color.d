module armos.graphics.color;
import armos.math;

class BaseColor(PixelType) {
	PixelType r, g, b, a;
	PixelType limit = 255;
	this(){
		r = PixelType.max;
		g = PixelType.max;
		b = PixelType.max;
		a = PixelType.max;
	}
	
	this(float red, float green, float blue, float alpha = limit){
		r = armos.math.clamp(cast(PixelType)red, PixelType.init, limit);
		g = armos.math.clamp(cast(PixelType)green, PixelType.init, limit);
		b = armos.math.clamp(cast(PixelType)blue, PixelType.init, limit);
		a = armos.math.clamp(cast(PixelType)alpha, PixelType.init, limit);
	}
	
	BaseColor!(PixelType) opAdd(BaseColor!(PixelType) color){
		BaseColor!(PixelType) result = new BaseColor!(PixelType);
		result.r = cast(PixelType)( this.r * this.a + color.r * color.a );
		result.g = cast(PixelType)( this.g * this.a + color.g * color.a );
		result.b = cast(PixelType)( this.b * this.a + color.b * color.a );
		// result.a = cast(PixelType)( this.a + color.a );
		return result;
	}
	
	BaseColor!(PixelType) opSub(BaseColor!(PixelType) color){
		BaseColor!(PixelType) result = new BaseColor!(PixelType);
		result.r = cast(PixelType)( this.r * this.a - color.r * color.a );
		result.g = cast(PixelType)( this.g * this.a - color.g * color.a );
		result.b = cast(PixelType)( this.b * this.a - color.b * color.a );
		// result.a = cast(PixelType)( this.a - color.a );
		return result;
	}
}

class Color : BaseColor!(char){
	char limit = 255;
};

class FloatColor : BaseColor!(float){
	float limit = 1.0;
};

unittest{
	auto color = new Color;
}
