module armos.types.color;
import armos.math;

/++
色情報を表すstructを構成するtemplateです．
+/
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
	
	/++
		16進数のカラーコードで色を指定します．
	+/
	this(int hexColor, float alpha = limit){
		r = (hexColor >> 16) & 0xff;
		g = (hexColor >> 8) & 0xff;
		b = (hexColor >> 0) & 0xff;
		a = cast(PixelType)alpha;
	}
	
	/++
		RGBAで色を指定します．透明度は省略可能です．
	+/
	this(float red, float green, float blue, float alpha = limit){
		r = armos.math.clamp(cast(PixelType)red, cast(PixelType)0, limit);
		g = armos.math.clamp(cast(PixelType)green, cast(PixelType)0, limit);
		b = armos.math.clamp(cast(PixelType)blue, cast(PixelType)0, limit);
		a = armos.math.clamp(cast(PixelType)alpha, cast(PixelType)0, limit);
	}
	
	/++
		色の加算を行います．
	+/
	ColorType opAdd(ColorType color){
		ColorType result = ColorType();
		result.r = cast(PixelType)( this.r * this.a + color.r * color.a );
		result.g = cast(PixelType)( this.g * this.a + color.g * color.a );
		result.b = cast(PixelType)( this.b * this.a + color.b * color.a );
		// result.a = cast(PixelType)( this.a + color.a );
		return result;
	}
	
	/++
		色の減算を行います．
	+/
	ColorType opSub(ColorType color){
		ColorType result = ColorType();
		result.r = cast(PixelType)( this.r * this.a - color.r * color.a );
		result.g = cast(PixelType)( this.g * this.a - color.g * color.a );
		result.b = cast(PixelType)( this.b * this.a - color.b * color.a );
		// result.a = cast(PixelType)( this.a - color.a );
		return result;
	}
	
	/++
		色をHSBで指定します．
	+/
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

/++
色を表すstructです．1byteの色深度を持ちます．
+/
struct Color{
	mixin BaseColor!(Color, char);
	static const char limit = 255;
	// this(float red, float green, float blue, float alpha = limit){
		// this(red, green, blue, alpha);
	// }
};

/++
色を表すstructです．浮動小数点型で値を持ちます．

最小値は0.0，最大値は1.0です．
+/
struct FloatColor{
	mixin BaseColor!(FloatColor, float);
	static const float limit = 1.0;
};

unittest{
	auto color = Color();
}
