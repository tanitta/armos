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
