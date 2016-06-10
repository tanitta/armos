module armos.graphics.font;
import armos.graphics;
import derelict.freetype.ft;

/++
読み込まれる文字を表します．
+/
struct Character{
    int index;
    int glyph;
    int height;
    int width;
    int bearingX, bearingY;
    int xmin, xmax, ymin, ymax;
    int advance;
    float tW,tH;
    float t1,t2,v1,v2;

    void setupInfo(in int index, in int glyph, in FT_Face face){
        this.index = index;
        this.glyph = glyph;
        height     = cast(int)face.glyph.metrics.height >>6;
        width      = cast(int)face.glyph.metrics.width >>6;
        bearingX   = cast(int)face.glyph.metrics.horiBearingX >>6;
        bearingY   = cast(int)face.glyph.metrics.horiBearingY >>6;
        xmin       = face.glyph.bitmap_left;
        xmax       = xmin + width;
        ymin       = -face.glyph.bitmap_top;
        ymax       = ymin + height;
        advance    = cast(int)face.glyph.metrics.horiAdvance >>6;
        tW         = width;
        tH         = height;
    }
} 

/++
Fontを読み込み，描画を行います．
Deprecated: 現在動作しません．
+/
class Font{
    public{
        this(){
            DerelictFT.load();
            if(!_librariesInitialized){
                FT_Error error = FT_Init_FreeType( &_library );
                if(!error){
                    _librariesInitialized = true;
                }
            }
        }

        /++
            +/
            void load(
                    string fontName, int fontSize, 
                    bool isAntiAliased=false,
                    bool isFullCharacterSet=false,
                    bool makeContours=false,
                    float simplifyAmt=0.3f,
                    int dpi=0
                    ){
                int fontId = 0;
                // string filePath = armos.utils.toDataPath( fontName );
                string filePath = "";
                FT_Error error = FT_New_Face( _library, filePath.ptr, fontId, &_face );

                if(dpi!=0){
                    _dpi = dpi;
                }

                FT_Set_Char_Size( _face, fontSize << 6, fontSize << 6, _dpi, _dpi);
                float fontUnitScale = (cast(float)fontSize * _dpi) / (72 * _face.units_per_EM);
                _lineHeight = _face.height * fontUnitScale;
                _ascenderHeight = _face.ascender * fontUnitScale;
                _descenderHeight = _face.descender * fontUnitScale;

                _glyphBBox.set(
                        _face.bbox.xMin * fontUnitScale,
                        _face.bbox.yMin * fontUnitScale,
                        (_face.bbox.xMax - _face.bbox.xMin) * fontUnitScale,
                        (_face.bbox.yMax - _face.bbox.yMin) * fontUnitScale
                        );

                _useKerning = FT_HAS_KERNING( _face );

                _numCharacters = (isFullCharacterSet ? 256 : 128) - NUM_CHARACTER_TO_START;

                loadEachCharacters(isAntiAliased);
            }

        /++
            +/
            void drawString(string drawnString, int x, int y)const{}

        /++
            +/
            void drawStringAsShapes(string drawnString, int x, int y)const{}

    }//public

    private{
        static immutable  NUM_CHARACTER_TO_START = 32;
        static FT_Library _library;
        static bool _librariesInitialized = false;
        static int _dpi = 96;
        Character[] _characters;
        FT_Face _face;
        float _lineHeight = 0.0;
        float _ascenderHeight = 0.0;
        float _descenderHeight = 0.0;
        bool _useKerning;
        int _numCharacters = 0;
        armos.types.Rectangle _glyphBBox;
        armos.graphics.Texture _textureAtlas;

        /++
            +/
            void loadEachCharacters(bool isAntiAliased){
                int border = 1;
                long areaSum=0;
                _characters = new Character[](_numCharacters);
                armos.graphics.Bitmap!(char)[] expandedData = new armos.graphics.Bitmap!(char)[](_numCharacters);

                foreach (int i, ref character; _characters) {
                    int glyph = cast(char)(i+NUM_CHARACTER_TO_START);
                    if (glyph == 0xA4) glyph = 0x20AC; // hack to load the euro sign, all codes in 8859-15 match with utf-32 except for this one
                    FT_Error error = FT_Load_Glyph( _face, FT_Get_Char_Index( _face, glyph ), isAntiAliased ?  FT_LOAD_FORCE_AUTOHINT : FT_LOAD_DEFAULT );

                    if (isAntiAliased == true){
                        FT_Render_Glyph(_face.glyph, FT_RENDER_MODE_NORMAL);
                    }else{
                        FT_Render_Glyph(_face.glyph, FT_RENDER_MODE_MONO);
                    }

                    FT_Bitmap* bitmap= &_face.glyph.bitmap;

                    auto width  = bitmap.width;
                    auto height = bitmap.rows;

                    character.setupInfo(i, glyph, _face);

                    areaSum += cast(long)( (character.tW+border*2)*(character.tH+border*2) );

                    if(width==0 || height==0) continue;
                    expandedData[i].allocate(width, height, armos.graphics.ColorFormat.GrayAlpha);
                    expandedData[i].setAllPixels(0, 255);
                    expandedData[i].setAllPixels(1, 0);

                    if (isAntiAliased){
                    } else {
                        auto src =  bitmap.buffer;
                        for(typeof(height) j=0; j < height; j++) {
                            char b=0;
                            auto bptr =  src;
                            for(typeof(width) k=0; k < width; k++){
                                expandedData[i].pixel(k, j, 0, 255);

                                if (k%8==0){
                                    b = (*bptr++);
                                }

                                expandedData[i].pixel(k, j, 1, b&0x80 ? 255 : 0);
                                b <<= 1;
                            }
                            src += bitmap.pitch;
                        }
                    }
                }	

            }

        /++
            +/
            bool packInTexture(in long areaSum, in int border, armos.graphics.Bitmap!(char)[] expandedData){
                import std.algorithm;
                bool compareCharacters(in Character c1, in Character c2){
                    if(c1.tH == c2.tH) return c1.tW > c2.tW;
                    else return c1.tH > c2.tH;
                }
                auto sortedCharacter = _characters;
                sort!(compareCharacters)(sortedCharacter);

                armos.math.Vector2i atlasSize = calcAtlasSize(areaSum, sortedCharacter, border);

                armos.graphics.Bitmap!char atlasPixelsLuminanceAlpha;
                atlasPixelsLuminanceAlpha.allocate(atlasSize[0], atlasSize[1], armos.graphics.ColorFormat.GrayAlpha);
                atlasPixelsLuminanceAlpha.setAllPixels(0,255);
                atlasPixelsLuminanceAlpha.setAllPixels(1,0);


                int x=0;
                int y=0;
                int maxRowHeight = cast(int)sortedCharacter[0].tH + border*2;
                for(int i = 0; i < cast(int)sortedCharacter.length; i++){
                    armos.graphics.Bitmap!(char)* charBitmap = &expandedData[cast(int)sortedCharacter[i].index];

                    if(x+cast(int)sortedCharacter[i].tW + border*2 > atlasSize[0]){
                        x = 0;
                        y += maxRowHeight;
                        maxRowHeight = cast(int)sortedCharacter[i].tH + border*2;
                    }

                    _characters[sortedCharacter[i].index].t1		= cast( float )(x + border)/cast( float )(atlasSize[0]);
                    _characters[sortedCharacter[i].index].v1		= cast( float )(y + border)/cast( float )(atlasSize[1]);
                    _characters[sortedCharacter[i].index].t2		= float(_characters[sortedCharacter[i].index].tW + x + border)/float(atlasSize[0]);
                    _characters[sortedCharacter[i].index].v2		= float(_characters[sortedCharacter[i].index].tH + y + border)/float(atlasSize[1]);
                    charBitmap.pasteInto(atlasPixelsLuminanceAlpha,x+border,y+border);
                    x+= cast(int)sortedCharacter[i].tW + border*2;
                }
                _textureAtlas.allocate(atlasPixelsLuminanceAlpha);

                // if(bAntiAliased && fontSize>20){
                // 	_textureAtlas.setTextureMinMagFilter(GL_LINEAR,GL_LINEAR);
                // }else{
                // 	_textureAtlas.setTextureMinMagFilter(GL_NEAREST,GL_NEAREST);
                // }
                // _textureAtlas.loadData(atlasPixelsLuminanceAlpha);

                return true;
            }

        /++
            +/
            armos.math.Vector2i calcAtlasSize(long areaSum, in Character[] sortedCharacter, int border){
                import std.math;
                bool packed = false;
                float alpha = log(cast(float)areaSum)*1.44269;
                int w;
                int h;
                while(!packed){
                    w = cast(int)pow(2,floor((alpha/2.0) + 0.5)); 
                    h = w;
                    int x=0;
                    int y=0;
                    int maxRowHeight = cast(int)sortedCharacter[0].tH + border*2;
                    for(int i=0; i<cast(int)sortedCharacter.length; i++){
                        if(x+sortedCharacter[i].tW + border*2>w){
                            x = 0;
                            y += maxRowHeight;
                            maxRowHeight = cast(int)sortedCharacter[i].tH + border*2;
                            if(y + maxRowHeight > h){
                                alpha++;
                                break;
                            }
                        }
                        x+= cast(int)sortedCharacter[i].tW + border*2;
                        if(i==cast(int)sortedCharacter.length-1){
                            packed = true;
                        }
                    }
                }
                return armos.math.Vector2i(w, h);
            }

        /++
            +/
            // string fontPathByName(string fontName){
            // 	version(linux){
            // 		import std.string;
            // 		string fileName;
            // 		FcPattern* pattern = FcNameParse(cast(const FcChar8*)fontname.toStringz);
            // 		return fileName;
            // 	}
            // 	version(Windows){
            // 		return "";
            // 	}
            // };
    }//private
}

/++
Fontを読み込みます
Deprecated: 現在動作しません．
+/
class FontLoader{
    public{
        /++
            +/
            void loadFont(
                    string fontName, int fontSize, 
                    bool isAntiAliased=false,
                    bool isFullCharacterSet=false,
                    bool makeContours=false,
                    float simplifyAmt=0.3f,
                    int dpi=0
                    ){}
    }//public

    private{}//private
}
