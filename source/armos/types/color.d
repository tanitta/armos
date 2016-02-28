module armos.types.color;
import armos.math;

/++
+/
struct BaseColor(T, T Limit){
	alias C = BaseColor!(T, Limit);
	
	public{
		enum T limit = Limit;
		// static if(is(T == char)){
		// 	enum T limit = 255;
		// }else static if(is(T == float)){
		// 	enum T limit = 1.0;
		// }
		
		T r = limit;
		T g = limit;
		T b = limit; 
		T a = limit;

		/++
		16進数のカラーコードで色を指定します．
		+/
		this(int hexColor, float alpha = limit){
			r = (hexColor >> 16) & 0xff;
			g = (hexColor >> 8) & 0xff;
			b = (hexColor >> 0) & 0xff;
			a = cast(T)alpha;
		}

		/++
		RGBAで色を指定します．透明度は省略可能です．
		+/
		this(float red, float green, float blue, float alpha = limit){
			r = armos.math.clamp(cast(T)red, cast(T)0, limit);
			g = armos.math.clamp(cast(T)green, cast(T)0, limit);
			b = armos.math.clamp(cast(T)blue, cast(T)0, limit);
			a = armos.math.clamp(cast(T)alpha, cast(T)0, limit);
		}

		/++
		色の加算を行います．
		+/
		C opAdd(C color){
			C result = C();
			result.r = cast(T)( this.r * this.a + color.r * color.a );
			result.g = cast(T)( this.g * this.a + color.g * color.a );
			result.b = cast(T)( this.b * this.a + color.b * color.a );
			// result.a = cast(T)( this.a + color.a );
			return result;
		}

		/++
		色の減算を行います．
		+/
		C opSub(C color){
			C result = C();
			result.r = cast(T)( this.r * this.a - color.r * color.a );
			result.g = cast(T)( this.g * this.a - color.g * color.a );
			result.b = cast(T)( this.b * this.a - color.b * color.a );
			// result.a = cast(T)( this.a - color.a );
			return result;
		}

		/++
		色をHSBで指定します．
		+/
		C hsb(in T hue, in T saturation, in T value){
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
			r = cast(T)red;
			g = cast(T)green;
			b = cast(T)blue;
			return this;
		}
		
		F opCast(F)()const if(is(F == BaseColor!(typeof( F.r ), F.limit))){
			import std.conv:to;
			F castedColor= F(0, 0, 0, 0);
			float c = cast(float)castedColor.limit / cast(float)limit;
			alias CT = typeof(F.r);
			castedColor.r = cast(CT)( cast(float)r*c );
			castedColor.g = cast(CT)( cast(float)g*c );
			castedColor.b = cast(CT)( cast(float)b*c );
			castedColor.a = cast(CT)( cast(float)a*c );
			return castedColor;
		}
		unittest{
			import std.stdio;
			import std.math;
			auto cColor = BaseColor!(char, 255)(128, 0, 0, 255);
			assert(approxEqual( ( cast(BaseColor!(float, 1.0f))cColor ).r, 128.0/255.0 ));
			
			auto fColor = BaseColor!(float, 1.0f)(0.5, 0.0, 0.0, 1.0);
			assert(approxEqual( ( cast(BaseColor!(char, 255))cColor ).r, 128));
		}
	}//public

	private{
	}//private
}//struct BaseColor

/++
色を表すstructです．1byteの色深度を持ちます．
最小値は0，最大値は255です．
+/
alias BaseColor!(char, 255) Color;
unittest{
	assert(__traits(compiles, (){
		auto color = Color();
	}));
}

/++
色を表すstructです．浮動小数点型で値を持ちます．

最小値は0.0，最大値は1.0です．
+/
alias BaseColor!(float, 1.0f) FloatColor;
unittest{
	assert(__traits(compiles, (){
		auto color = FloatColor();
	}));
}
