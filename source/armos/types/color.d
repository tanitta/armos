module armos.types.color;
import armos.math;

mixin template BaseColor(ColorType, PixelType) {
	static const PixelType limit = 255;
	PixelType r=limit;
	PixelType g=limit;
	PixelType b=limit; 
	PixelType a=limit;
	// this(){
	// 	r = PixelType.max;
	// 	g = PixelType.max;
	// 	b = PixelType.max;
	// 	a = PixelType.max;
	// }
	
	 this(int hexColor, float alpha = limit){
		r = (hexColor >> 16) & 0xff;
		g = (hexColor >> 8) & 0xff;
		b = (hexColor >> 0) & 0xff;
		a = cast(PixelType)alpha;
	}
	
	this(float red, float green, float blue, float alpha = limit){
		r = armos.math.clamp(cast(PixelType)red, cast(PixelType)0, limit);
		g = armos.math.clamp(cast(PixelType)green, cast(PixelType)0, limit);
		b = armos.math.clamp(cast(PixelType)blue, cast(PixelType)0, limit);
		a = armos.math.clamp(cast(PixelType)alpha, cast(PixelType)0, limit);
	}
	
	ColorType opAdd(ColorType color){
		ColorType result = ColorType();
		result.r = cast(PixelType)( this.r * this.a + color.r * color.a );
		result.g = cast(PixelType)( this.g * this.a + color.g * color.a );
		result.b = cast(PixelType)( this.b * this.a + color.b * color.a );
		// result.a = cast(PixelType)( this.a + color.a );
		return result;
	}
	
	ColorType opSub(ColorType color){
		ColorType result = ColorType();
		result.r = cast(PixelType)( this.r * this.a - color.r * color.a );
		result.g = cast(PixelType)( this.g * this.a - color.g * color.a );
		result.b = cast(PixelType)( this.b * this.a - color.b * color.a );
		// result.a = cast(PixelType)( this.a - color.a );
		return result;
	}
	
	ColorType hsb(in PixelType hue, in PixelType saturation, in PixelType value){
		import std.math;
		float castedLimit = cast(float)limit;
		float h = cast(float)hue*360.0/castedLimit;
		int hi = cast(int)( floor(h / 60.0f) % 6 );
		auto f  = (h / 60.0f) - floor(h / 60.0f);
		auto p  = round(value * (1.0f - (saturation / castedLimit)));
		auto q  = round(value * (1.0f - (saturation / castedLimit) * f));
		auto t  = round(value * (1.0f - (saturation / castedLimit) * (1.0f - f)));
		float red, green, blue;
		switch (hi) {
			case 0:
				red = value, green = t,     blue = p;
				break;
			case 1:
				red = q,     green = value, blue = p;
				break;
			case 2:
				red = p,     green = value, blue = t;
				break;
			case 3:
				red = p,     green = q,     blue = value;
				break;
			case 4:
				red = t,     green = p,     blue = value;
				break;
			case 5:
				red = value, green = p,     blue = q;
				break;
			default:
				break;
		}
		r = cast(PixelType)red;
		g = cast(PixelType)green;
		b = cast(PixelType)blue;
		return this;
	}
	
}

struct Color{
	mixin BaseColor!(Color, char);
	static const char limit = 255;
	// this(float red, float green, float blue, float alpha = limit){
		// this(red, green, blue, alpha);
	// }
};

struct FloatColor{
	mixin BaseColor!(FloatColor, float);
	static const float limit = 1.0;
};

unittest{
	auto color = Color();
}
