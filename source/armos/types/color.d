module armos.types.color;
import armos.math;

/++
+/
struct BaseColor(T, T Limit){
    alias C = BaseColor!(T, Limit);

    public{
        /// Upper limit of each channel.
        enum T limit = Limit;

        /// Red Channel.
        T r = limit;

        /// Green Channel.
        T g = limit;

        /// Blue Channel.
        T b = limit; 

        /// Alpha Channel.
        T a = limit;

        /++
            16進数のカラーコードで色を指定します．
        +/
        this(in int hexColor, in float alpha = limit){
            char r255 = (hexColor >> 16) & 0xff;
            char g255 = (hexColor >> 8) & 0xff;
            char b255 = (hexColor >> 0) & 0xff;
            import std.conv:to;
            r = (r255.to!float*limit/255.0f).to!T;
            g = (g255.to!float*limit/255.0f).to!T;
            b = (b255.to!float*limit/255.0f).to!T;
            a = cast(T)alpha;
        }

        /++
            RGBAで色を指定します．透明度は省略可能です．
        +/
        this(in float red, in float green, in float blue, in float alpha = limit){
            assert(red   <= limit);
            assert(green <= limit);
            assert(blue  <= limit);
            assert(alpha <= limit);
            r = armos.math.clamp(cast(T)red, T(0), limit);
            g = armos.math.clamp(cast(T)green, T(0), limit);
            b = armos.math.clamp(cast(T)blue, T(0), limit);
            a = armos.math.clamp(cast(T)alpha, T(0), limit);
        }
        
        this(V)(V v)if(isVector!(V) && V.dimention == 4){
            import std.conv;
            r = (v.x.to!float * limit.to!float).to!T;
            g = (v.y.to!float * limit.to!float).to!T;
            b = (v.z.to!float * limit.to!float).to!T;
            a = (v.w.to!float * limit.to!float).to!T;
        }

        /++
            色の加算を行います．
        +/
        C opAdd(in C color)const{
            import std.conv;

            C result;
            float alphaPercentageL = this.a.to!float/limit.to!float;
            float alphaPercentageR = color.a.to!float/color.limit.to!float;
            import std.math;

            result.r = fmax(fmin( this.r.to!float * alphaPercentageL + color.r.to!float * alphaPercentageR, this.limit), float(0)).to!T;
            result.g = fmax(fmin( this.g.to!float * alphaPercentageL + color.g.to!float * alphaPercentageR, this.limit), float(0)).to!T;
            result.b = fmax(fmin( this.b.to!float * alphaPercentageL + color.b.to!float * alphaPercentageR, this.limit), float(0)).to!T;
            return result;
        }
        unittest{
            alias C = BaseColor!(char, 255);
            immutable colorL = C(128, 64, 0, 255);
            immutable colorR = C(128, 0, 64, 255);
            assert(colorL + colorR == C(255, 64, 64, 255));
        }

        /++
            色の減算を行います．
        +/
        C opSub(in C color)const{
            import std.conv;
            C result;
            float alphaPercentageL = this.a.to!float/limit.to!float;
            float alphaPercentageR = color.a.to!float/color.limit.to!float;
            import std.math;

            result.r = fmax(fmin( this.r.to!float * alphaPercentageL - color.r.to!float * alphaPercentageR, this.limit), float(0)).to!T;
            result.g = fmax(fmin( this.g.to!float * alphaPercentageL - color.g.to!float * alphaPercentageR, this.limit), float(0)).to!T;
            result.b = fmax(fmin( this.b.to!float * alphaPercentageL - color.b.to!float * alphaPercentageR, this.limit), float(0)).to!T;
            return result;
        }
        unittest{
            alias C = BaseColor!(char, 255);
            immutable colorL = C(128, 64, 64, 255);
            immutable colorR = C(128, 0, 32, 255);
            assert(colorL - colorR == C(0, 64, 32, 255));
        }

        /++
            色をHSBで指定します．
            Params: 
            hue = [0, 255]
            saturation = [0, 255]
            value = [0, 255]
        +/
        C hsb(Hue, Saturation, Value)(in Hue hue, in Saturation saturation, in Value value)if(__traits(isArithmetic, Hue, Saturation, Value)){
            import std.math;
            import std.conv;
            immutable float castedLimit = limit.to!float;
            immutable float h = hue.to!float*360.0f/castedLimit;
            immutable int hi = ( floor(h / 60.0f) % 6 ).to!int;
            immutable f  = (h / 60.0f) - floor(h / 60.0f);
            immutable p  = round(value * (1.0f - (saturation / castedLimit)));
            immutable q  = round(value * (1.0f - (saturation / castedLimit) * f));
            immutable t  = round(value * (1.0f - (saturation / castedLimit) * (1.0f - f)));
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

            r = red.to!T;
            g = green.to!T;
            b = blue.to!T;
            return this;
        }
        unittest{
            import std.conv;
            auto cColor = BaseColor!(char, 255)(128, 0, 0, 255);
            cColor.hsb(0, 255, 255);
            assert(cColor.r.to!int == 255);
            assert(cColor.g.to!int == 0);
            assert(cColor.b.to!int == 0);

            cColor.hsb(255, 255, 255);
            assert(cColor.r.to!int == 255);
            assert(cColor.g.to!int == 0);
            assert(cColor.b.to!int == 0);
            // import std.stdio;
            // cColor.r.to!int.writeln;
            // cColor.g.to!int.writeln;
            // cColor.b.to!int.writeln;

            cColor.hsb(255.0/3.0, 255.0, 255.0);
            assert(cColor.r.to!int == 0);
            assert(cColor.g.to!int == 255);
            assert(cColor.b.to!int == 0);
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
alias BaseColor!(float, 1.0f) Color;
unittest{
    assert(__traits(compiles, (){
                auto color = Color();
                }));
}

/++
色を表すstructです．浮動小数点型で値を持ちます．

最小値は0.0，最大値は1.0です．
+/
deprecated alias BaseColor!(float, 1.0f) FloatColor;
unittest{
    assert(__traits(compiles, (){
                auto color = FloatColor();
                }));
}
